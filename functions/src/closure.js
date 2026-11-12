/**
 * Account closure: a client's right to have their personal information
 * deleted (POPIA s24), balanced against the records the business must keep.
 *
 *   request  The client (in Account settings) or an admin (on the client's
 *            page, e.g. after an email) asks to close the account. It closes
 *            CLOSURE_GRACE_DAYS later. The client can still sign in until
 *            then: to get their items back, pay, or cancel.
 *   close    The daily sweep (or an admin's "Close now") closes it once
 *            nothing blocks it (closureBlockers). The login is deleted and
 *            contact details, addresses, notifications and emails are
 *            cleared. The client record is archived (isDeleted).
 *   keep     Admin-only for RETAIN_YEARS after closing: name, email,
 *            invoices, order history, unit records, photos and signatures.
 *            These are needed for tax records and for claims about stored
 *            items (see the website's privacy policy).
 *   purge    After that, the sweep removes the name, email, photos,
 *            signatures and descriptions. Invoices stay: they carry only the
 *            account number. Audit events are append-only and hold ids only.
 *
 * Every field this touches is listed in the *Patch functions below, which
 * are pure and tested.
 */
const { FieldValue, Timestamp } = require("firebase-admin/firestore");
const { HttpsError } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

const {
  COL,
  NOTIFY,
  AUDIT,
  SYSTEM_ACTOR,
  BILLABLE_STATUSES,
  TIME_ZONE,
  APP_URL,
} = require("./constants");
const { clientRef } = require("./references");
const { renderEmail } = require("./messages");

/** Days between asking to close an account and it closing. */
const CLOSURE_GRACE_DAYS = 30;
/** Years closed-account records are kept before they are purged. */
const RETAIN_YEARS = 5;

const DAY_MS = 24 * 60 * 60 * 1000;
/** Job statuses still to happen or happening (JobStatusX.isOpen). */
const OPEN_JOB_STATUSES = new Set(["pendingConfirmation", "scheduled",
  "assigned", "inProgress", "collected"]);
/** Job statuses whose once-off charges are due (billing.js). */
const CHARGEABLE_JOB_STATUSES = new Set(["collected", "completed"]);
/** Firestore `in` queries take at most 30 values. */
const IN_LIMIT = 30;

// ------------------------------------------------------------ pure rules

/**
 * What stops an account closing — mirrors closureBlockers() in
 * app/lib/core/utils/account_closure.dart. Nobody's details are erased
 * while we still hold their things, owe them a visit, or are owed money.
 * @param {{units: object[], jobs: object[], invoices: object[]}} records
 * @return {{kind: string, count: number, zar: number}[]}
 */
function closureBlockers({ units = [], jobs = [], invoices = [] }) {
  const live = (doc) => !doc.isDeleted;
  const blockers = [];
  const held = units.filter((u) => live(u) && BILLABLE_STATUSES.has(u.status));
  if (held.length > 0) {
    blockers.push({ kind: "itemsHeld", count: held.length, zar: 0 });
  }
  const open = jobs.filter((j) => live(j) && OPEN_JOB_STATUSES.has(j.status));
  if (open.length > 0) {
    blockers.push({ kind: "openOrders", count: open.length, zar: 0 });
  }
  const unpaid = invoices.filter((i) => live(i) && i.status === "open");
  if (unpaid.length > 0) {
    blockers.push({ kind: "unpaidInvoices", count: unpaid.length,
      zar: Math.round(unpaid.reduce((sum, i) => sum + (i.amount || 0), 0)) });
  }
  const unbilled = jobs.filter((j) => live(j) &&
    CHARGEABLE_JOB_STATUSES.has(j.status) &&
    (j.onceOffZar || 0) > 0 && !j.invoicedIn);
  if (unbilled.length > 0) {
    blockers.push({ kind: "unbilledCharges", count: unbilled.length,
      zar: unbilled.reduce((sum, j) => sum + j.onceOffZar, 0) });
  }
  return blockers;
}

/** One line per blocker, for admin alerts and error messages. */
function describeBlockers(blockers) {
  const plural = (n, word) => `${n} ${word}${n === 1 ? "" : "s"}`;
  return blockers.map((b) => {
    switch (b.kind) {
      case "itemsHeld":
        return `${plural(b.count, "item")} still in storage`;
      case "openOrders":
        return `${plural(b.count, "order")} still open`;
      case "unpaidInvoices":
        return `${plural(b.count, "unpaid invoice")} (R${b.zar})`;
      case "unbilledCharges":
        return `R${b.zar} in charges not invoiced yet`;
      default:
        return b.kind;
    }
  }).join("; ");
}

/** When an account asked to close at [now] closes. */
function closureDate(now) {
  return new Date(now.getTime() + CLOSURE_GRACE_DAYS * DAY_MS);
}

/** When a closed account's records are purged. */
function retainUntil(closedAt) {
  const until = new Date(closedAt.getTime());
  until.setUTCFullYear(until.getUTCFullYear() + RETAIN_YEARS);
  return until;
}

/** "12 December 2026" in SAST. */
function longDate(date) {
  return new Intl.DateTimeFormat("en-ZA", {
    day: "numeric", month: "long", year: "numeric", timeZone: TIME_ZONE,
  }).format(date);
}

/** Client record at closing: contact details go; name and email stay. */
function closedClientPatch() {
  return {
    phone: "",
    address: { line1: "", line2: null, city: "", state: null, postCode: "",
      country: "ZA", lat: null, lng: null },
    notes: null,
    memberIds: [],
    stripeCustomerId: null,
    subscriptionId: null,
    isActive: false,
    isDeleted: true,
  };
}

/** A login's profile at closing: nothing left to identify them. */
function closedUserPatch() {
  return {
    name: "Closed account",
    email: "",
    phone: null,
    avatarUrl: null,
    fcmTokens: [],
    notificationPrefs: FieldValue.delete(),
    isActive: false,
    isDeleted: true,
  };
}

/**
 * An order at closing: the street address and instructions go; the suburb
 * stays for area reports. Dates, items, charges, the driver, photos and the
 * signature stay as the service record.
 */
function closedJobPatch(job) {
  const address = job.address || {};
  return {
    address: { line1: "", line2: null, city: address.city || "", state: null,
      postCode: "", country: address.country || "ZA", lat: null, lng: null },
    accessNotes: null,
    notes: null,
  };
}

/** A notification addressed to, or about, the closed account. */
function scrubbedNotificationPatch() {
  return { title: "Closed account", body: "", isDeleted: true };
}

/** A queued email to the closed account: who and what are removed. */
function scrubbedMailPatch() {
  return { to: "", message: FieldValue.delete() };
}

/** Client record at purge: only the account number is left. */
function purgedClientPatch(clientId) {
  return { displayName: `Closed account ${clientRef(clientId)}`, email: "" };
}

/** A unit at purge: its QR code, size, dates and condition stay. */
function purgedUnitPatch(unit) {
  return {
    label: unit.qrCodeId || "Unit",
    description: null,
    tags: [],
    photoIds: [],
  };
}

/** An item at purge. */
function purgedItemPatch(item) {
  return { label: item.qrCodeId || "Item", description: null, tags: [],
    photoIds: [] };
}

/** An order at purge: who signed, the signature and photos go. */
function purgedJobPatch() {
  return {
    recipientName: null,
    clientSignatureUrl: null,
    photoIds: [],
    driverNotes: null,
  };
}

// ------------------------------------------------------------- Firestore

/**
 * @param {FirebaseFirestore.Firestore} db
 * @param {import("firebase-admin/auth").Auth} auth
 * @param {{deleteFiles: function({prefix: string}): Promise}} bucket
 * @param {ReturnType<import("./store").createStore>} store
 */
function createClosure(db, auth, bucket, store) {
  const { notificationData, createOnce } = store;
  const serverNow = () => FieldValue.serverTimestamp();

  function auditEvent(tenantId, actor, action, clientId, metadata = {}) {
    return {
      tenantId,
      actorId: actor.uid,
      actorRole: actor.role,
      action,
      entityType: "client",
      entityId: clientId,
      metadata,
      timestamp: serverNow(),
    };
  }

  /** The signed-in caller's profile, or a permission error. */
  async function caller(request) {
    const uid = request.auth && request.auth.uid;
    if (!uid) throw new HttpsError("unauthenticated", "Sign in first.");
    const me = await db.collection(COL.users).doc(uid).get();
    if (!me.exists || me.get("isDeleted")) {
      throw new HttpsError("permission-denied", "This account is closed.");
    }
    return { uid, role: me.get("role"), tenantId: me.get("tenantId"),
      clientId: me.get("clientId") || null };
  }

  /**
   * The client record [me] may act on: their own, or any in the tenant
   * for an admin.
   */
  async function targetClient(me, data) {
    const requested = String((data && data.clientId) || "");
    let clientId;
    if (me.role === "admin") {
      clientId = requested;
      if (!clientId) {
        throw new HttpsError("invalid-argument", "Choose a client.");
      }
    } else if (me.role === "client") {
      clientId = me.clientId;
      if (!clientId || (requested && requested !== clientId)) {
        throw new HttpsError("permission-denied",
            "You can only close your own account.");
      }
    } else {
      throw new HttpsError("permission-denied",
          "Only clients and admins can close accounts.");
    }
    const snap = await db.collection(COL.clients).doc(clientId).get();
    if (!snap.exists || snap.get("tenantId") !== me.tenantId) {
      throw new HttpsError("not-found", "Client not found.");
    }
    return snap;
  }

  /** The client's units, orders and invoices — for blockers. */
  async function clientRecords(clientId) {
    const byClient = (name) => db.collection(name)
        .where("clientId", "==", clientId).get();
    const [units, jobs, invoices] = await Promise.all([
      byClient(COL.storageUnits), byClient(COL.jobs), byClient(COL.invoices),
    ]);
    const data = (snap) => snap.docs.map((d) => ({ id: d.id, ...d.data() }));
    return { units, jobs, invoices,
      blockers: closureBlockers({ units: data(units), jobs: data(jobs),
        invoices: data(invoices) }) };
  }

  /** Queues an email to [to]. */
  async function email(id, to, tenantId, content) {
    if (!to) return;
    await createOnce(db.collection(COL.mail).doc(id), {
      to,
      message: renderEmail(content),
      tenantId,
      createdAt: serverNow(),
    });
  }

  /**
   * Starts closing an account. data: { clientId?, reason? } →
   * { scheduledFor } (ISO). Asking again while pending changes nothing.
   */
  async function requestAccountClosure(request) {
    const me = await caller(request);
    const snap = await targetClient(me, request.data || {});
    const client = snap.data();
    if (client.isDeleted) {
      throw new HttpsError("failed-precondition",
          "This account is already closed.");
    }
    const pending = client.closure && client.closure.status === "requested" ?
      client.closure : null;
    if (pending) {
      return { scheduledFor: pending.scheduledFor.toDate().toISOString() };
    }

    const now = new Date();
    const due = closureDate(now);
    const reason = String((request.data && request.data.reason) || "")
        .trim().slice(0, 500) || null;
    const name = client.displayName || clientRef(snap.id);
    const byAdmin = me.role === "admin";

    const batch = db.batch();
    batch.update(snap.ref, {
      closure: {
        status: "requested",
        requestedAt: Timestamp.fromDate(now),
        scheduledFor: Timestamp.fromDate(due),
        requestedBy: me.uid,
        requestedByRole: me.role,
        reason,
      },
      updatedAt: serverNow(),
    });
    batch.create(db.collection(COL.auditEvents).doc(), auditEvent(
        client.tenantId, me, AUDIT.accountClosureRequested, snap.id,
        { scheduledFor: due.toISOString(), reason }));
    batch.create(db.collection(COL.notifications).doc(), notificationData(
        client.tenantId, {
          type: NOTIFY.systemAlert,
          title: byAdmin ? `Closing ${name}'s account` :
            `${name} asked to close their account`,
          body: `It closes on ${longDate(due)} once their items are back ` +
            "with them and invoices are settled. Their page shows what's " +
            "left to do.",
          entityType: "client",
          entityId: snap.id,
        }, null));
    if (client.primaryUserId) {
      batch.create(db.collection(COL.notifications).doc(), notificationData(
          client.tenantId, {
            type: NOTIFY.systemAlert,
            title: "Your account is closing",
            body: `It closes on ${longDate(due)}. Before then, ask for your ` +
              "items back and settle any open invoices. Changed your mind? " +
              "Cancel in Account settings.",
            entityType: "account",
            entityId: snap.id,
          }, client.primaryUserId));
    }
    await batch.commit();

    await email(`closure-requested-${snap.id}-${now.getTime()}`,
        client.email, client.tenantId, {
          heading: "We've received your request to close your account",
          paragraphs: [
            `Your StrongBox account will close on ${longDate(due)}.`,
            "Before then, ask for any stored items back and settle open " +
              "invoices. We can only close the account once both are done.",
            "When it closes we delete your sign-in, phone number, " +
              "addresses and messages. Invoices, order history, photos " +
              `and signatures are kept for ${RETAIN_YEARS} years for tax ` +
              "records and claims, then deleted.",
            "Changed your mind? Cancel any time before then in Account " +
              "settings.",
          ],
          cta: "Manage your account",
          url: `${APP_URL}/client/account`,
        });
    logger.info("Account closure requested", { clientId: snap.id,
      by: me.uid, role: me.role });
    return { scheduledFor: due.toISOString() };
  }

  /** Stops a pending closure. data: { clientId? } → {}. */
  async function cancelAccountClosure(request) {
    const me = await caller(request);
    const snap = await targetClient(me, request.data || {});
    const client = snap.data();
    if (!client.closure || client.closure.status !== "requested") {
      throw new HttpsError("failed-precondition",
          "This account isn't closing.");
    }
    const name = client.displayName || clientRef(snap.id);
    const batch = db.batch();
    batch.update(snap.ref, {
      closure: FieldValue.delete(),
      updatedAt: serverNow(),
    });
    batch.create(db.collection(COL.auditEvents).doc(), auditEvent(
        client.tenantId, me, AUDIT.accountClosureCancelled, snap.id));
    batch.create(db.collection(COL.notifications).doc(), notificationData(
        client.tenantId, {
          type: NOTIFY.systemAlert,
          title: `${name}'s account stays open`,
          body: me.role === "admin" ? "An admin cancelled the closure." :
            "They cancelled their request to close it.",
          entityType: "client",
          entityId: snap.id,
        }, null));
    if (client.primaryUserId) {
      batch.create(db.collection(COL.notifications).doc(), notificationData(
          client.tenantId, {
            type: NOTIFY.systemAlert,
            title: "Your account stays open",
            body: "Your request to close it has been cancelled.",
            entityType: "account",
            entityId: snap.id,
          }, client.primaryUserId));
    }
    await batch.commit();
    logger.info("Account closure cancelled", { clientId: snap.id,
      by: me.uid });
    return {};
  }

  /**
   * Admin: closes a pending account now instead of waiting for its date
   * (e.g. the client asked not to wait). data: { clientId } → {}.
   */
  async function closeAccountNow(request) {
    const me = await caller(request);
    if (me.role !== "admin") {
      throw new HttpsError("permission-denied",
          "Only admins can close an account early.");
    }
    const snap = await targetClient(me, request.data || {});
    const closure = snap.get("closure");
    if (!closure || closure.status !== "requested") {
      throw new HttpsError("failed-precondition",
          "Start the closure first.");
    }
    const result = await closeAccount(snap, { uid: me.uid, role: "admin" });
    if (!result.closed) {
      throw new HttpsError("failed-precondition",
          `Not yet: ${describeBlockers(result.blockers)}.`);
    }
    return {};
  }

  /** Every doc in [name] whose [field] is one of [values]. */
  async function whereIn(name, field, values) {
    const docs = [];
    for (let i = 0; i < values.length; i += IN_LIMIT) {
      const snap = await db.collection(name)
          .where(field, "in", values.slice(i, i + IN_LIMIT)).get();
      docs.push(...snap.docs);
    }
    return docs;
  }

  /** Queued emails to any of [emails]. */
  async function mailTo(emails) {
    return whereIn(COL.mail, "to", [...emails]);
  }

  /**
   * Closes [snap]'s account unless something blocks it. Safe to re-run:
   * a failure part-way leaves the closure `requested` and tomorrow's
   * sweep finishes it.
   * @return {Promise<{closed: boolean, blockers: object[]}>}
   */
  async function closeAccount(snap, actor) {
    const clientId = snap.id;
    const client = snap.data();
    const records = await clientRecords(clientId);
    if (records.blockers.length > 0) {
      return { closed: false, blockers: records.blockers };
    }

    const users = await db.collection(COL.users)
        .where("clientId", "==", clientId).get();
    const uids = new Set(users.docs.map((d) => d.id));
    if (client.primaryUserId) uids.add(client.primaryUserId);
    for (const uid of client.memberIds || []) uids.add(uid);
    const emails = new Set([client.email, ...users.docs.map(
        (d) => d.get("email"))].filter(Boolean));

    // 1. Sign-in goes first, so nothing below can be undone from the app.
    for (const uid of uids) {
      try {
        await auth.deleteUser(uid);
      } catch (error) {
        if (error.code !== "auth/user-not-found") throw error;
      }
    }

    // 2. Personal details on the client's other records.
    const writer = db.bulkWriter();
    for (const uid of uids) {
      const ref = db.collection(COL.users).doc(uid);
      if (!(await ref.get()).exists) continue;
      writer.update(ref, { ...closedUserPatch(), deletedAt: serverNow(),
        updatedAt: serverNow() });
      const inbox = await db.collection(COL.notifications)
          .where("userId", "==", uid).get();
      for (const doc of inbox.docs) {
        writer.update(doc.ref, scrubbedNotificationPatch());
      }
    }
    for (const doc of records.jobs.docs) {
      writer.update(doc.ref, { ...closedJobPatch(doc.data()),
        updatedAt: serverNow() });
    }
    // Admin alerts about the client or their orders name them.
    const about = await whereIn(COL.notifications, "entityId",
        [clientId, ...records.jobs.docs.map((d) => d.id)]);
    for (const doc of about) {
      if (!doc.get("userId")) writer.update(doc.ref,
          scrubbedNotificationPatch());
    }
    for (const doc of await mailTo(emails)) {
      writer.update(doc.ref, scrubbedMailPatch());
    }
    await writer.close();

    // 3. Archive the record, with its audit event, in one write.
    const closedAt = new Date();
    const until = retainUntil(closedAt);
    const batch = db.batch();
    batch.update(snap.ref, {
      ...closedClientPatch(),
      "closure.status": "closed",
      "closure.closedAt": Timestamp.fromDate(closedAt),
      "closure.closedBy": actor.uid,
      "closure.retainUntil": Timestamp.fromDate(until),
      deletedAt: serverNow(),
      updatedAt: serverNow(),
    });
    batch.create(db.collection(COL.auditEvents).doc(), auditEvent(
        client.tenantId, actor, AUDIT.accountClosed, clientId, {
          logins: uids.size,
          orders: records.jobs.size,
          units: records.units.size,
          invoices: records.invoices.size,
          retainUntil: until.toISOString(),
        }));
    batch.create(db.collection(COL.notifications).doc(), notificationData(
        client.tenantId, {
          type: NOTIFY.systemAlert,
          title: `Account ${clientRef(clientId)} closed`,
          body: "Sign-in and contact details removed. Invoices and order " +
            `records are kept until ${longDate(until)}, then deleted.`,
          entityType: "client",
          entityId: clientId,
        }, null));
    await batch.commit();

    // 4. Confirmation to the address kept on record (purged with it).
    await email(`closure-closed-${clientId}`, client.email, client.tenantId, {
      heading: "Your StrongBox account is closed",
      paragraphs: [
        "We've deleted your sign-in, phone number, addresses and messages.",
        "Invoices, order history, photos and signatures are kept until " +
          `${longDate(until)} for tax records and claims, then deleted. ` +
          "Only our admin team can see them.",
        "Thank you for storing with us. You're welcome back any time.",
      ],
      cta: "Visit StrongBox",
      url: "https://strongbox.co.za",
    });
    logger.info("Account closed", { clientId, by: actor.uid });
    return { closed: true, blockers: [] };
  }

  /**
   * Removes what a closed account kept for the retention period. Invoices
   * stay (account number only); audit events are never edited.
   */
  async function purgeRecords(snap) {
    const clientId = snap.id;
    const client = snap.data();
    const byClient = (name) => db.collection(name)
        .where("clientId", "==", clientId).get();
    const [units, items, jobs] = await Promise.all([
      byClient(COL.storageUnits), byClient(COL.items), byClient(COL.jobs),
    ]);

    const photoIds = new Set();
    const writer = db.bulkWriter();
    for (const doc of units.docs) {
      for (const id of doc.get("photoIds") || []) photoIds.add(id);
      writer.update(doc.ref, { ...purgedUnitPatch(doc.data()),
        updatedAt: serverNow() });
    }
    for (const doc of items.docs) {
      for (const id of doc.get("photoIds") || []) photoIds.add(id);
      writer.update(doc.ref, { ...purgedItemPatch(doc.data()),
        updatedAt: serverNow() });
    }
    for (const doc of jobs.docs) {
      for (const id of doc.get("photoIds") || []) photoIds.add(id);
      writer.update(doc.ref, { ...purgedJobPatch(), updatedAt: serverNow() });
    }
    const photoRefs = [...photoIds].map((id) =>
      db.collection(COL.photos).doc(id));
    for (let i = 0; i < photoRefs.length; i += 100) {
      const docs = await db.getAll(...photoRefs.slice(i, i + 100));
      for (const doc of docs) {
        if (!doc.exists) continue;
        writer.update(doc.ref, { storageUrl: "", storagePath: "",
          isDeleted: true, deletedAt: serverNow() });
      }
    }
    if (client.email) {
      for (const doc of await mailTo([client.email])) {
        writer.update(doc.ref, scrubbedMailPatch());
      }
    }
    await writer.close();

    const tenant = client.tenantId;
    const prefixes = [
      ...units.docs.map((d) => `${tenant}/storageUnits/${d.id}/`),
      ...items.docs.map((d) => `${tenant}/items/${d.id}/`),
      ...jobs.docs.map((d) => `${tenant}/jobs/${d.id}/`),
    ];
    for (const prefix of prefixes) await bucket.deleteFiles({ prefix });

    const batch = db.batch();
    batch.update(snap.ref, {
      ...purgedClientPatch(clientId),
      "closure.status": "purged",
      "closure.purgedAt": serverNow(),
      updatedAt: serverNow(),
    });
    batch.create(db.collection(COL.auditEvents).doc(), auditEvent(
        tenant, { uid: SYSTEM_ACTOR, role: "admin" },
        AUDIT.accountRecordsPurged, clientId,
        { units: units.size, orders: jobs.size, photos: photoIds.size }));
    await batch.commit();
    logger.info("Closed account records purged", { clientId });
  }

  /**
   * Daily: closes accounts whose date has come (alerting admins once when
   * something blocks one), and purges records past their retention date.
   */
  async function runClosureSweep(now) {
    const pending = await db.collection(COL.clients)
        .where("closure.status", "==", "requested").get();
    for (const snap of pending.docs) {
      const due = snap.get("closure.scheduledFor");
      if (!due || due.toDate() > now) continue;
      try {
        const result = await closeAccount(snap,
            { uid: SYSTEM_ACTOR, role: "admin" });
        if (result.closed) continue;
        const name = snap.get("displayName") || clientRef(snap.id);
        await createOnce(db.collection(COL.notifications).doc(
            `closure-blocked-${snap.id}-${due.toMillis()}`),
        notificationData(snap.get("tenantId"), {
          type: NOTIFY.systemAlert,
          title: `Can't close ${name}'s account yet`,
          body: `${describeBlockers(result.blockers)}. It closes ` +
              "automatically once these are cleared.",
          entityType: "client",
          entityId: snap.id,
        }, null));
      } catch (error) {
        logger.error("Account closure failed", { clientId: snap.id, error });
      }
    }

    const closed = await db.collection(COL.clients)
        .where("closure.status", "==", "closed").get();
    for (const snap of closed.docs) {
      const until = snap.get("closure.retainUntil");
      if (!until || until.toDate() > now) continue;
      try {
        await purgeRecords(snap);
      } catch (error) {
        logger.error("Records purge failed", { clientId: snap.id, error });
      }
    }
  }

  return {
    requestAccountClosure,
    cancelAccountClosure,
    closeAccountNow,
    closeAccount,
    purgeRecords,
    runClosureSweep,
  };
}

module.exports = {
  CLOSURE_GRACE_DAYS,
  RETAIN_YEARS,
  closureBlockers,
  describeBlockers,
  closureDate,
  retainUntil,
  longDate,
  closedClientPatch,
  closedUserPatch,
  closedJobPatch,
  purgedClientPatch,
  purgedUnitPatch,
  purgedItemPatch,
  purgedJobPatch,
  createClosure,
};
