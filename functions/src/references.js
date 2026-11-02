/**
 * Public references — what people see instead of Firebase ids, e.g.
 * `SB-7K3QX9`. A one-way fingerprint of the id: stable and practically
 * unique, but the id can't be read back from it. Must match
 * app/lib/core/utils/public_ref.dart exactly.
 */
const { createHash } = require("node:crypto");

/** Crockford base32 — no I, L, O or U to misread. */
const ALPHABET = "0123456789ABCDEFGHJKMNPQRSTVWXYZ";

/**
 * @param {string} prefix e.g. "SB"
 * @param {string} id a Firebase document id or uid
 * @return {string}
 */
function publicRef(prefix, id) {
  // First 30 bits of SHA-256(id) → 6 base32 characters.
  let bits = createHash("sha256").update(String(id)).digest()
      .readUInt32BE(0) >>> 2;
  let out = "";
  for (let i = 0; i < 6; i++) {
    out = ALPHABET[bits & 31] + out;
    bits >>>= 5;
  }
  return `${prefix}-${out}`;
}

/** A client's account number, e.g. `SB-7K3QX9`. */
const clientRef = (clientId) => publicRef("SB", clientId);

const JOB_PREFIX = { pickup: "PU", delivery: "DL", supplyDrop: "SD" };

/** A job's reference, e.g. `PU-4F8K2M` — the app's jobRef(). */
const jobRef = (jobId, type) => publicRef(JOB_PREFIX[type] || "PU", jobId);

module.exports = { publicRef, clientRef, jobRef };
