const test = require("node:test");
const assert = require("node:assert/strict");
const { planDelivery } = require("../src/delivery");

// 10:00 SAST on Thu 15 Oct 2026.
const NOW = new Date("2026-10-15T08:00:00Z");
const base = {
  unitIds: ["u1", "u2", "u1"],
  date: "2026-10-16T00:00:00.000+02:00",
  timeWindow: "evening",
  address: { line1: "3 Kloof Rd", city: "Cape Town" },
};

const rejects = (data, pattern) => assert.throws(
    () => planDelivery({ ...base, ...data }, NOW),
    (error) => error.code === "invalid-argument" && pattern.test(error.message));

test("a request needs units, next-day notice, a window and an address", () => {
  const plan = planDelivery(base, NOW);
  assert.deepEqual(plan.unitIds, ["u1", "u2"]); // de-duplicated
  assert.equal(plan.timeWindow, "evening");
  assert.equal(plan.address.country, "ZA");
  rejects({ unitIds: [] }, /at least one item/);
  rejects({ date: "2026-10-15T15:00:00.000+02:00" }, /a day's notice/);
  rejects({ date: "2026-11-20T00:00:00.000+02:00" }, /next 30 days/);
  rejects({ timeWindow: "night" }, /time window/);
  rejects({ address: { line1: "" } }, /delivery address/);
});
