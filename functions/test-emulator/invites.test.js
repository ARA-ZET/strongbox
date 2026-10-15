/**
 * Driver invites against the Auth + Firestore emulators.
 *
 *   npm run test:emulator
 */
const test = require("node:test");
const assert = require("node:assert/strict");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getAuth } = require("firebase-admin/auth");
const { createInvites } = require("../src/invites");

const PROJECT = process.env.GCLOUD_PROJECT || "demo-strongbox";
const TENANT = "strongbox-default";

const app = initializeApp({ projectId: PROJECT }, "invites");
const db = getFirestore(app);
const auth = getAuth(app);
const invites = createInvites(db, auth);

const asUser = (uid, data) => ({ auth: { uid }, data });

async function rejectsWith(promise, code, pattern) {
  await assert.rejects(promise, (error) => {
    assert.equal(error.code, code);
    if (pattern) assert.match(error.message, pattern);
    return true;
  });
}

test.beforeEach(async () => {
  const { users } = await auth.listUsers();
  await Promise.all(users.map((u) => auth.deleteUser(u.uid)));
  for (const name of ["users", "mail", "auditEvents"]) {
    const snap = await db.collection(name).get();
    await Promise.all(snap.docs.map((d) => d.ref.delete()));
  }
  await db.doc("users/admin-1").set({ tenantId: TENANT, role: "admin",
    email: "ada@x.co", isDeleted: false });
  await db.doc("users/client-1").set({ tenantId: TENANT, role: "client",
    email: "cee@x.co", isDeleted: false });
});

test("only admins can invite", async () => {
  await rejectsWith(invites.inviteDriver({ data: { name: "Dee",
    email: "dee@x.co" } }), "unauthenticated");
  await rejectsWith(invites.inviteDriver(asUser("client-1",
      { name: "Dee", email: "dee@x.co" })), "permission-denied");
});

test("an invite creates the login, the driver profile and the email",
    async () => {
      const { uid, link, mailId } = await invites.inviteDriver(asUser("admin-1",
          { name: "Dee Driver", email: " Dee@X.co ", phone: "071 000 0000" }));

      const user = await auth.getUser(uid);
      assert.equal(user.email, "dee@x.co");
      assert.equal(user.emailVerified, false);
      assert.equal(user.passwordHash, undefined); // no password until set

      const profile = (await db.doc(`users/${uid}`).get()).data();
      assert.equal(profile.role, "driver");
      assert.equal(profile.invited, true);
      assert.equal(profile.tenantId, TENANT);
      assert.equal(profile.phone, "071 000 0000");

      assert.match(link, /mode=resetPassword/);
      const mail = (await db.collection("mail").get()).docs.map((d) => d.data());
      assert.equal(mail.length, 1);
      assert.equal(mail[0].to, "dee@x.co");
      assert.match(mail[0].message.subject, /Dee, you're invited/);
      assert.ok(mail[0].message.html.includes("mode=resetPassword"));
      assert.match(mailId, new RegExp(`^invite-${uid}-`));

      const audit = (await db.collection("auditEvents").get()).docs[0].data();
      assert.equal(audit.action, "userRoleChanged");
      assert.equal(audit.actorId, "admin-1");
    });

test("an email with an account is never taken over", async () => {
  await invites.inviteDriver(asUser("admin-1",
      { name: "Dee", email: "dee@x.co" }));
  await rejectsWith(invites.inviteDriver(asUser("admin-1",
      { name: "Dee", email: "dee@x.co" })), "already-exists",
  /already a driver/);

  const client = await auth.createUser({ email: "cee@x.co" });
  await db.doc(`users/${client.uid}`).set({ tenantId: TENANT,
    role: "client", email: "cee@x.co" });
  await rejectsWith(invites.inviteDriver(asUser("admin-1",
      { name: "Cee", email: "cee@x.co" })), "already-exists",
  /Settings → Team/);
  assert.equal((await db.doc(`users/${client.uid}`).get()).get("role"),
      "client");
});

test("invalid input is rejected before anything is created", async () => {
  await rejectsWith(invites.inviteDriver(asUser("admin-1",
      { name: "", email: "dee@x.co" })), "invalid-argument");
  await rejectsWith(invites.inviteDriver(asUser("admin-1",
      { name: "Dee", email: "not-an-email" })), "invalid-argument");
  assert.equal((await auth.listUsers()).users.length, 0);
});

test("resending works until the driver has signed in", async () => {
  const { uid } = await invites.inviteDriver(asUser("admin-1",
      { name: "Dee", email: "dee@x.co" }));
  const { link } = await invites.resendInvite(asUser("admin-1", { uid }));
  assert.match(link, /mode=resetPassword/);
  assert.equal((await db.collection("mail").get()).size, 2);

  await db.doc(`users/${uid}`).update({ invited: false });
  await rejectsWith(invites.resendInvite(asUser("admin-1", { uid })),
      "failed-precondition");
  await rejectsWith(invites.resendInvite(asUser("admin-1",
      { uid: "client-1" })), "not-found");
});
