/**
 * StrongBox Cloud Functions (Stage 7).
 *
 *   onJobCreated / onJobUpdated  job events → notifications
 *   onIssueReported              driver issue report → admin notification
 *   onNotificationCreated        notification → FCM push (+ email for clients)
 *   onClientCreated              welcome email
 *   onInvoiceUpdated             paid/voided → client status + receipt
 *   monthlyInvoices              1st of the month: one invoice per client
 *   dailyBillingSweep            overdue invoices → client pastDue
 *   weeklyUnlinkedQrSweep        flags QR labels never attached to a unit
 *   inviteDriver / resendInvite  admin callables: driver login + setup link
 *
 * Billing is invoices-only: clients pay by EFT and an admin marks invoices
 * paid in the app. Emails go through the "Trigger Email from Firestore"
 * extension, which sends every doc written to `mail` — see functions/README.md.
 */
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");
const { getAuth } = require("firebase-admin/auth");
const { setGlobalOptions } = require("firebase-functions/v2");
const {
  onDocumentCreated,
  onDocumentUpdated,
} = require("firebase-functions/v2/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { onCall } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

const {
  COL,
  NOTIFY,
  TIME_ZONE,
  QR_UNLINKED_DAYS,
  APP_URL,
} = require("./src/constants");
const billing = require("./src/billing");
const messages = require("./src/messages");
const { createStore, NOT_FOUND } = require("./src/store");
const { createInvites } = require("./src/invites");

initializeApp();
// Firestore is in nam5, so triggers run in us-central1.
setGlobalOptions({ region: "us-central1", maxInstances: 10 });

const db = getFirestore();
const store = createStore(db);
const invites = createInvites(db, getAuth());
const { notificationData, createOnce, deliver, recomputeBillingStatus } = store;


/** FCM errors that mean a token will never work again. */
const DEAD_TOKEN_CODES = new Set([
  "messaging/registration-token-not-registered",
  "messaging/invalid-registration-token",
  "messaging/invalid-argument",
]);

// ---------------------------------------------------------- job events

exports.onJobCreated = onDocumentCreated(`${COL.jobs}/{jobId}`,
    async (event) => {
      const job = event.data.data();
      const client = job.clientId ?
        await db.collection(COL.clients).doc(job.clientId).get() :
        null;
      const clientName = client && client.exists ?
        client.get("displayName") :
        "";
      await deliver(job.tenantId,
          messages.jobCreatedMessages(job, event.params.jobId, clientName),
          job.clientId);
    });

exports.onJobUpdated = onDocumentUpdated(`${COL.jobs}/{jobId}`,
    async (event) => {
      const before = event.data.before.data();
      const after = event.data.after.data();
      await deliver(after.tenantId,
          messages.jobUpdatedMessages(before, after, event.params.jobId),
          after.clientId);
    });

exports.onIssueReported = onDocumentCreated(`${COL.issueReports}/{reportId}`,
    async (event) => {
      const report = event.data.data();
      const type = String(report.issueType || "other")
          .replace(/([A-Z])/g, " $1").toLowerCase();
      const description = String(report.description || "").slice(0, 140);
      await deliver(report.tenantId, [{
        to: "admins",
        type: NOTIFY.issueReported,
        title: `${report.isUrgent ? "Urgent: " : ""}Driver reported ${type}`,
        body: description || "Open the alert centre for details.",
        entityType: report.jobId ? "job" : "issue",
        entityId: report.jobId || event.params.reportId,
      }]);
    });

// ------------------------------------------------- push + email fan-out

/** Sends [n] to [user]'s devices and prunes tokens FCM has retired. */
async function push(userRef, user, n, notificationId, route) {
  const tokens = [...new Set(user.fcmTokens || [])];
  if (tokens.length === 0) return;
  const result = await getMessaging().sendEachForMulticast({
    tokens,
    notification: { title: n.title, body: n.body },
    data: {
      route,
      notificationId,
      entityType: n.entityType || "",
      entityId: n.entityId || "",
    },
    android: { priority: "high" },
    apns: { payload: { aps: { sound: "default" } } },
    webpush: { fcmOptions: { link: `${APP_URL}${route}` } },
  });
  const dead = tokens.filter((_, i) => {
    const error = result.responses[i].error;
    return error && DEAD_TOKEN_CODES.has(error.code);
  });
  if (dead.length > 0) {
    await userRef.update({ fcmTokens: FieldValue.arrayRemove(...dead) });
  }
  if (result.failureCount > dead.length) {
    // Failed push is logged, never retried into a duplicate (doc 22).
    logger.warn("Some pushes failed", {
      notificationId, failed: result.failureCount - dead.length,
    });
  }
}

exports.onNotificationCreated = onDocumentCreated(
    `${COL.notifications}/{notificationId}`,
    async (event) => {
      const n = event.data.data();
      const notificationId = event.params.notificationId;
      if (n.isDeleted) return;

      let users;
      if (n.userId) {
        const snap = await db.collection(COL.users).doc(n.userId).get();
        users = snap.exists ? [snap] : [];
      } else {
        const snap = await db.collection(COL.users)
            .where("tenantId", "==", n.tenantId)
            .where("role", "==", "admin")
            .get();
        users = snap.docs;
      }

      // Saved for the in-app inbox, which opens the same place on tap.
      // Broadcasts only ever reach admins.
      if (!n.route) {
        const role = n.userId ?
          (users[0] && users[0].get("role")) || "client" :
          "admin";
        try {
          await event.data.ref.update({ route: messages.routeFor(role, n) });
        } catch (error) {
          if (error.code !== NOT_FOUND) throw error; // removed meanwhile
          return;
        }
      }

      await Promise.all(users.map(async (snap) => {
        const user = snap.data();
        if (user.isDeleted || user.isActive === false) return;
        const route = messages.routeFor(user.role, n);

        const work = [push(snap.ref, user, n, notificationId, route)];
        if (messages.wantsEmail(user, n.type)) {
          work.push(createOnce(
              db.collection(COL.mail).doc(`notification-${notificationId}`),
              {
                to: user.email,
                message: messages.notificationEmail(n, route),
                tenantId: n.tenantId,
                createdAt: FieldValue.serverTimestamp(),
              }));
        }
        const results = await Promise.allSettled(work);
        for (const r of results) {
          if (r.status === "rejected") {
            logger.error("Notification delivery step failed", {
              notificationId, uid: snap.id, error: String(r.reason),
            });
          }
        }
      }));
    });

exports.onClientCreated = onDocumentCreated(`${COL.clients}/{clientId}`,
    async (event) => {
      const client = event.data.data();
      // Records an admin creates for someone without a login get no welcome.
      if (!client.email || !client.primaryUserId || client.isDeleted) return;
      await createOnce(
          db.collection(COL.mail).doc(`welcome-${event.params.clientId}`),
          {
            to: client.email,
            message: messages.welcomeEmail(client),
            tenantId: client.tenantId,
            createdAt: FieldValue.serverTimestamp(),
          });
    });

// ------------------------------------------------------------- billing

exports.onInvoiceUpdated = onDocumentUpdated(`${COL.invoices}/{invoiceId}`,
    async (event) => {
      const before = event.data.before.data();
      const after = event.data.after.data();
      if (before.status === after.status) return;

      await recomputeBillingStatus(after.clientId);
      if (after.status === "paid") {
        await deliver(after.tenantId, [{
          to: "client",
          type: NOTIFY.invoicePaid,
          title: "Payment received — thank you",
          body: `${billing.formatZar(after.amount)} for ` +
            `${after.description} (${after.reference}).`,
          entityType: "invoice",
          entityId: event.params.invoiceId,
        }], after.clientId);
      }
    });

exports.monthlyInvoices = onSchedule({
  schedule: "0 6 1 * *",
  timeZone: TIME_ZONE,
  timeoutSeconds: 540,
  memory: "512MiB",
}, async () => {
  await store.runMonthlyInvoices(new Date());
});

exports.dailyBillingSweep = onSchedule({
  schedule: "0 7 * * *",
  timeZone: TIME_ZONE,
}, async () => {
  await store.runBillingSweep(new Date());
});

// ------------------------------------------------------------------ QR

exports.weeklyUnlinkedQrSweep = onSchedule({
  schedule: "0 7 * * 1",
  timeZone: TIME_ZONE,
}, async () => {
  const cutoff = Date.now() - QR_UNLINKED_DAYS * 24 * 60 * 60 * 1000;
  const snap = await db.collection(COL.qrCodes)
      .where("isLinked", "==", false)
      .get();
  const byTenant = new Map();
  for (const doc of snap.docs) {
    const createdAt = doc.get("createdAt");
    if (!createdAt || createdAt.toMillis() > cutoff) continue;
    const tenantId = doc.get("tenantId");
    byTenant.set(tenantId, (byTenant.get(tenantId) || 0) + 1);
  }

  const week = billing.billingPeriod(new Date()).key +
    `-${new Date().getUTCDate()}`;
  for (const [tenantId, count] of byTenant) {
    logger.info("Unlinked QR codes", { tenantId, count });
    await createOnce(
        db.collection(COL.notifications).doc(`qr-unlinked-${tenantId}-${week}`),
        notificationData(tenantId, {
          type: NOTIFY.qrUnlinkedAlert,
          title: `${count} QR label${count === 1 ? "" : "s"} unused for ` +
            `${QR_UNLINKED_DAYS}+ days`,
          body: "Printed labels that were never attached to a unit. " +
            "Use them up or reprint in QR Management.",
          entityType: "qr",
        }, null));
  }
});

// -------------------------------------------------------------- invites

exports.inviteDriver = onCall((request) => invites.inviteDriver(request));
exports.resendInvite = onCall((request) => invites.resendInvite(request));
