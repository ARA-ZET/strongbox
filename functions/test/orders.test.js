const test = require("node:test");
const assert = require("node:assert/strict");
const { checkCancel, releasedUnit } = require("../src/orders");

const job = (fields) => ({
  clientId: "client-1",
  type: "pickup",
  status: "assigned",
  isDeleted: false,
  ...fields,
});

const refuses = (j, linked, code, pattern) => assert.throws(
    () => checkCancel(j, linked, "client-1"),
    (error) => error.code === code && pattern.test(error.message));

test("a client can cancel a pickup or delivery until the driver starts", () => {
  for (const status of ["pendingConfirmation", "scheduled", "assigned"]) {
    assert.equal(checkCancel(job({ status }), undefined, "client-1"), true);
    assert.equal(checkCancel(job({ status, type: "delivery" }), undefined,
        "client-1"), true);
  }
  for (const status of ["inProgress", "collected", "completed"]) {
    refuses(job({ status }), undefined, "failed-precondition",
        /driver has already started/);
  }
  // Already cancelled — nothing to do, no error (e.g. a double tap).
  assert.equal(checkCancel(job({ status: "cancelled" }), undefined,
      "client-1"), false);
});

test("only the client's own pickups and deliveries", () => {
  refuses(undefined, undefined, "not-found", /couldn't find/);
  refuses(job({ clientId: "someone-else" }), undefined, "not-found",
      /couldn't find/);
  refuses(job({ isDeleted: true }), undefined, "not-found", /couldn't find/);
  refuses(job({ type: "supplyDrop" }), undefined, "failed-precondition",
      /with their pickup/);
});

test("a supplies-first pickup can't be cancelled once supplies are out", () => {
  const pickup = job({ linkedJobId: "drop-1" });
  assert.equal(checkCancel(pickup, job({ type: "supplyDrop" }), "client-1"),
      true);
  assert.equal(checkCancel(pickup,
      job({ type: "supplyDrop", status: "cancelled" }), "client-1"), true);
  for (const status of ["inProgress", "completed"]) {
    refuses(pickup, job({ type: "supplyDrop", status }),
        "failed-precondition", /supplies are already on their way/);
  }
});

test("cancelling releases the job's units the way the app does", () => {
  const booked = job({ source: "quote" });
  assert.deepEqual(releasedUnit(booked, "j1",
      { jobId: "j1", status: "pendingPickup" }),
  { jobId: null, status: "cancelled" });
  // An ops pickup's units stay awaiting pickup.
  assert.deepEqual(releasedUnit(job({ source: null }), "j1",
      { jobId: "j1", status: "pendingPickup" }), { jobId: null });
  // A delivery's units go back to storage.
  assert.deepEqual(releasedUnit(job({ type: "delivery" }), "j1",
      { jobId: "j1", status: "pendingDelivery" }),
  { jobId: null, status: "inStorage" });
  // Units that moved to another job, or are gone, are left alone.
  assert.equal(releasedUnit(booked, "j1",
      { jobId: "j2", status: "pendingPickup" }), null);
  assert.equal(releasedUnit(booked, "j1", undefined), null);
});
