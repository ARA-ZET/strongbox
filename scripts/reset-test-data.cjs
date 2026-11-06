#!/usr/bin/env node
/**
 * Clears test data so the client → admin → driver → invoice journey can be
 * tested from a clean slate.
 *
 *   node scripts/reset-test-data.cjs            # dry run: shows what would go
 *   node scripts/reset-test-data.cjs --yes      # actually deletes
 *   --project <id>                              # default strongbox-app
 *
 * KEEPS: staff accounts (users with role admin or driver) and their Auth
 * logins, `tenants` (business + EFT details), `priceLists`, `vehicles`, and
 * driver profile photos in Storage.
 * DELETES: every other top-level collection (subcollections included),
 * client `users` docs, every other Auth login, and every other Storage file.
 *
 * This hard-deletes on purpose: it is a test-reset tool, not app code. The
 * app itself only ever soft-deletes. Needs Application Default Credentials
 * (`gcloud auth application-default login`) for an owner of the project.
 */
const path = require("node:path");
module.paths.push(path.join(__dirname, "..", "functions", "node_modules"));

const { initializeApp, applicationDefault } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getAuth } = require("firebase-admin/auth");
const { getStorage } = require("firebase-admin/storage");

const args = process.argv.slice(2);
const execute = args.includes("--yes");
const projectArg = args.indexOf("--project");
const projectId = projectArg >= 0 ? args[projectArg + 1] : "strongbox-app";
const bucketName = `${projectId}.firebasestorage.app`;

const KEEP_COLLECTIONS = new Set(["tenants", "priceLists", "vehicles"]);
const STAFF_ROLES = new Set(["admin", "driver"]);

initializeApp({ credential: applicationDefault(), projectId });
const db = getFirestore();
const auth = getAuth();
const bucket = getStorage().bucket(bucketName);

async function main() {
  console.log(`Project: ${projectId}   Mode: ${execute ? "DELETE" : "dry run"}\n`);

  // --- users: keep staff, drop clients --------------------------------
  const users = await db.collection("users").get();
  const staff = new Map();
  const clientUserDocs = [];
  for (const doc of users.docs) {
    const role = doc.get("role");
    if (STAFF_ROLES.has(role)) staff.set(doc.id, `${role}  ${doc.get("email") || doc.id}`);
    else clientUserDocs.push(doc);
  }
  console.log("Keeping staff accounts:");
  for (const label of staff.values()) console.log(`  ${label}`);
  if (staff.size === 0 || ![...staff.values()].some((s) => s.startsWith("admin"))) {
    throw new Error("No admin user found — refusing to continue (you would be locked out).");
  }
  console.log(`\nusers (client profiles): ${clientUserDocs.length} to delete`);

  // --- other collections ----------------------------------------------
  const collections = await db.listCollections();
  const toClear = [];
  for (const col of collections) {
    if (col.id === "users") continue;
    const count = (await col.count().get()).data().count;
    const keep = KEEP_COLLECTIONS.has(col.id);
    console.log(`${col.id}: ${count} ${keep ? "(kept)" : "to delete"}`);
    if (!keep && count > 0) toClear.push(col);
  }

  // --- Auth logins ----------------------------------------------------
  const authToDelete = [];
  let pageToken;
  do {
    const page = await auth.listUsers(1000, pageToken);
    for (const u of page.users) if (!staff.has(u.uid)) authToDelete.push(u);
    pageToken = page.pageToken;
  } while (pageToken);
  console.log(`\nAuth logins to delete: ${authToDelete.length}`);
  for (const u of authToDelete) console.log(`  ${u.email || u.uid}`);

  // --- Storage files --------------------------------------------------
  let files = [];
  try {
    [files] = await bucket.getFiles();
  } catch (error) {
    console.log(`\nStorage: could not list ${bucketName} (${error.message}) — skipping`);
  }
  const filesToDelete = files.filter((f) => !f.name.includes("/drivers/"));
  console.log(`\nStorage files: ${filesToDelete.length} to delete, ` +
    `${files.length - filesToDelete.length} driver photos kept`);

  if (!execute) {
    console.log("\nDry run only. Re-run with --yes to delete the above.");
    return;
  }

  console.log("\nDeleting…");
  for (const col of toClear) {
    await db.recursiveDelete(col);
    console.log(`  cleared ${col.id}`);
  }
  for (const doc of clientUserDocs) await db.recursiveDelete(doc.ref);
  console.log(`  deleted ${clientUserDocs.length} client user docs`);
  for (let i = 0; i < authToDelete.length; i += 1000) {
    const res = await auth.deleteUsers(authToDelete.slice(i, i + 1000).map((u) => u.uid));
    if (res.failureCount) console.log(`  ${res.failureCount} Auth deletions failed`, res.errors);
  }
  console.log(`  deleted ${authToDelete.length} Auth logins`);
  await Promise.all(filesToDelete.map((f) => f.delete()));
  console.log(`  deleted ${filesToDelete.length} Storage files`);
  console.log("\nDone.");
}

main().catch((error) => {
  console.error(`\n${error.message}`);
  process.exit(1);
});
