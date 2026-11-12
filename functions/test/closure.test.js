const test = require("node:test");
const assert = require("node:assert/strict");
const {
  CLOSURE_GRACE_DAYS,
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
  purgedJobPatch,
} = require("../src/closure");
const { clientRef } = require("../src/references");

test("nothing blocks an account with everything returned and paid", () => {
  assert.deepEqual(closureBlockers({
    units: [{ status: "delivered" }, { status: "pendingPickup" },
      { status: "inStorage", isDeleted: true }],
    jobs: [{ status: "completed", onceOffZar: 300, invoicedIn: "c_2026-11" },
      { status: "cancelled", onceOffZar: 300 }],
    invoices: [{ status: "paid", amount: 99 }, { status: "voided" }],
  }), []);
  assert.deepEqual(closureBlockers({}), []);
});

test("held items, open orders, unpaid invoices and unbilled charges block",
    () => {
      const blockers = closureBlockers({
        units: [{ status: "inStorage" }, { status: "inTransit" },
          { status: "pendingDelivery" }, { status: "delivered" }],
        jobs: [
          { status: "pendingConfirmation" },
          { status: "collected", onceOffZar: 450 },
          { status: "completed", onceOffZar: 200 },
        ],
        invoices: [{ status: "open", amount: 149.5 },
          { status: "open", amount: 100 }],
      });
      assert.deepEqual(blockers, [
        { kind: "itemsHeld", count: 3, zar: 0 },
        { kind: "openOrders", count: 2, zar: 0 },
        { kind: "unpaidInvoices", count: 2, zar: 250 },
        { kind: "unbilledCharges", count: 2, zar: 650 },
      ]);
      assert.equal(describeBlockers(blockers),
          "3 items still in storage; 2 orders still open; " +
          "2 unpaid invoices (R250); R650 in charges not invoiced yet");
    });

test("an account closes 30 days after the request", () => {
  const now = new Date("2026-11-12T08:00:00Z");
  assert.equal(CLOSURE_GRACE_DAYS, 30);
  assert.equal(closureDate(now).toISOString(), "2026-12-12T08:00:00.000Z");
  assert.equal(longDate(closureDate(now)), "12 December 2026");
});

test("records are kept for five years after closing", () => {
  assert.equal(retainUntil(new Date("2026-12-12T08:00:00Z")).toISOString(),
      "2031-12-12T08:00:00.000Z");
});

test("closing clears contact details but keeps name and email", () => {
  const patch = closedClientPatch();
  assert.equal(patch.phone, "");
  assert.equal(patch.address.line1, "");
  assert.equal(patch.address.lat, null);
  assert.equal(patch.notes, null);
  assert.equal(patch.isDeleted, true);
  assert.equal(patch.isActive, false);
  assert.ok(!("displayName" in patch));
  assert.ok(!("email" in patch));

  const user = closedUserPatch();
  assert.equal(user.email, "");
  assert.deepEqual(user.fcmTokens, []);
  assert.equal(user.isDeleted, true);
});

test("closing an order keeps the suburb, drops the street and notes", () => {
  const patch = closedJobPatch({
    address: { line1: "3 Kloof Rd", line2: "Flat 2", city: "Gardens",
      postCode: "8001", country: "ZA", lat: -33.9, lng: 18.4 },
    accessNotes: "Gate 1234#", notes: "Ring twice",
  });
  assert.deepEqual(patch.address, { line1: "", line2: null, city: "Gardens",
    state: null, postCode: "", country: "ZA", lat: null, lng: null });
  assert.equal(patch.accessNotes, null);
  assert.equal(patch.notes, null);
  assert.ok(!("clientSignatureUrl" in patch)); // kept until purge
  assert.ok(!("photoIds" in patch));
});

test("purging leaves only the account number and QR codes", () => {
  assert.deepEqual(purgedClientPatch("client-1"),
      { displayName: `Closed account ${clientRef("client-1")}`, email: "" });
  assert.deepEqual(purgedUnitPatch({ qrCodeId: "SBX-1234-A1",
    label: "Grandma's letters" }),
  { label: "SBX-1234-A1", description: null, tags: [], photoIds: [] });
  assert.equal(purgedUnitPatch({}).label, "Unit");
  assert.deepEqual(purgedJobPatch(), { recipientName: null,
    clientSignatureUrl: null, photoIds: [], driverNotes: null });
});

test("closure notifications open the client's account settings", () => {
  const { routeFor } = require("../src/messages");
  assert.equal(routeFor("client", { entityType: "account", entityId: "c" }),
      "/client/account");
  assert.equal(routeFor("admin", { entityType: "client", entityId: "c" }),
      "/admin/clients/c");
});
