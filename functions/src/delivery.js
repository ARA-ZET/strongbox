/**
 * Client delivery requests — the `requestDelivery` callable.
 *
 * The client picks units they have in storage, a day (tomorrow to 30 days
 * out, SAST), a time window and an address. The server checks every unit
 * is theirs and in storage, then — in one transaction — creates the
 * delivery job `pendingConfirmation` and moves the units to
 * `pendingDelivery`. An admin confirms it and dispatches a driver.
 */
const { HttpsError } = require("firebase-functions/v2/https");
const { FieldValue, Timestamp } = require("firebase-admin/firestore");
const logger = require("firebase-functions/logger");

const { COL } = require("./constants");
const { sastDay } = require("./booking");

const WINDOWS = new Set(["morning", "afternoon", "evening"]);
const DAY_MS = 24 * 60 * 60 * 1000;
const MAX_DAYS_AHEAD = 30;
const MAX_UNITS = 200;

function bad(message) {
  return new HttpsError("invalid-argument", message);
}

/**
 * Validates a request's shape — pure; unit ownership is checked against
 * Firestore by the callable.
 * @param {object} data
 * @param {Date} now
 * @return {{unitIds: string[], scheduledDate: Date, timeWindow: string,
 *   address: object, notes: string|null}}
 */
function planDelivery(data, now) {
  const unitIds = [...new Set(Array.isArray(data.unitIds) ?
    data.unitIds.filter((id) => typeof id === "string" && id) : [])];
  if (unitIds.length === 0) throw bad("Choose at least one item.");
  if (unitIds.length > MAX_UNITS) throw bad("That's too many items at once.");

  const scheduledDate = new Date(String(data.date || ""));
  if (Number.isNaN(scheduledDate.getTime())) {
    throw bad("Choose a delivery date.");
  }
  if (sastDay(scheduledDate) <= sastDay(now)) {
    throw bad("Deliveries need a day's notice — pick tomorrow or later.");
  }
  if (sastDay(scheduledDate) > sastDay(now) + MAX_DAYS_AHEAD) {
    throw bad(`Pick a date within the next ${MAX_DAYS_AHEAD} days.`);
  }
  const timeWindow = String(data.timeWindow || "");
  if (!WINDOWS.has(timeWindow)) throw bad("Choose a time window.");

  const raw = data.address || {};
  const text = (value, max) => String(value || "").trim().slice(0, max);
  const address = {
    line1: text(raw.line1, 120),
    line2: text(raw.line2, 120) || null,
    city: text(raw.city, 60),
    postCode: text(raw.postCode, 10),
    country: "ZA",
  };
  if (!address.line1 || !address.city) {
    throw bad("Enter the delivery address (street and suburb/city).");
  }
  return {
    unitIds,
    scheduledDate,
    timeWindow,
    address,
    notes: text(data.notes, 500) || null,
  };
}

/**
 * @param {FirebaseFirestore.Firestore} db
 */
function createDelivery(db) {
  /** data: { unitIds, date (ISO), timeWindow, address, notes? } → { jobId } */
  async function requestDelivery(request) {
    const uid = request.auth && request.auth.uid;
    if (!uid) throw new HttpsError("unauthenticated", "Sign in first.");
    const user = await db.collection(COL.users).doc(uid).get();
    if (!user.exists || user.get("role") !== "client" ||
      !user.get("clientId")) {
      throw new HttpsError("permission-denied",
          "Deliveries are requested from a client account.");
    }
    const clientId = user.get("clientId");
    const tenantId = user.get("tenantId");
    const client = await db.collection(COL.clients).doc(clientId).get();
    if (client.exists && client.get("subscriptionStatus") === "cancelled") {
      throw new HttpsError("failed-precondition",
          "This account is closed — contact us to reopen it.");
    }

    const plan = planDelivery(request.data || {}, new Date());
    const jobRef = db.collection(COL.jobs).doc();
    const now = FieldValue.serverTimestamp();

    await db.runTransaction(async (txn) => {
      const refs = plan.unitIds.map((id) =>
        db.collection(COL.storageUnits).doc(id));
      const snaps = await Promise.all(refs.map((ref) => txn.get(ref)));
      for (const snap of snaps) {
        const unit = snap.data();
        if (!snap.exists || unit.isDeleted || unit.clientId !== clientId) {
          throw new HttpsError("not-found", "One of those items isn't yours.");
        }
        if (unit.status !== "inStorage") {
          throw new HttpsError("failed-precondition",
              `${unit.label || "An item"} isn't in storage right now.`);
        }
      }
      txn.set(jobRef, {
        tenantId,
        type: "delivery",
        clientId,
        driverId: null,
        status: "pendingConfirmation",
        scheduledDate: Timestamp.fromDate(plan.scheduledDate),
        timeWindow: plan.timeWindow,
        address: plan.address,
        storageUnitIds: plan.unitIds,
        scannedUnitIds: [],
        receivedUnitIds: [],
        handedOverUnitIds: [],
        itemIds: [],
        photoIds: [],
        supplies: [],
        emptyBoxes: {},
        helperHours: 0,
        onceOffZar: 0,
        notes: plan.notes,
        source: "request",
        isRushJob: false,
        isDeleted: false,
        createdAt: now,
        updatedAt: now,
      });
      for (const ref of refs) {
        txn.update(ref, {
          status: "pendingDelivery",
          jobId: jobRef.id,
          updatedAt: now,
        });
      }
      txn.set(db.collection(COL.auditEvents).doc(), {
        tenantId,
        actorId: uid,
        actorRole: "client",
        action: "jobCreated",
        entityType: "job",
        entityId: jobRef.id,
        metadata: { type: "delivery", source: "request",
          units: plan.unitIds.length },
        timestamp: now,
      });
    });

    logger.info("Delivery requested", { jobId: jobRef.id, clientId,
      units: plan.unitIds.length });
    return { jobId: jobRef.id };
  }

  return { requestDelivery };
}

module.exports = { createDelivery, planDelivery };
