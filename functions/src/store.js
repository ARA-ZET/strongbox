/**
 * Firestore-side helpers and the billing jobs, bound to a database so the
 * emulator suite can run them directly (functions/test-emulator).
 */
const { FieldValue, Timestamp } = require("firebase-admin/firestore");
const logger = require("firebase-functions/logger");

const { COL, NOTIFY, AUDIT, SYSTEM_ACTOR } = require("./constants");
const billing = require("./billing");
const messages = require("./messages");

/** gRPC status codes surfaced by Firestore writes. */
const NOT_FOUND = 5;
/** A deterministic doc id was already written. */
const ALREADY_EXISTS = 6;

/**
 * @param {FirebaseFirestore.Firestore} db
 */
function createStore(db) {
  function auditEvent(tenantId, action, entityType, entityId, metadata = {}) {
    return {
      tenantId,
      actorId: SYSTEM_ACTOR,
      actorRole: "admin",
      action,
      entityType,
      entityId,
      metadata,
      timestamp: FieldValue.serverTimestamp(),
    };
  }

  /** An AppNotification doc. [userId] null = broadcast to the tenant's admins. */
  function notificationData(tenantId, message, userId) {
    return {
      tenantId,
      type: message.type,
      title: message.title,
      body: message.body,
      userId: userId || null,
      entityType: message.entityType || null,
      entityId: message.entityId || null,
      isRead: false,
      isDeleted: false,
      createdAt: FieldValue.serverTimestamp(),
    };
  }

  /** The uid that receives a client's notifications. */
  async function clientUserId(clientId) {
    if (!clientId) return null;
    const snap = await db.collection(COL.clients).doc(clientId).get();
    return snap.exists ? snap.get("primaryUserId") || null : null;
  }

  /**
   * Writes [drafts] (from src/messages.js) as notification docs, resolving
   * `to: "client"` via [clientId]. Drafts without a recipient are dropped.
   */
  async function deliver(tenantId, drafts, clientId) {
    if (drafts.length === 0) return;
    const needsClient = drafts.some((draft) => draft.to === "client");
    const clientUid = needsClient ? await clientUserId(clientId) : null;

    const batch = db.batch();
    let count = 0;
    for (const draft of drafts) {
      let userId = null;
      if (draft.to === "client") userId = clientUid;
      if (draft.to === "driver") userId = draft.userId;
      if (draft.to !== "admins" && !userId) continue;
      batch.create(db.collection(COL.notifications).doc(),
          notificationData(tenantId, draft, userId));
      count++;
    }
    if (count > 0) await batch.commit();
  }

  /** Creates a doc with a fixed id, treating "already exists" as done. */
  async function createOnce(ref, data) {
    try {
      await ref.create(data);
      return true;
    } catch (error) {
      if (error.code === ALREADY_EXISTS) return false;
      throw error;
    }
  }

  /**
   * Recomputes a client's billing status from their invoices; writes it with
   * an audit event when it changes (rule 7).
   */
  async function recomputeBillingStatus(clientId, now = new Date()) {
    const clientRef = db.collection(COL.clients).doc(clientId);
    // A transaction, so an invoice trigger and the daily sweep running at
    // once cannot both record the same change.
    const change = await db.runTransaction(async (tx) => {
      const client = await tx.get(clientRef);
      if (!client.exists || client.get("isDeleted")) return null;
      const tenantId = client.get("tenantId");
      const current = client.get("subscriptionStatus") || "incomplete";

      const snap = await tx.get(db.collection(COL.invoices)
          .where("tenantId", "==", tenantId)
          .where("clientId", "==", clientId));
      const invoices = snap.docs.map((doc) => ({
        status: doc.get("status"),
        isDeleted: doc.get("isDeleted"),
        dueAt: doc.get("dueAt") ? doc.get("dueAt").toDate() : null,
      }));
      const next = billing.billingStatusFor(current, invoices, now);
      if (next === current) return null;

      tx.update(clientRef, {
        subscriptionStatus: next,
        updatedAt: FieldValue.serverTimestamp(),
      });
      tx.create(db.collection(COL.auditEvents).doc(), auditEvent(
          tenantId, AUDIT.subscriptionUpdated, "client", clientId,
          { from: current, to: next }));
      return { from: current, to: next };
    });
    if (change) logger.info("Billing status changed", { clientId, ...change });
  }

  /** Issues one client's invoice for [period]; returns it, or null. */
  async function issueInvoice(clientDoc, rates, period) {
    const client = { id: clientDoc.id, ...clientDoc.data() };
    const units = await db.collection(COL.storageUnits)
        .where("tenantId", "==", client.tenantId)
        .where("clientId", "==", client.id)
        .where("isDeleted", "==", false)
        .get();
    const invoice = billing.buildInvoice(client,
        units.docs.map((doc) => ({ id: doc.id, ...doc.data() })),
        rates, period);
    if (!invoice) return null;

    const id = billing.invoiceId(client.id, period);
    const batch = db.batch();
    batch.create(db.collection(COL.invoices).doc(id), {
      ...invoice,
      periodStart: Timestamp.fromDate(invoice.periodStart),
      periodEnd: Timestamp.fromDate(invoice.periodEnd),
      dueAt: Timestamp.fromDate(invoice.dueAt),
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });
    batch.create(db.collection(COL.auditEvents).doc(), auditEvent(
        client.tenantId, AUDIT.invoiceIssued, "client", client.id,
        { invoiceId: id, amount: invoice.amount, units: invoice.unitCount }));
    if (client.primaryUserId) {
      const due = messages.sastDay(invoice.dueAt, { weekday: false });
      batch.create(db.collection(COL.notifications).doc(), notificationData(
          client.tenantId, {
            type: NOTIFY.invoiceReady,
            title: `Your ${period.label} invoice is ready`,
            body: `${billing.formatZar(invoice.amount)} for ` +
              `${invoice.unitCount} ${invoice.unitCount === 1 ? "unit" : "units"}` +
              ` — due ${due}. Use reference ${invoice.reference} when paying.`,
            entityType: "invoice",
            entityId: id,
          }, client.primaryUserId));
    }
    try {
      await batch.commit();
    } catch (error) {
      if (error.code === ALREADY_EXISTS) return null; // already billed
      throw error;
    }
    await recomputeBillingStatus(client.id);
    return invoice;
  }

  /**
   * Whether [tenantId] can be invoiced: clients need somewhere to pay, so
   * nothing is issued until Admin → Settings has EFT payment details. When
   * held, admins get one alert for the month instead.
   */
  async function billingReady(tenantId, period) {
    const tenant = await db.collection(COL.tenants).doc(tenantId).get();
    const instructions = tenant.exists ?
      String(tenant.get("paymentInstructions") || "").trim() :
      "";
    if (instructions) return true;
    logger.warn("Invoices held: no payment details", { tenantId });
    await createOnce(
        db.collection(COL.notifications)
            .doc(`invoices-held-${tenantId}-${period.key}`),
        notificationData(tenantId, {
          type: NOTIFY.systemAlert,
          title: `${period.label} invoices not issued`,
          body: "Add your EFT payment details in Settings → Business " +
            "details so clients know where to pay. Invoices go out on " +
            "the next 1st after they are saved.",
          entityType: "settings",
        }, null));
    return false;
  }

  /** Issues this month's invoices for every client (monthlyInvoices). */
  async function runMonthlyInvoices(now) {
    const period = billing.billingPeriod(now);
    const clients = await db.collection(COL.clients)
        .where("isDeleted", "==", false)
        .get();

    const ratesByTenant = new Map();
    const readyByTenant = new Map();
    const summary = new Map(); // tenantId → { count, total, unpriced, failed }
    for (const clientDoc of clients.docs) {
      const tenantId = clientDoc.get("tenantId");
      if (!readyByTenant.has(tenantId)) {
        readyByTenant.set(tenantId, await billingReady(tenantId, period));
      }
      if (!readyByTenant.get(tenantId)) continue;
      if (!ratesByTenant.has(tenantId)) {
        const list = await db.collection(COL.priceLists).doc(tenantId).get();
        ratesByTenant.set(tenantId,
            billing.ratesFrom(list.exists ? list.data() : undefined));
      }
      const totals = summary.get(tenantId) ||
        { count: 0, total: 0, unpriced: 0, failed: 0 };
      summary.set(tenantId, totals);
      try {
        const invoice = await issueInvoice(
            clientDoc, ratesByTenant.get(tenantId), period);
        if (invoice) {
          totals.count++;
          totals.total += invoice.amount;
          totals.unpriced += invoice.unpricedUnitCount;
        }
      } catch (error) {
        // One bad client must not stop everyone else's invoice.
        totals.failed++;
        logger.error("Invoice failed", { clientId: clientDoc.id, error });
      }
    }

    for (const [tenantId, totals] of summary) {
      if (totals.count === 0 && totals.failed === 0) continue;
      const notes = [];
      if (totals.unpriced > 0) {
        notes.push(`${totals.unpriced} unit${totals.unpriced === 1 ? "" : "s"}` +
          " had no size and were not billed.");
      }
      if (totals.failed > 0) {
        notes.push(`${totals.failed} failed — see the function logs.`);
      }
      await createOnce(
          db.collection(COL.notifications)
              .doc(`invoices-${tenantId}-${period.key}`),
          notificationData(tenantId, {
            type: NOTIFY.invoiceReady,
            title: `${period.label} invoices issued`,
            body: [`${totals.count} clients · ` +
              `${billing.formatZar(totals.total)} billed.`, ...notes].join(" "),
            entityType: "invoice",
          }, null));
      logger.info("Monthly invoices issued", { tenantId, period: period.key,
        ...totals });
    }
  }

  /** Overdue → pastDue, settled → active (dailyBillingSweep). */
  async function runBillingSweep(now) {
    const clientIds = new Set();
    // Single-field queries only, so no composite index is needed.
    const open = await db.collection(COL.invoices)
        .where("status", "==", "open")
        .get();
    for (const doc of open.docs) {
      const dueAt = doc.get("dueAt");
      if (dueAt && dueAt.toDate() < now) clientIds.add(doc.get("clientId"));
    }
    const pastDue = await db.collection(COL.clients)
        .where("subscriptionStatus", "==", "pastDue")
        .get();
    for (const doc of pastDue.docs) clientIds.add(doc.id);

    for (const clientId of clientIds) {
      try {
        await recomputeBillingStatus(clientId, now);
      } catch (error) {
        logger.error("Billing status sweep failed", { clientId, error });
      }
    }
  }

  return {
    auditEvent,
    notificationData,
    createOnce,
    deliver,
    recomputeBillingStatus,
    issueInvoice,
    runMonthlyInvoices,
    runBillingSweep,
  };
}

module.exports = { createStore, NOT_FOUND, ALREADY_EXISTS };
