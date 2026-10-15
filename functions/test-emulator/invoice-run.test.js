/**
 * The monthly invoice run and the daily billing sweep against the Firestore
 * emulator, driven directly (schedules don't fire on the emulator).
 *
 *   npm run test:emulator
 */
const test = require("node:test");
const assert = require("node:assert/strict");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, Timestamp } = require("firebase-admin/firestore");
const { createStore } = require("../src/store");

const PROJECT = process.env.GCLOUD_PROJECT || "demo-strongbox";
const TENANT = "strongbox-default";
// 06:00 SAST on 1 November 2026, when the schedule fires.
const RUN_AT = new Date("2026-11-01T04:00:00Z");

const db = getFirestore(initializeApp({ projectId: PROJECT }, "invoice-run"));
const store = createStore(db);

async function clear() {
  for (const name of ["tenants", "clients", "storageUnits", "invoices",
    "notifications", "auditEvents", "users"]) {
    const snap = await db.collection(name).get();
    await Promise.all(snap.docs.map((d) => d.ref.delete()));
  }
}

async function seedClient() {
  await db.doc("clients/client-1").set({
    tenantId: TENANT, primaryUserId: "client-user",
    displayName: "Thandi Nkosi", subscriptionStatus: "incomplete",
    isDeleted: false,
  });
  const unit = (status, fields) => ({
    tenantId: TENANT, clientId: "client-1", status, isDeleted: false,
    monthlyRateZar: 0, label: "", ...fields,
  });
  await db.doc("storageUnits/u1").set(unit("inStorage",
      { qrCodeId: "SBX-0001-A1", priceKey: "small", monthlyRateZar: 195 }));
  await db.doc("storageUnits/u2").set(unit("pendingDelivery",
      { qrCodeId: "SBX-0002-A1", priceKey: "medium" })); // list rate
  await db.doc("storageUnits/u3").set(unit("delivered",
      { qrCodeId: "SBX-0003-A1", monthlyRateZar: 395 })); // returned
  await db.doc("storageUnits/u4").set(unit("inStorage",
      { qrCodeId: "SBX-0004-A1" })); // never sized
}

test.beforeEach(clear);

test("without EFT details nothing is invoiced and admins are told why",
    async () => {
      await seedClient();
      await store.runMonthlyInvoices(RUN_AT);

      assert.equal((await db.collection("invoices").get()).size, 0);
      const held = await db
          .doc(`notifications/invoices-held-${TENANT}-2026-11`).get();
      assert.ok(held.exists);
      assert.equal(held.get("userId"), null);
      assert.match(held.get("title"), /November 2026 invoices not issued/);
    });

test("issues one invoice per client per month, at recorded rates",
    async () => {
      await db.doc(`tenants/${TENANT}`).set({
        tenantId: TENANT, paymentInstructions: "FNB · Acc 620 · 250655",
      });
      await seedClient();

      await store.runMonthlyInvoices(RUN_AT);
      await store.runMonthlyInvoices(RUN_AT); // a retry must not double-bill

      const invoices = await db.collection("invoices").get();
      assert.equal(invoices.size, 1);
      const invoice = invoices.docs[0];
      assert.equal(invoice.id, "client-1_2026-11");
      // u1 at its recorded R195 + u2 at the default medium list price.
      const medium = require("../src/default-rates.g.json").monthlyZar.medium;
      assert.equal(invoice.get("amount"), 195 + medium);
      assert.deepEqual(invoice.get("lines").map((l) => l.unitId), ["u1", "u2"]);
      assert.equal(invoice.get("unpricedUnitCount"), 1);
      assert.equal(invoice.get("reference"), "INV-202611-CLIENT");
      assert.equal(invoice.get("status"), "open");

      const notes = (await db.collection("notifications").get()).docs
          .map((d) => d.data());
      const toClient = notes.filter((n) => n.userId === "client-user");
      assert.equal(toClient.length, 1);
      assert.equal(toClient[0].type, "invoiceReady");
      assert.match(toClient[0].body, /due 8 Nov.*INV-202611-CLIENT/);
      const summary = notes.find((n) => n.userId === null);
      assert.match(summary.body, /1 clients .*1 unit had no size/);

      const client = await db.doc("clients/client-1").get();
      assert.equal(client.get("subscriptionStatus"), "active");
    });

test("an overdue invoice makes the account past due until settled",
    async () => {
      await seedClient();
      await db.doc("invoices/client-1_2026-10").set({
        tenantId: TENANT, clientId: "client-1", status: "open", amount: 195,
        dueAt: Timestamp.fromDate(new Date("2026-10-07T22:00:00Z")),
        isDeleted: false,
      });

      await store.runBillingSweep(new Date("2026-10-10T05:00:00Z"));
      assert.equal(
          (await db.doc("clients/client-1").get()).get("subscriptionStatus"),
          "pastDue");

      await db.doc("invoices/client-1_2026-10").update({ status: "paid" });
      await store.runBillingSweep(new Date("2026-10-11T05:00:00Z"));
      assert.equal(
          (await db.doc("clients/client-1").get()).get("subscriptionStatus"),
          "active");
      // Each change is audited exactly once, even though the invoice
      // trigger and the sweep both reacted to the payment.
      const changes = (await db.collection("auditEvents").get()).docs
          .map((d) => `${d.get("metadata").from}→${d.get("metadata").to}`)
          .sort();
      assert.deepEqual(changes, ["incomplete→pastDue", "pastDue→active"]);
    });
