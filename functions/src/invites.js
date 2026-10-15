/**
 * Driver invites. The invite creates the driver's Firebase Auth account and
 * `users/{uid}` profile, then sends a "set your password" link. Opening that
 * link proves the driver owns the email, so nobody can claim a driver role
 * by signing up first with someone else's address.
 */
const { FieldValue } = require("firebase-admin/firestore");
const { HttpsError } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

const { COL, AUDIT, APP_URL } = require("./constants");
const { renderEmail } = require("./messages");

const EMAIL = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;

/**
 * @param {FirebaseFirestore.Firestore} db
 * @param {import("firebase-admin/auth").Auth} auth
 */
function createInvites(db, auth) {
  /** The calling admin's profile, or a permission error. */
  async function requireAdmin(request) {
    const uid = request.auth && request.auth.uid;
    if (!uid) throw new HttpsError("unauthenticated", "Sign in first.");
    const me = await db.collection(COL.users).doc(uid).get();
    if (!me.exists || me.get("role") !== "admin" || me.get("isDeleted")) {
      throw new HttpsError("permission-denied", "Only admins can invite.");
    }
    return { uid, tenantId: me.get("tenantId") };
  }

  /** A password-setup link that returns the driver to the app's sign-in. */
  async function setupLink(email) {
    try {
      return await auth.generatePasswordResetLink(email,
          { url: `${APP_URL}/login` });
    } catch (error) {
      // The app's domain may not be an authorised continue URL yet.
      if (error.code !== "auth/unauthorized-continue-uri" &&
          error.code !== "auth/invalid-continue-uri") throw error;
      return auth.generatePasswordResetLink(email);
    }
  }

  async function sendInvite(uid, name, email, link) {
    const first = (name || "").split(" ")[0];
    await db.collection(COL.mail).doc(`invite-${uid}-${Date.now()}`).set({
      to: email,
      message: renderEmail({
        heading: first ? `${first}, you're invited to drive for StrongBox` :
          "You're invited to drive for StrongBox",
        paragraphs: [
          "Set a password to open the StrongBox driver app: your daily " +
            "jobs, QR scanning and client sign-off.",
          "This link works for one hour. If it has expired, ask dispatch " +
            "to resend your invite. You can also use \"Continue with " +
            "Google\" with this email address.",
        ],
        cta: "Set your password",
        url: link,
      }),
      createdAt: FieldValue.serverTimestamp(),
    });
  }

  /**
   * Creates a driver's login and profile and sends the invite.
   * data: { name, email, phone? } → { uid, link }
   */
  async function inviteDriver(request) {
    const admin = await requireAdmin(request);
    const data = request.data || {};
    const name = String(data.name || "").trim();
    const email = String(data.email || "").trim().toLowerCase();
    const phone = String(data.phone || "").trim();
    if (!name) throw new HttpsError("invalid-argument", "Name is required.");
    if (!EMAIL.test(email)) {
      throw new HttpsError("invalid-argument", "Enter a valid email.");
    }

    let existing = null;
    try {
      existing = await auth.getUserByEmail(email);
    } catch (error) {
      if (error.code !== "auth/user-not-found") throw error;
    }
    if (existing) {
      const profile = await db.collection(COL.users).doc(existing.uid).get();
      throw new HttpsError("already-exists",
          profile.exists && profile.get("role") === "driver" ?
            `${email} is already a driver.` :
            `${email} already has an account — make them a Driver in ` +
              "Settings → Team.");
    }

    const user = await auth.createUser({ email, displayName: name });
    const batch = db.batch();
    batch.set(db.collection(COL.users).doc(user.uid), {
      tenantId: admin.tenantId,
      name,
      email,
      phone: phone || null,
      role: "driver",
      invited: true,
      isActive: true,
      isDeleted: false,
      fcmTokens: [],
      createdAt: FieldValue.serverTimestamp(),
    });
    batch.create(db.collection(COL.auditEvents).doc(), {
      tenantId: admin.tenantId,
      actorId: admin.uid,
      actorRole: "admin",
      action: AUDIT.userRoleChanged,
      entityType: "user",
      entityId: user.uid,
      metadata: { role: "driver", invited: true },
      timestamp: FieldValue.serverTimestamp(),
    });
    try {
      await batch.commit();
    } catch (error) {
      // Don't strand a login with no profile.
      await auth.deleteUser(user.uid).catch(() => {});
      throw error;
    }

    const link = await setupLink(email);
    await sendInvite(user.uid, name, email, link);
    logger.info("Driver invited", { uid: user.uid, by: admin.uid });
    return { uid: user.uid, link };
  }

  /**
   * A fresh setup link for a driver who has not signed in yet.
   * data: { uid } → { link }
   */
  async function resendInvite(request) {
    await requireAdmin(request);
    const uid = String((request.data || {}).uid || "");
    const profile = uid ? await db.collection(COL.users).doc(uid).get() : null;
    if (!profile || !profile.exists || profile.get("role") !== "driver") {
      throw new HttpsError("not-found", "No such driver.");
    }
    if (!profile.get("invited")) {
      throw new HttpsError("failed-precondition",
          "This driver has already signed in.");
    }
    const email = profile.get("email");
    const link = await setupLink(email);
    await sendInvite(uid, profile.get("name"), email, link);
    return { link };
  }

  return { inviteDriver, resendInvite };
}

module.exports = { createInvites };
