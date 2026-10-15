const test = require("node:test");
const assert = require("node:assert/strict");
const {
  billingPeriod,
  ratesFrom,
  buildInvoice,
  billingStatusFor,
  invoiceId,
  formatZar,
} = require("../src/billing");
const defaults = require("../src/default-rates.g.json").monthlyZar;

const client = { id: "abc123xyz", tenantId: "strongbox-default" };
const period = billingPeriod(new Date("2026-11-01T04:00:00Z")); // 06:00 SAST

function unit(id, fields) {
  return { id, qrCodeId: `SBX-000${id}-A1`, label: "", isDeleted: false,
    status: "inStorage", monthlyRateZar: 0, ...fields };
}

test("billing period is the SAST calendar month", () => {
  assert.equal(period.key, "2026-11");
  assert.equal(period.label, "November 2026");
  assert.equal(period.start.toISOString(), "2026-10-31T22:00:00.000Z");
  assert.equal(period.end.toISOString(), "2026-11-30T22:00:00.000Z");
  // 23:30 UTC on 31 Oct is already 1 Nov in Johannesburg.
  assert.equal(billingPeriod(new Date("2026-10-31T23:30:00Z")).key, "2026-11");
});

test("rates come from the published list, else the generated defaults", () => {
  assert.deepEqual(ratesFrom(undefined), defaults);
  const rates = ratesFrom({
    boxes: [{ id: "small", monthlyZar: 210 }],
    looseItems: [{ id: "desk", monthlyZar: 120 }],
  });
  assert.deepEqual(rates, { small: 210, desk: 120 });
});

test("bills billable units at their recorded rate", () => {
  const invoice = buildInvoice(client, [
    unit("1", { monthlyRateZar: 195 }),
    unit("2", { status: "inTransit", monthlyRateZar: 295 }),
    unit("3", { status: "pendingDelivery", monthlyRateZar: 395 }),
    unit("4", { status: "delivered", monthlyRateZar: 999 }),
    unit("5", { status: "pendingPickup", monthlyRateZar: 999 }),
    unit("6", { isDeleted: true, monthlyRateZar: 999 }),
  ], {}, period);

  assert.equal(invoice.amount, 195 + 295 + 395);
  assert.equal(invoice.unitCount, 3);
  assert.deepEqual(invoice.lines.map((l) => l.unitId), ["1", "2", "3"]);
  assert.equal(invoice.status, "open");
  assert.equal(invoice.reference, "INV-202611-ABC123");
  assert.equal(invoice.description, "Storage — November 2026");
  assert.equal(invoice.dueAt.toISOString(), "2026-11-07T22:00:00.000Z");
});

test("a recorded rate wins over a later price change", () => {
  const invoice = buildInvoice(client,
      [unit("1", { priceKey: "small", monthlyRateZar: 180 })],
      { small: 250 }, period);
  assert.equal(invoice.amount, 180);
});

test("units without a recorded rate fall back to the list; unsized ones are skipped", () => {
  const invoice = buildInvoice(client, [
    unit("1", { priceKey: "small" }),
    unit("2", { priceKey: null }),
    unit("3", { priceKey: "retired-size" }),
  ], { small: 195 }, period);
  assert.equal(invoice.amount, 195);
  assert.equal(invoice.unitCount, 1);
  assert.equal(invoice.unpricedUnitCount, 2);
});

test("no invoice when nothing is billable", () => {
  assert.equal(buildInvoice(client,
      [unit("1", { status: "delivered", monthlyRateZar: 195 })], {}, period),
  null);
  assert.equal(buildInvoice(client, [unit("1", {})], {}, period), null);
});

test("invoice ids are one per client per month", () => {
  assert.equal(invoiceId("abc", period), "abc_2026-11");
});

test("billing status follows overdue invoices", () => {
  const now = new Date("2026-11-10T08:00:00Z");
  const overdue = { status: "open", dueAt: new Date("2026-11-07T22:00:00Z") };
  const current = { status: "open", dueAt: new Date("2026-12-07T22:00:00Z") };
  const paid = { status: "paid", dueAt: new Date("2026-10-07T22:00:00Z") };

  assert.equal(billingStatusFor("active", [overdue, paid], now), "pastDue");
  assert.equal(billingStatusFor("pastDue", [current, paid], now), "active");
  assert.equal(billingStatusFor("incomplete", [current], now), "active");
  assert.equal(billingStatusFor("incomplete", [], now), "incomplete");
  assert.equal(billingStatusFor("cancelled", [overdue], now), "cancelled");
  // A voided invoice is never chased.
  assert.equal(billingStatusFor("pastDue",
      [{ ...overdue, status: "voided" }], now), "active");
});

test("amounts format like the app's formatZarExact", () => {
  assert.equal(formatZar(1234), "R1,234.00");
  assert.equal(formatZar(195.5), "R195.50");
});
