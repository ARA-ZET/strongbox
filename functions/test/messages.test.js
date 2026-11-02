const test = require("node:test");
const assert = require("node:assert/strict");
const {
  jobCreatedMessages,
  jobUpdatedMessages,
  jobWhen,
  routeFor,
  wantsEmail,
  notificationEmail,
  welcomeEmail,
} = require("../src/messages");

const base = {
  tenantId: "strongbox-default",
  type: "pickup",
  status: "scheduled",
  clientId: "client-1",
  driverId: null,
  scheduledDate: new Date("2026-11-03T08:00:00Z"),
  timeWindow: "morning",
  address: { line1: "12 Long St", city: "Cape Town" },
  storageUnitIds: ["u1", "u2", "u3"],
};
const JOB_ID = "ab12cd34";

const types = (msgs) => msgs.map((m) => `${m.to}:${m.type}`);

test("dates read in SAST with the time window", () => {
  assert.equal(jobWhen(base), "Tue 3 Nov, morning");
});

test("an unassigned new job alerts admins; delivery requests say so", () => {
  assert.deepEqual(types(jobCreatedMessages(base, JOB_ID, "Thandi")),
      ["admins:jobScheduled"]);
  const delivery = jobCreatedMessages(
      { ...base, type: "delivery" }, JOB_ID, "Thandi");
  assert.deepEqual(types(delivery), ["admins:deliveryRequested"]);
  assert.match(delivery[0].title, /DL-[0-9A-Z]{6}/);
  assert.doesNotMatch(delivery[0].title, /AB12/i); // never the raw id
  assert.match(delivery[0].body, /^Thandi · 3 items · Tue 3 Nov, morning$/);
});

test("a job created with a driver goes straight to that driver", () => {
  const msgs = jobCreatedMessages({ ...base, driverId: "drv-1" }, JOB_ID, "");
  assert.deepEqual(types(msgs), ["driver:jobAssigned"]);
  assert.equal(msgs[0].userId, "drv-1");
  assert.equal(msgs[0].body, "Tue 3 Nov, morning · 12 Long St, Cape Town · 3 items");
});

test("assigning or reassigning a driver notifies the new driver only", () => {
  const assigned = { ...base, status: "assigned", driverId: "drv-1" };
  assert.deepEqual(types(jobUpdatedMessages(base, assigned, JOB_ID)),
      ["driver:jobAssigned"]);
  const reassigned = { ...assigned, driverId: "drv-2" };
  const msgs = jobUpdatedMessages(assigned, reassigned, JOB_ID);
  assert.deepEqual(msgs.map((m) => m.userId), ["drv-2"]);
  // Unrelated edits stay quiet.
  assert.deepEqual(jobUpdatedMessages(assigned, { ...assigned, notes: "x" },
      JOB_ID), []);
});

test("a client booking asks admins to confirm and tells the client", () => {
  const booking = { ...base, status: "pendingConfirmation",
    suppliesFirst: true, helperHours: 2 };
  const msgs = jobCreatedMessages(booking, JOB_ID, "Thandi");
  assert.deepEqual(types(msgs), ["admins:jobScheduled", "client:bookingReceived"]);
  assert.match(msgs[0].title, /to confirm/);
  assert.match(msgs[0].body, /supplies first, 2h packing help/);
  // Its paired supply drop-off adds nothing of its own.
  assert.deepEqual(jobCreatedMessages({ ...booking, type: "supplyDrop",
    linkedJobId: "p1" }, "s1", "Thandi"), []);
});

test("confirming or declining a booking tells the client", () => {
  const pending = { ...base, status: "pendingConfirmation" };
  assert.deepEqual(types(jobUpdatedMessages(pending,
      { ...pending, status: "scheduled" }, JOB_ID)),
  ["client:bookingConfirmed"]);
  const declined = jobUpdatedMessages(pending,
      { ...pending, status: "cancelled", cancelReason: "Area not served." },
      JOB_ID);
  assert.deepEqual(types(declined), ["client:bookingDeclined"]);
  assert.match(declined[0].body, /Area not served/);
});

test("check-ins tell the client who is coming, then that they arrived", () => {
  const assigned = { ...base, status: "assigned", driverId: "drv-1" };
  const started = { ...assigned, status: "inProgress", departedAt: new Date() };
  const enRoute = jobUpdatedMessages(assigned, started, JOB_ID,
      { driverName: "Sipho" });
  assert.deepEqual(types(enRoute), ["client:driverEnRoute"]);
  assert.match(enRoute[0].body, /^Sipho \(E-ID DRV-[0-9A-Z]{6}\) is on the way/);
  const arrived = { ...started, arrivedAt: new Date() };
  assert.deepEqual(types(jobUpdatedMessages(started, arrived, JOB_ID)),
      ["client:driverArrived"]);
  // A delivery starting at the facility says nothing until it departs.
  const loading = { ...assigned, type: "delivery", status: "inProgress" };
  assert.deepEqual(jobUpdatedMessages({ ...assigned, type: "delivery" },
      loading, JOB_ID), []);
});

test("collection, receiving and completion reach the client", () => {
  const started = { ...base, status: "inProgress", driverId: "drv-1" };
  const collected = { ...started, status: "collected" };
  assert.deepEqual(types(jobUpdatedMessages(started, collected, JOB_ID)),
      ["client:pickupConfirmed"]);
  const stored = { ...collected, status: "completed" };
  assert.deepEqual(types(jobUpdatedMessages(collected, stored, JOB_ID)),
      ["client:unitsReceived", "admins:jobCompleted"]);
  const delivered = jobUpdatedMessages(
      { ...started, type: "delivery" },
      { ...started, type: "delivery", status: "completed",
        recipientName: "Ann" }, JOB_ID);
  assert.deepEqual(types(delivered),
      ["client:deliveryCompleted", "admins:jobCompleted"]);
  assert.match(delivered[0].body, /signed for by Ann/);
  const supplies = jobUpdatedMessages({ ...started, type: "supplyDrop" },
      { ...started, type: "supplyDrop", status: "completed" }, JOB_ID);
  assert.deepEqual(types(supplies),
      ["client:suppliesDelivered", "admins:jobCompleted"]);
});

test("cancellation tells the client and the driver who had it", () => {
  const assigned = { ...base, status: "assigned", driverId: "drv-1" };
  const cancelled = { ...assigned, status: "cancelled",
    cancelReason: "Client away" };
  const msgs = jobUpdatedMessages(assigned, cancelled, JOB_ID);
  assert.deepEqual(types(msgs), ["client:jobCancelled", "driver:jobCancelled"]);
  assert.match(msgs[0].body, /Reason: Client away/);
  assert.deepEqual(types(jobUpdatedMessages(base,
      { ...base, status: "cancelled" }, JOB_ID)), ["client:jobCancelled"]);
});

test("routes open a screen each role can see", () => {
  const job = { entityType: "job", entityId: "j1" };
  assert.equal(routeFor("driver", job), "/driver/jobs/j1");
  assert.equal(routeFor("client", job), "/client/orders/j1");
  assert.equal(routeFor("client", { entityType: "job" }), "/client/orders");
  assert.equal(routeFor("admin", job), "/admin/jobs");
  assert.equal(routeFor("client", { entityType: "invoice", entityId: "i" }),
      "/client/subscription");
  assert.equal(routeFor("admin", { entityType: "client", entityId: "c1" }),
      "/admin/clients/c1");
  assert.equal(routeFor("driver", {}), "/driver/notifications");
});

test("email follows the client's preferences and app defaults", () => {
  const user = { role: "client", email: "a@b.co" };
  assert.equal(wantsEmail(user, "invoiceReady"), true);
  assert.equal(wantsEmail({ ...user,
    notificationPrefs: { invoiceReadyEmail: false } }, "invoiceReady"), false);
  assert.equal(wantsEmail(user, "jobCancelled"), false); // push only
  assert.equal(wantsEmail({ ...user, role: "driver" }, "jobStarted"), false);
  assert.equal(wantsEmail({ role: "client" }, "jobStarted"), false);
});

test("emails escape user content and link into the app", () => {
  const email = notificationEmail(
      { title: "<b>Hi</b>", body: "A & B", entityType: "invoice" },
      "/client/subscription");
  assert.equal(email.subject, "<b>Hi</b>");
  assert.match(email.html, /&lt;b&gt;Hi&lt;\/b&gt;/);
  assert.match(email.html, /A &amp; B/);
  assert.match(email.text, /View billing: https:\/\/app\.strongbox\.co\.za\/client\/subscription/);
  assert.match(welcomeEmail({ displayName: "Thandi Nkosi" }).subject,
      /Welcome to StrongBox, Thandi/);
});

test("due dates read without a weekday", () => {
  const { sastDay } = require("../src/messages");
  assert.equal(sastDay(new Date("2026-11-07T22:00:00Z"), { weekday: false }),
      "8 Nov");
});
