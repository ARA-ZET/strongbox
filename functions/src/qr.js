/**
 * Storage-unit QR codes, e.g. `SBX-9942-A1` — the same format the app
 * prints in batches (app/lib/core/utils/qr_generator.dart). A code's
 * `qrCodes/{code}` doc id is the code itself, so a clash is an existing doc.
 */
const { randomInt } = require("node:crypto");

const { COL } = require("./constants");

const UNIT_CODE = /^SBX-\d{4}-[A-Z]\d$/;

/** One random unit code. [rand] is `randomInt`-shaped, for tests. */
function newUnitCode(rand = randomInt) {
  const letter = String.fromCharCode(65 + rand(26));
  return `SBX-${1000 + rand(9000)}-${letter}${rand(10)}`;
}

/**
 * [count] distinct codes not yet in `qrCodes`. Writers still `create()`
 * them, which fails rather than overwrite if one lands in between.
 * @param {FirebaseFirestore.Firestore} db
 * @param {number} count
 * @return {Promise<string[]>}
 */
async function freshUnitCodes(db, count, rand = randomInt) {
  const codes = new Set();
  for (let round = 0; codes.size < count; round++) {
    if (round >= 5) throw new Error("Could not find unused QR codes.");
    const candidates = new Set();
    while (candidates.size < count - codes.size) {
      const code = newUnitCode(rand);
      if (!codes.has(code)) candidates.add(code);
    }
    const snaps = await db.getAll(...[...candidates].map((code) =>
      db.collection(COL.qrCodes).doc(code)));
    snaps.filter((snap) => !snap.exists).forEach((snap) => codes.add(snap.id));
  }
  return [...codes];
}

module.exports = { UNIT_CODE, newUnitCode, freshUnitCodes };
