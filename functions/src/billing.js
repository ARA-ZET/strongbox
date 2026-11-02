/**
 * Monthly storage billing — pure functions, no Firestore access.
 *
 * Mirrors StorageBill in app/lib/core/constants/pricing.dart: every billable
 * unit is charged the rate recorded when it was registered; units registered
 * before rates were recorded fall back to the current price list. Billing is
 * monthly in advance, with no contract, minimum term or discounts.
 *
 * Once-off charges (pickup vehicle, packing supplies, packing helper) are
 * recorded on the job as `onceOffZar` when booked, and billed on the first
 * invoice after the job is collected or completed.
 */
const {
  BILLABLE_STATUSES,
  SAST_OFFSET_MS,
  INVOICE_DUE_DAYS,
} = require("./constants");
const defaultRates = require("./default-rates.g.json").monthlyZar;
const { clientRef, jobRef } = require("./references");

const DAY_MS = 24 * 60 * 60 * 1000;

const MONTHS = [
  "January", "February", "March", "April", "May", "June",
  "July", "August", "September", "October", "November", "December",
];

/**
 * The SAST calendar month containing [now].
 * @param {Date} now
 * @return {{key: string, label: string, start: Date, end: Date}}
 *   key "2026-11"; start/end are SAST midnights as UTC instants.
 */
function billingPeriod(now) {
  const local = new Date(now.getTime() + SAST_OFFSET_MS);
  const year = local.getUTCFullYear();
  const month = local.getUTCMonth();
  return {
    key: `${year}-${String(month + 1).padStart(2, "0")}`,
    label: `${MONTHS[month]} ${year}`,
    start: new Date(Date.UTC(year, month, 1) - SAST_OFFSET_MS),
    end: new Date(Date.UTC(year, month + 1, 1) - SAST_OFFSET_MS),
  };
}

/**
 * Monthly rate per price key: the tenant's published price list
 * (`priceLists/{tenantId}`), or the generated defaults before the first
 * publish — the same fallback priceCatalogProvider uses.
 * @param {object|undefined} priceList
 * @return {Object<string, number>}
 */
function ratesFrom(priceList) {
  if (!priceList) return { ...defaultRates };
  const rates = {};
  // Stored with the app's JSON names (PriceCatalog): `price`, `desc`.
  for (const entry of [...(priceList.boxes || []),
    ...(priceList.looseItems || [])]) {
    rates[entry.id] = Number(entry.price) || 0;
  }
  return rates;
}

/** Deterministic id, so a re-run never bills a client twice for a month. */
function invoiceId(clientId, period) {
  return `${clientId}_${period.key}`;
}

/**
 * "INV-202611-7K3QX9" — what clients quote as their EFT reference. Ends in
 * the client's account number (never their Firebase id), so a payment can
 * be matched to the client.
 */
function invoiceReference(clientId, period) {
  return `INV-${period.key.replace("-", "")}-` + clientRef(clientId).slice(3);
}

/** Job statuses whose once-off charges are due. */
const CHARGEABLE_JOB_STATUSES = new Set(["collected", "completed"]);

const JOB_KIND = {
  pickup: "Pickup",
  delivery: "Delivery",
  supplyDrop: "Supply drop-off",
};

/**
 * Once-off charge lines for [jobs] not billed yet.
 * @param {Array<object>} jobs the client's jobs docs (with id)
 * @return {Array<{jobId: string, label: string, amountZar: number}>}
 */
function onceOffCharges(jobs) {
  return jobs
      .filter((job) => !job.isDeleted && !job.invoicedIn &&
        CHARGEABLE_JOB_STATUSES.has(job.status) &&
        Number(job.onceOffZar) > 0)
      .map((job) => ({
        jobId: job.id,
        label: `${JOB_KIND[job.type] || "Job"} ` +
          `${jobRef(job.id, job.type)} — once-off`,
        amountZar: Math.round(Number(job.onceOffZar)),
      }))
      .sort((a, b) => a.jobId.localeCompare(b.jobId));
}

/**
 * The invoice for one client's month, or null when nothing is billable.
 * @param {{id: string, tenantId: string}} client
 * @param {Array<object>} units the client's storageUnits docs (with id)
 * @param {Object<string, number>} rates from ratesFrom()
 * @param {ReturnType<typeof billingPeriod>} period
 * @param {Array<object>} jobs the client's jobs docs (with id), for
 *   once-off charges
 * @return {object|null} invoice fields, minus server timestamps
 */
function buildInvoice(client, units, rates, period, jobs = []) {
  const lines = [];
  let unpriced = 0;
  for (const unit of units) {
    if (unit.isDeleted || !BILLABLE_STATUSES.has(unit.status)) continue;
    const rate = unit.monthlyRateZar > 0 ?
      unit.monthlyRateZar :
      rates[unit.priceKey] || 0;
    if (!rate) {
      unpriced++;
      continue;
    }
    lines.push({
      unitId: unit.id,
      qrCodeId: unit.qrCodeId || "",
      label: unit.label || "",
      priceKey: unit.priceKey || null,
      rateZar: rate,
    });
  }
  const charges = onceOffCharges(jobs);
  if (lines.length === 0 && charges.length === 0) return null;

  lines.sort((a, b) => a.qrCodeId.localeCompare(b.qrCodeId));
  const storage = lines.reduce((sum, line) => sum + line.rateZar, 0);
  const amount = storage +
    charges.reduce((sum, charge) => sum + charge.amountZar, 0);
  return {
    tenantId: client.tenantId,
    clientId: client.id,
    reference: invoiceReference(client.id, period),
    description: `Storage — ${period.label}`,
    amount,
    currency: "zar",
    status: "open",
    lines,
    charges,
    storageZar: storage,
    unitCount: lines.length,
    unpricedUnitCount: unpriced,
    periodStart: period.start,
    periodEnd: period.end,
    dueAt: new Date(period.start.getTime() + INVOICE_DUE_DAYS * DAY_MS),
    isDeleted: false,
  };
}

/**
 * The client's billing status given their invoices. Overdue open invoices
 * make an account pastDue; once settled it returns to active. Cancelled
 * accounts are left alone — that is an ops decision.
 * @param {string} current Client.subscriptionStatus
 * @param {Array<{status: string, dueAt: Date, isDeleted?: boolean}>} invoices
 * @param {Date} now
 * @return {string}
 */
function billingStatusFor(current, invoices, now) {
  if (current === "cancelled") return current;
  const live = invoices.filter((invoice) => !invoice.isDeleted &&
    invoice.status !== "voided");
  const overdue = live.some((invoice) => invoice.status === "open" &&
    invoice.dueAt && invoice.dueAt.getTime() < now.getTime());
  if (overdue) return "pastDue";
  if (current === "pastDue" || live.length > 0) return "active";
  return current;
}

/** "R1,234.00" — the app's formatZarExact. */
function formatZar(amount) {
  return "R" + amount.toLocaleString("en-US", {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  });
}

module.exports = {
  billingPeriod,
  ratesFrom,
  invoiceId,
  invoiceReference,
  buildInvoice,
  onceOffCharges,
  billingStatusFor,
  formatZar,
};
