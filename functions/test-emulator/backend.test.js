/**
 * End-to-end checks against the Firestore + Functions emulators:
 * the real triggers in index.js and the real firestore.rules.
 *
 *   npm run test:emulator     (from functions/)
 *
 * Runs under a demo- project id, so nothing reaches a live project.
 */
const test = require("node:test");
const assert = require("node:assert/strict");
const { readFileSync } = require("node:fs");
const { resolve } = require("node:path");
const {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} = require("@firebase/rules-unit-testing");
const {
  doc, getDoc, getDocs, setDoc, updateDoc, addDoc, collection,
  serverTimestamp,
} = require("firebase/firestore");

const PROJECT = process.env.GCLOUD_PROJECT || "demo-strongbox";
const TENANT = "strongbox-default";

let env;

test.before(async () => {
  env = await initializeTestEnvironment({
    projectId: PROJECT,
    firestore: {
      rules: readFileSync(resolve(__dirname, "../../firestore.rules"), "utf8"),
    },
  });
});
test.after(() => env && env.cleanup());

/** Seeds docs bypassing rules (and triggering functions like real writes). */
async function seed(fn) {
  await env.withSecurityRulesDisabled((ctx) => fn(ctx.firestore()));
}

/** Reads bypassing rules. */
async function read(fn) {
  let out;
  await env.withSecurityRulesDisabled(async (ctx) => {
    out = await fn(ctx.firestore());
  });
  return out;
}

/** Polls until [fn] returns something truthy — triggers are async. */
async function eventually(fn, timeoutMs = 20000) {
  const end = Date.now() + timeoutMs;
  for (;;) {
    const value = await fn();
    if (value) return value;
    if (Date.now() > end) throw new Error("timed out waiting for trigger");
    await new Promise((r) => setTimeout(r, 250));
  }
}

const users = {
  admin: { tenantId: TENANT, role: "admin", name: "Ada", email: "ada@x.co",
    isDeleted: false, fcmTokens: [] },
  driver: { tenantId: TENANT, role: "driver", name: "Dee", email: "dee@x.co",
    isDeleted: false, fcmTokens: [] },
  client: { tenantId: TENANT, role: "client", name: "Cee", email: "cee@x.co",
    clientId: "client-1", isDeleted: false, fcmTokens: [] },
  other: { tenantId: TENANT, role: "client", name: "Oz", email: "oz@x.co",
    clientId: "client-2", isDeleted: false, fcmTokens: [] },
};

/** Wipes the emulator, waiting out triggers still holding a transaction. */
async function clearAll() {
  for (let attempt = 0; ; attempt++) {
    try {
      return await env.clearFirestore();
    } catch (error) {
      if (attempt >= 10 || !/ABORTED|lock timeout/.test(String(error))) {
        throw error;
      }
      await new Promise((r) => setTimeout(r, 500));
    }
  }
}

test.beforeEach(async () => {
  await clearAll();
  await seed(async (db) => {
    for (const [uid, data] of Object.entries(users)) {
      await setDoc(doc(db, "users", uid), data);
    }
    await setDoc(doc(db, "clients", "client-1"), {
      tenantId: TENANT, primaryUserId: "client", displayName: "Cee Client",
      email: "cee@x.co", subscriptionStatus: "incomplete", isDeleted: false,
    });
  });
});

// ------------------------------------------------------------- triggers

test("a delivery request flows through to the right people", async () => {
  await seed((db) => setDoc(doc(db, "jobs", "job-1"), {
    tenantId: TENANT, type: "delivery", status: "scheduled",
    clientId: "client-1", driverId: null, storageUnitIds: ["u1", "u2"],
    timeWindow: "morning", isDeleted: false,
  }));

  const adminAlert = await eventually(async () =>
    (await notificationsAll()).find((n) => n.type === "deliveryRequested"));
  assert.equal(adminAlert.userId, null);
  assert.match(adminAlert.body, /Cee Client · 2 items/);
  await eventually(async () =>
    (await notificationsAll()).find((n) => n.id === adminAlert.id &&
      n.route === "/admin/jobs"));

  await seed((db) => updateDoc(doc(db, "jobs", "job-1"),
      { driverId: "driver", status: "assigned" }));
  const assigned = await eventually(async () =>
    (await notificationsAll()).find((n) => n.type === "jobAssigned"));
  assert.equal(assigned.userId, "driver");
  await eventually(async () =>
    (await notificationsAll()).find((n) => n.id === assigned.id &&
      n.route === "/driver/jobs/job-1"));

  await seed((db) => updateDoc(doc(db, "jobs", "job-1"),
      { status: "inProgress" }));
  const started = await eventually(async () =>
    (await notificationsAll()).find((n) => n.type === "jobStarted"));
  assert.equal(started.userId, "client");
  // Clients get this one by email too (default preferences).
  const mail = await eventually(() => mailDoc(`notification-${started.id}`));
  assert.equal(mail.to, "cee@x.co");
  assert.equal(mail.message.subject, "Your delivery is on its way");
  // onMailCreated sends it (test transport) and records the outcome.
  const sent = await eventually(async () => {
    const doc = await mailDoc(`notification-${started.id}`);
    return doc && doc.delivery && doc.delivery;
  });
  assert.equal(sent.state, "SUCCESS");
});

test("settling an invoice updates the account and thanks the client",
    async () => {
      await seed((db) => setDoc(doc(db, "invoices", "client-1_2026-11"), {
        tenantId: TENANT, clientId: "client-1", reference: "INV-202611-CLIENT",
        description: "Storage — November 2026", amount: 490, status: "open",
        dueAt: new Date(Date.now() - 86400000), isDeleted: false, lines: [],
      }));
      await seed((db) => updateDoc(doc(db, "invoices", "client-1_2026-11"),
          { status: "paid", paidBy: "admin" }));

      const thanks = await eventually(async () =>
        (await notificationsAll()).find((n) => n.type === "invoicePaid"));
      assert.equal(thanks.userId, "client");
      assert.match(thanks.body, /R490\.00/);
      const status = await eventually(async () => {
        const s = await clientDoc("client-1");
        return s.subscriptionStatus === "active" && s.subscriptionStatus;
      });
      assert.equal(status, "active");
    });

test("a new client with a login gets a welcome email", async () => {
  await seed((db) => setDoc(doc(db, "clients", "client-9"), {
    tenantId: TENANT, primaryUserId: "u9", displayName: "Nomsa Dube",
    email: "nomsa@x.co", isDeleted: false,
  }));
  const mail = await eventually(() => mailDoc("welcome-client-9"));
  assert.equal(mail.message.subject, "Welcome to StrongBox, Nomsa");
});

// ---------------------------------------------------------------- rules

test("rules: only admins address notifications to people", async () => {
  const client = env.authenticatedContext("client").firestore();
  await assertFails(addDoc(collection(client, "notifications"), {
    tenantId: TENANT, type: "systemAlert", title: "x", body: "y",
    userId: "driver", isRead: false,
  }));
  await assertFails(addDoc(collection(client, "notifications"), {
    tenantId: TENANT, type: "jobAssigned", title: "x", body: "y",
    userId: null, isRead: false,
  }));
  await assertSucceeds(addDoc(collection(client, "notifications"), {
    tenantId: TENANT, type: "systemAlert", title: "Account deletion",
    body: "requested", userId: null, isRead: false,
  }));
  const admin = env.authenticatedContext("admin").firestore();
  await assertSucceeds(addDoc(collection(admin, "notifications"), {
    tenantId: TENANT, type: "directMessage", title: "Gate code",
    body: "4410", userId: "driver", isRead: false,
  }));
});

test("rules: recipients can only mark notifications read", async () => {
  await seed((db) => setDoc(doc(db, "notifications", "n1"), {
    tenantId: TENANT, type: "jobAssigned", title: "t", body: "b",
    userId: "driver", isRead: false,
  }));
  const driver = env.authenticatedContext("driver").firestore();
  await assertSucceeds(updateDoc(doc(driver, "notifications", "n1"),
      { isRead: true, readAt: serverTimestamp() }));
  await assertFails(updateDoc(doc(driver, "notifications", "n1"),
      { title: "changed" }));
  const other = env.authenticatedContext("other").firestore();
  await assertFails(updateDoc(doc(other, "notifications", "n1"),
      { isRead: true }));
});

test("rules: admins settle open invoices, nobody edits amounts", async () => {
  const invoice = {
    tenantId: TENANT, clientId: "client-1", amount: 490, status: "open",
    reference: "INV-1", isDeleted: false,
  };
  await seed((db) => setDoc(doc(db, "invoices", "i1"), invoice));
  const admin = env.authenticatedContext("admin").firestore();
  const client = env.authenticatedContext("client").firestore();

  await assertFails(updateDoc(doc(client, "invoices", "i1"),
      { status: "paid" }));
  await assertFails(updateDoc(doc(admin, "invoices", "i1"),
      { amount: 1 }));
  await assertFails(setDoc(doc(admin, "invoices", "i2"), invoice));
  await assertSucceeds(updateDoc(doc(admin, "invoices", "i1"), {
    status: "paid", paidBy: "admin", paymentNote: "EFT",
    paidAt: serverTimestamp(), updatedAt: serverTimestamp(),
  }));
  // Settled is final.
  await assertFails(updateDoc(doc(admin, "invoices", "i1"),
      { status: "voided" }));
});

test("rules: payment instructions are part of the public tenant doc",
    async () => {
      const admin = env.authenticatedContext("admin").firestore();
      const settings = {
        tenantId: TENANT, name: "StrongBox", contactPhone: "0719090839",
        contactEmail: "hi@x.co", serviceArea: "Cape Town", address: {},
        morning: {}, afternoon: {}, evening: {},
        paymentInstructions: "FNB · Acc 620 · Branch 250655",
        updatedBy: "admin", updatedAt: serverTimestamp(),
      };
      await assertSucceeds(setDoc(doc(admin, "tenants", TENANT), settings));
      await assertFails(setDoc(doc(admin, "tenants", TENANT), {
        ...settings, paymentInstructions: "x".repeat(501),
      }));
    });

// --------------------------------------------------------------- helpers

async function notificationsAll() {
  return read(async (db) => {
    const snap = await getDocs(collection(db, "notifications"));
    return snap.docs.map((d) => ({ id: d.id, ...d.data() }));
  });
}

async function mailDoc(id) {
  return read(async (db) => {
    const snap = await getDoc(doc(db, "mail", id));
    return snap.exists() ? snap.data() : null;
  });
}

async function clientDoc(id) {
  return read(async (db) => {
    return (await getDoc(doc(db, "clients", id))).data();
  });
}

test("rules: only admins read email status; nobody writes it", async () => {
  await seed((db) => setDoc(doc(db, "mail", "invite-x-1"), {
    to: "dee@x.co", message: { subject: "Invite" },
    delivery: { state: "SUCCESS" },
  }));
  const admin = env.authenticatedContext("admin").firestore();
  const driver = env.authenticatedContext("driver").firestore();
  await assertSucceeds(getDoc(doc(admin, "mail", "invite-x-1")));
  await assertFails(getDoc(doc(driver, "mail", "invite-x-1")));
  await assertFails(setDoc(doc(admin, "mail", "m2"),
      { to: "a@b.co", message: { subject: "spoof" } }));
});
