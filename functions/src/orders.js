/**
 * Client cancellations — the `cancelOrder` callable.
 *
 * A client may cancel their own pickup or delivery until the driver
 * starts it (business rules: jobs are cancellable up until inProgress).
 * Clients can't write jobs, so — like booking — it runs here, in one
 * transaction:
 *   - the job → cancelled, with `cancelledBy: "client"` and their reason;
 *   - a booked pickup's units → cancelled; a delivery's units → back in
 *     storage. Units since moved to another job are left alone (the same
 *     rules as JobRepository._releaseUnits in the app);
 *   - a Path A pickup's supply drop-off is cancelled with it. Once the
 *     supplies are on their way or delivered the client contacts us
 *     instead, so supplies aren't handed over unbilled.
 * onJobUpdated then tells the client, the admins and any assigned driver.
 */
const { HttpsError } = require("firebase-functions/v2/https");
const { FieldValue } = require("firebase-admin/firestore");
const logger = require("firebase-functions/logger");

const { COL } = require("./constants");

/** Job statuses a client can still cancel — the driver hasn't started. */
const CANCELLABLE = new Set(["pendingConfirmation", "scheduled", "assigned"]);
const MAX_REASON = 300;

/**
 * Whether [clientId] may cancel [job] now. Pure.
 * @param {object|undefined} job
 * @param {object|undefined} linked a pickup's paired supply drop-off
 * @param {string} clientId
 * @return {boolean} false when it's already cancelled (nothing to do)
 * @throws {HttpsError} when it isn't theirs or can't be cancelled any more
 */
function checkCancel(job, linked, clientId) {
  if (!job || job.isDeleted || job.clientId !== clientId) {
    throw new HttpsError("not-found", "We couldn't find that order.");
  }
  if (job.status === "cancelled") return false;
  if (job.type !== "pickup" && job.type !== "delivery") {
    throw new HttpsError("failed-precondition",
        "Supply drop-offs are cancelled with their pickup.");
  }
  if (!CANCELLABLE.has(job.status)) {
    throw new HttpsError("failed-precondition",
        "Your driver has already started this order — contact us to " +
        "change it.");
  }
  if (linked && !linked.isDeleted && linked.status !== "cancelled" &&
    !CANCELLABLE.has(linked.status)) {
    throw new HttpsError("failed-precondition",
        "Your packing supplies are already on their way or delivered — " +
        "contact us to cancel this pickup.");
  }
  return true;
}

/**
 * What cancelling [job] does to one of its units, or null to leave it.
 * Pure — mirrors JobRepository._releaseUnits in the app.
 * @param {object} job
 * @param {string} jobId
 * @param {object|undefined} unit
 * @return {object|null} fields to update
 */
function releasedUnit(job, jobId, unit) {
  if (!unit || unit.jobId !== jobId) return null;
  const update = { jobId: null };
  if (job.type === "delivery" && unit.status === "pendingDelivery") {
    update.status = "inStorage";
  }
  if (job.type === "pickup" && job.source === "quote" &&
    unit.status === "pendingPickup") {
    update.status = "cancelled";
  }
  return update;
}

/**
 * @param {FirebaseFirestore.Firestore} db
 */
function createOrders(db) {
  /** data: { jobId, reason? } → { jobId, cancelled: true } */
  async function cancelOrder(request) {
    const uid = request.auth && request.auth.uid;
    if (!uid) throw new HttpsError("unauthenticated", "Sign in first.");
    const user = await db.collection(COL.users).doc(uid).get();
    if (!user.exists || user.get("role") !== "client" ||
      !user.get("clientId") || user.get("isDeleted") === true) {
      throw new HttpsError("permission-denied",
          "Orders are cancelled from a client account.");
    }
    const clientId = user.get("clientId");
    const data = request.data || {};
    const jobId = typeof data.jobId === "string" ? data.jobId : "";
    if (!jobId) {
      throw new HttpsError("invalid-argument", "Choose an order to cancel.");
    }
    const reason = String(data.reason || "").trim().slice(0, MAX_REASON) ||
      null;
    const jobRef = db.collection(COL.jobs).doc(jobId);
    const now = FieldValue.serverTimestamp();

    const changed = await db.runTransaction(async (txn) => {
      // All reads before any write.
      const snap = await txn.get(jobRef);
      const job = snap.exists ? snap.data() : undefined;
      const linkedId = job && job.type === "pickup" ? job.linkedJobId : null;
      const linkedRef = linkedId ? db.collection(COL.jobs).doc(linkedId) :
        null;
      const linkedSnap = linkedRef ? await txn.get(linkedRef) : null;
      const linked = linkedSnap && linkedSnap.exists ? linkedSnap.data() :
        undefined;
      if (!checkCancel(job, linked, clientId)) return false;

      const unitRefs = (job.storageUnitIds || []).map((id) =>
        db.collection(COL.storageUnits).doc(id));
      const unitSnaps = unitRefs.length ? await txn.getAll(...unitRefs) : [];

      const fields = {
        status: "cancelled",
        cancelledAt: now,
        cancelledBy: "client",
        cancelReason: reason,
        updatedAt: now,
      };
      txn.update(jobRef, fields);
      const dropToo = linked && !linked.isDeleted &&
        CANCELLABLE.has(linked.status);
      if (dropToo) txn.update(linkedRef, fields);
      for (const unitSnap of unitSnaps) {
        const update = releasedUnit(job, jobId,
            unitSnap.exists ? unitSnap.data() : undefined);
        if (update) txn.update(unitSnap.ref, { ...update, updatedAt: now });
      }
      txn.set(db.collection(COL.auditEvents).doc(), {
        tenantId: job.tenantId,
        actorId: uid,
        actorRole: "client",
        action: "jobCancelled",
        entityType: "job",
        entityId: jobId,
        metadata: {
          by: "client",
          type: job.type,
          fromStatus: job.status,
          ...(reason ? { reason } : {}),
          ...(dropToo ? { linkedJobId: linkedId } : {}),
        },
        timestamp: now,
      });
      return true;
    });

    if (changed) logger.info("Order cancelled by client", { jobId, clientId });
    return { jobId, cancelled: true };
  }

  return { cancelOrder };
}

module.exports = { createOrders, checkCancel, releasedUnit, CANCELLABLE };
