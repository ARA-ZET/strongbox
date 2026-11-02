const test = require("node:test");
const assert = require("node:assert/strict");
const { planBooking, catalogFrom, MAX_UNITS } = require("../src/booking");

const catalog = {
  boxes: [
    { id: "small", label: "Small box", monthlyZar: 195 },
    { id: "medium", label: "Medium box", monthlyZar: 295 },
    { id: "retired", label: "Old box", monthlyZar: 99, active: false },
  ],
  looseItems: [{ id: "bicycle", name: "Bicycle", monthlyZar: 150 }],
  vehicles: [{ id: "bakkie", label: "Bakkie", onceOffZar: 250 }],
  supplies: [
    { id: "bubble-wrap", label: "Bubble wrap", onceOffZar: 50 },
    { id: "old-tape", label: "Old tape", onceOffZar: 10, active: false },
  ],
  packingHelper: { label: "Packing helper", hourlyZar: 250, minHours: 2,
    active: true },
};
// 10:00 SAST on Thu 15 Oct 2026.
const NOW = new Date("2026-10-15T08:00:00Z");
const base = {
  boxes: { small: 2, medium: 1 },
  loose: { bicycle: 1 },
  vehicle: "bakkie",
  date: "2026-10-16T00:00:00.000+02:00",
  timeWindow: "morning",
  address: { line1: "12 Long St", city: "Cape Town", postCode: "8001" },
};

const rejects = (data, pattern) => assert.throws(
    () => planBooking({ ...base, ...data }, catalog, NOW),
    (error) => error.code === "invalid-argument" && pattern.test(error.message));

test("one unit per item, priced from the server's list", () => {
  const plan = planBooking(base, catalog, NOW);
  assert.deepEqual(plan.units.map((u) => `${u.label}:${u.monthlyRateZar}`), [
    "Small box 1:195", "Small box 2:195", "Medium box:295", "Bicycle:150",
  ]);
  assert.equal(plan.units[3].type, "open");
  assert.equal(plan.monthlyZar, 195 * 2 + 295 + 150);
  assert.equal(plan.vehicle.onceOffZar, 250);
  assert.equal(plan.address.country, "ZA");
});

test("prices in the request are ignored", () => {
  const plan = planBooking({ ...base, boxes: { small: 1 }, loose: {},
    monthlyRateZar: 1, price: 0 }, catalog, NOW);
  assert.equal(plan.units[0].monthlyRateZar, 195);
});

test("off-menu, retired or silly quantities are refused", () => {
  rejects({ boxes: { yacht: 1 } }, /isn't on the price list/);
  rejects({ boxes: { retired: 1 } }, /isn't on the price list/);
  rejects({ boxes: { small: -1 } }, /Quantity/);
  rejects({ boxes: { small: 1.5 } }, /Quantity/);
  rejects({ boxes: { small: 100 } }, /Quantity/);
  rejects({ boxes: {}, loose: {} }, /at least one/);
  rejects({ boxes: { small: 99, medium: 99, }, loose: { bicycle: 99 } },
      new RegExp(`more than ${MAX_UNITS}`));
});

test("needs a vehicle, a date from tomorrow, a window and an address", () => {
  rejects({ vehicle: "rocket" }, /vehicle/);
  rejects({ date: "2026-10-15T00:00:00.000+02:00" }, /tomorrow/); // today
  rejects({ date: "not a date" }, /date/);
  rejects({ date: "2027-06-01T00:00:00.000+02:00" }, /six months/);
  rejects({ timeWindow: "midnight" }, /time window/);
  rejects({ address: { line1: "", city: "Cape Town" } }, /address/);
});

test("reads the published list in the shape the app stores it", () => {
  const stored = catalogFrom({
    boxes: [{ id: "small", label: "Small box", desc: "", price: 210,
      active: true }],
    looseItems: [{ id: "desk", name: "Desk", category: "Office", price: 120 }],
    vehicles: [{ id: "bakkie", label: "Bakkie", price: 300, capacityM3: 3 }],
  });
  const plan = planBooking({ ...base, boxes: { small: 1 }, loose: { desk: 2 } },
      stored, NOW);
  assert.deepEqual(plan.units.map((u) => u.monthlyRateZar), [210, 120, 120]);
  assert.equal(plan.vehicle.onceOffZar, 300);
});

test("before the first publish, the generated defaults are the catalog", () => {
  const defaults = catalogFrom(undefined);
  assert.ok(defaults.boxes.length > 0 && defaults.vehicles.length > 0);
  assert.ok(defaults.looseItems.every((i) => i.name && i.monthlyZar > 0));
});

test("supplies and packing help are priced as once-off charges", () => {
  const plan = planBooking({ ...base, supplies: { "bubble-wrap": 3 },
    helperHours: 2 }, catalog, NOW);
  assert.deepEqual(plan.supplies,
      [{ id: "bubble-wrap", label: "Bubble wrap", qty: 3, unitZar: 50 }]);
  assert.equal(plan.helperZar, 500);
  assert.equal(plan.onceOffZar, 250 + 150 + 500);
  assert.equal(plan.supplyDrop, null); // Path B: brought on the day
  rejects({ helperHours: 1 }, /minimum of 2 hours/);
  rejects({ helperHours: 2.5 }, /whole hours/);
  rejects({ supplies: { "old-tape": 1 } }, /isn't on the price list/);
});

test("supplies first books a drop-off a day or more before the pickup", () => {
  const plan = planBooking({ ...base, date: "2026-10-20T00:00:00.000+02:00",
    suppliesFirst: true, supplyDate: "2026-10-17T00:00:00.000+02:00",
    supplyWindow: "afternoon" }, catalog, NOW);
  assert.equal(plan.supplyDrop.timeWindow, "afternoon");
  // One flat-pack box per booked box; loose items need none.
  assert.deepEqual(plan.emptyBoxes, { small: 2, medium: 1 });
  rejects({ suppliesFirst: true, supplyDate: base.date,
    supplyWindow: "morning" }, /at least a day before/);
  rejects({ suppliesFirst: true, supplyWindow: "morning" },
      /supply drop-off date/);
});
