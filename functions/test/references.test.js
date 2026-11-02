const test = require("node:test");
const assert = require("node:assert/strict");
const { publicRef, clientRef } = require("../src/references");

// Same vectors as app/test/core/public_ref_test.dart — must agree.
test("references match the app's", () => {
  assert.equal(publicRef("SB", "abc123"), "SB-DJGKTM");
  assert.equal(publicRef("SB", "client-1"), "SB-AW2DW6");
  assert.equal(clientRef("xK9mQ2pL7vR4tY8wN3bZ"), "SB-XKYNBG");
});
