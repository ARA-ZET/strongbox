/**
 * Account closure against the Auth + Firestore emulators: request → blocked
 * → closed (login deleted, details cleared, records kept) → purged, plus
 * the rules that keep clients away from their closure fields.
 *
 *   npm run test:emulator
 */
const test = require("node:test");
const assert = require("node:assert/strict");
const { readFileSync } = require("node:fs");
const { resolve } = require("node:path");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, Timestamp } = require("firebase-admin/firestore");
const { getAuth } = require("firebase-admin/auth");
const {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} = require("@firebase/rules-unit-testing");
const { doc, getDoc, updateDoc } = require("firebase/firestore");
const { createStore } = require("../src/store");
const { createClosure } = require("../src/closure");
const { clientRef } = require("../src/references");

const PROJECT = process.env.GCLOUD_PROJECT || "demo-strongbox";
const TENANT = "strongbox-default";
const DAY_MS = 24 * 60 * 60 * 1000;

const app = initializeApp({ projectId: PROJECT }, "closure");
const db = getFirestore(app);
const auth = getAuth(app);
const deleted = [];
const bucket = { deleteFiles: async ({ prefix }) => deleted.push(prefix) };
const closure = createClosure(db, auth, bucket, createStore(db));

const asUser = (uid, data) => ({ auth: { uid }, data });

async function rejectsWith(promise, code, pattern) {
  await assert.rejects(promise, (error) => {
    assert.equal(error.code, code);
    if (pattern) assert.match(error.message, pattern);
    return true;
  });
}

const get = async (path) => (await db.doc(path).get()).data();

async function clearAll() {
  const { users } = await auth.listUsers();
  await Promise.all(users.map((u) => auth.deleteUser(u.uid)));
  for (const name of ["users", "clients", "storageUnits", "jobs", "invoices",
    "notifications", "mail", "auditEvents", "photos", "items"]) {
    const snap = await db.collection(name).get();
    await Promise.all(snap.docs.map((d) => d.ref.delete()));
  }
  deleted.length = 0;
}

test.beforeEach(async () => {
  await clearAll();
  await auth.createUser({ uid: "cee", email: "cee@x.co" });
  await db.doc("users/admin-1").set({ tenantId: TENANT, role: "admin",
    name: "Ada", email: "ada@x.co", isDeleted: false });
  await db.doc("users/cee").set({ tenantId: TENANT, role: "client",
    name: "Cee Client", email: "cee@x.co", phone: "071 000 0000",
    clientId: "client-1", fcmTokens: ["tok"], isDeleted: false });
  await db.doc("users/driver-1").set({ tenantId: TENANT, role: "driver",
    email: "dee@x.co", isDeleted: false });
  await db.doc("clients/client-1").set({ tenantId: TENANT,
    primaryUserId: "cee", displayName: "Cee Client", email: "cee@x.co",
    phone: "071 000 0000", notes: "Prefers mornings",
    address: { line1: "3 Kloof Rd", city: "Gardens", postCode: "8001" },
    subscriptionStatus: "active", isDeleted: false });
  await db.doc("storageUnits/u1").set({ tenantId: TENANT,
    clientId: "client-1", qrCodeId: "SBX-1111-A1", label: "Letters",
    description: "Grandma's letters", status: "inStorage",
    photoIds: ["p1"], isDeleted: false });
  await db.doc("photos/p1").set({ tenantId: TENANT,
    storagePath: `${TENANT}/storageUnits/u1/exterior/a.jpg`,
    storageUrl: "https://x/a.jpg", isDeleted: false });
  await db.doc("jobs/j1").set({ tenantId: TENANT, clientId: "client-1",
    type: "pickup", status: "completed", onceOffZar: 300,
    invoicedIn: "client-1_2026-10", recipientName: "Cee Client",
    clientSignatureUrl: "https://x/sig.png", accessNotes: "Gate 1234#",
    address: { line1: "3 Kloof Rd", city: "Gardens" }, isDeleted: false });
  await db.doc("invoices/client-1_2026-10").set({ tenantId: TENANT,
    clientId: "client-1", status: "paid", amount: 449, isDeleted: false });
  await db.doc("notifications/n1").set({ tenantId: TENANT, userId: "cee",
    title: "Your driver is on the way", body: "Thabo is coming",
    isDeleted: false });
  await db.doc("mail/m1").set({ to: "cee@x.co",
    message: { subject: "Welcome, Cee" } });
});

test("only the client or an admin can ask, and only for that client",
    async () => {
      await rejectsWith(closure.requestAccountClosure({ data: {} }),
          "unauthenticated");
      await rejectsWith(closure.requestAccountClosure(asUser("driver-1",
          { clientId: "client-1" })), "permission-denied");
      await rejectsWith(closure.requestAccountClosure(asUser("cee",
          { clientId: "client-2" })), "permission-denied");
      await rejectsWith(closure.closeAccountNow(asUser("cee",
          { clientId: "client-1" })), "permission-denied");
    });

test("a request schedules the closure 30 days out, once", async () => {
  const before = Date.now();
  const { scheduledFor } = await closure.requestAccountClosure(
      asUser("cee", { clientId: "client-1" }));
  const due = new Date(scheduledFor).getTime();
  assert.ok(Math.abs(due - before - 30 * DAY_MS) < 60000);

  const client = await get("clients/client-1");
  assert.equal(client.closure.status, "requested");
  assert.equal(client.closure.requestedByRole, "client");
  assert.equal(client.isDeleted, false); // still open until the date

  // Asking again keeps the original date.
  const again = await closure.requestAccountClosure(
      asUser("cee", { clientId: "client-1" }));
  assert.equal(again.scheduledFor, scheduledFor);
  const audits = await db.collection("auditEvents")
      .where("action", "==", "accountClosureRequested").get();
  assert.equal(audits.size, 1);
  // (onClientCreated may also have queued a welcome email meanwhile.)
  const mail = (await db.collection("mail").where("to", "==", "cee@x.co")
      .get()).docs.filter((d) => d.id.startsWith("closure-requested-"));
  assert.equal(mail.length, 1);
});

test("the client can cancel while it is pending", async () => {
  await closure.requestAccountClosure(asUser("admin-1",
      { clientId: "client-1", reason: "Asked by email" }));
  await closure.cancelAccountClosure(asUser("cee", { clientId: "client-1" }));
  assert.equal((await get("clients/client-1")).closure, undefined);
  await rejectsWith(closure.cancelAccountClosure(asUser("cee",
      { clientId: "client-1" })), "failed-precondition", /isn't closing/);
});

test("items still in storage block the closure; admins hear once",
    async () => {
      await closure.requestAccountClosure(asUser("cee",
          { clientId: "client-1" }));
      await rejectsWith(closure.closeAccountNow(asUser("admin-1",
          { clientId: "client-1" })), "failed-precondition",
      /1 item still in storage/);

      const later = new Date(Date.now() + 31 * DAY_MS);
      await closure.runClosureSweep(later);
      await closure.runClosureSweep(later);
      const client = await get("clients/client-1");
      assert.equal(client.closure.status, "requested");
      assert.equal(client.isDeleted, false);
      const alerts = (await db.collection("notifications").get()).docs
          .filter((d) => d.id.startsWith("closure-blocked-client-1-"));
      assert.equal(alerts.length, 1);
      assert.match(alerts[0].get("body"), /1 item still in storage/);
      await auth.getUser("cee"); // still signed up
    });

test("closing removes the login and personal details, keeps records",
    async () => {
      await db.doc("storageUnits/u1").update({ status: "delivered" });
      await closure.requestAccountClosure(asUser("cee",
          { clientId: "client-1" }));
      await closure.runClosureSweep(new Date(Date.now() + 31 * DAY_MS));

      await rejectsWith(auth.getUser("cee"), "auth/user-not-found");

      const client = await get("clients/client-1");
      assert.equal(client.closure.status, "closed");
      assert.equal(client.isDeleted, true);
      assert.equal(client.phone, "");
      assert.equal(client.address.line1, "");
      assert.equal(client.notes, null);
      assert.equal(client.displayName, "Cee Client"); // kept for records
      assert.equal(client.email, "cee@x.co");
      const keepFor = client.closure.retainUntil.toDate() -
        client.closure.closedAt.toDate();
      assert.ok(keepFor > 4.9 * 365 * DAY_MS);

      const user = await get("users/cee");
      assert.equal(user.isDeleted, true);
      assert.equal(user.email, "");
      assert.deepEqual(user.fcmTokens, []);

      const job = await get("jobs/j1");
      assert.equal(job.address.line1, "");
      assert.equal(job.address.city, "Gardens");
      assert.equal(job.accessNotes, null);
      assert.equal(job.clientSignatureUrl, "https://x/sig.png"); // kept
      assert.equal((await get("storageUnits/u1")).description,
          "Grandma's letters"); // kept
      assert.equal((await get("invoices/client-1_2026-10")).amount, 449);

      const inbox = await get("notifications/n1");
      assert.equal(inbox.body, "");
      assert.equal(inbox.isDeleted, true);
      const oldMail = await get("mail/m1");
      assert.equal(oldMail.to, "");
      assert.equal(oldMail.message, undefined);
      assert.ok(await get("mail/closure-closed-client-1")); // confirmation

      const audit = await db.collection("auditEvents")
          .where("action", "==", "accountClosed").get();
      assert.equal(audit.size, 1);
      assert.equal(deleted.length, 0); // no files removed yet
    });

test("after five years the remaining records are purged", async () => {
  await db.doc("storageUnits/u1").update({ status: "delivered" });
  await closure.requestAccountClosure(asUser("cee",
      { clientId: "client-1" }));
  await closure.runClosureSweep(new Date(Date.now() + 31 * DAY_MS));
  await db.doc("clients/client-1").update({
    "closure.retainUntil": Timestamp.fromMillis(Date.now() - 1000),
  });
  await closure.runClosureSweep(new Date());

  const client = await get("clients/client-1");
  assert.equal(client.closure.status, "purged");
  assert.equal(client.displayName,
      `Closed account ${clientRef("client-1")}`);
  assert.equal(client.email, "");
  const unit = await get("storageUnits/u1");
  assert.equal(unit.label, "SBX-1111-A1");
  assert.equal(unit.description, null);
  assert.deepEqual(unit.photoIds, []);
  const job = await get("jobs/j1");
  assert.equal(job.clientSignatureUrl, null);
  assert.equal(job.recipientName, null);
  assert.equal((await get("photos/p1")).storagePath, "");
  assert.deepEqual(deleted.sort(), [`${TENANT}/jobs/j1/`,
    `${TENANT}/storageUnits/u1/`]);
  assert.equal((await get("invoices/client-1_2026-10")).amount, 449);
});

// ----------------------------------------------------------------- rules

test("clients can't set their own closure, and closed logins read nothing",
    async () => {
      const env = await initializeTestEnvironment({
        projectId: PROJECT,
        firestore: { rules: readFileSync(
            resolve(__dirname, "../../firestore.rules"), "utf8") },
      });
      try {
        const cee = env.authenticatedContext("cee").firestore();
        const ref = doc(cee, "clients/client-1");
        await assertSucceeds(updateDoc(ref, { phone: "072 000 0000" }));
        await assertFails(updateDoc(ref, { closure: { status: "closed" } }));
        await assertFails(updateDoc(ref, { isDeleted: true }));

        await db.doc("users/cee").update({ isDeleted: true });
        await assertFails(getDoc(ref));
        await assertFails(getDoc(doc(cee, "storageUnits/u1")));
      } finally {
        await env.cleanup();
      }
    });
