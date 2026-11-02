const test = require("node:test");
const assert = require("node:assert/strict");
const { UNIT_CODE, newUnitCode, freshUnitCodes } = require("../src/qr");

/** Firestore stand-in: `qrCodes` holds [taken]. */
function fakeDb(taken) {
  return {
    collection: () => ({ doc: (id) => ({ id }) }),
    getAll: async (...refs) =>
      refs.map((ref) => ({ id: ref.id, exists: taken.has(ref.id) })),
  };
}

/** A `randomInt` that replays [values], then repeats the last one. */
function scripted(values) {
  let i = 0;
  return (max) => {
    const value = values[Math.min(i++, values.length - 1)];
    assert.ok(value < max);
    return value;
  };
}

test("unit codes match the printed-label format", () => {
  for (let i = 0; i < 200; i++) assert.match(newUnitCode(), UNIT_CODE);
  // letter, number, digit
  assert.equal(newUnitCode(scripted([0, 8942, 1])), "SBX-9942-A1");
});

test("fresh codes are distinct and unused", async () => {
  const codes = await freshUnitCodes(fakeDb(new Set()), 50);
  assert.equal(codes.length, 50);
  assert.equal(new Set(codes).size, 50);
  codes.forEach((code) => assert.match(code, UNIT_CODE));
});

test("codes already in qrCodes are skipped", async () => {
  // First draw SBX-1000-A0 (taken), then SBX-1001-A0.
  const rand = scripted([0, 0, 0, 0, 1, 0]);
  const codes = await freshUnitCodes(fakeDb(new Set(["SBX-1000-A0"])), 1,
      rand);
  assert.deepEqual(codes, ["SBX-1001-A0"]);
});
