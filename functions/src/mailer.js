/**
 * Outbound email. Everything that emails someone writes a doc to `mail`:
 *
 *   { to, message: { subject, text, html }, replyTo?, ... }
 *
 * and `onMailCreated` (index.js) sends it over SMTP, then records the
 * outcome on the same doc — the shape the Trigger Email extension uses:
 *
 *   delivery: { state: "SUCCESS" | "ERROR", attempts, error?, messageId?,
 *               startTime, endTime }
 *
 * SMTP works with any provider (Brevo, Resend, SendGrid, Gmail/Workspace,
 * the domain host's mail). The connection is one secret, SMTP_URL, e.g.
 * `smtps://user:password@smtp-relay.brevo.com:465`.
 */
const nodemailer = require("nodemailer");

/** Test hook: `SMTP_URL=json://` builds messages without sending them. */
const JSON_TRANSPORT = "json://";

/** A nodemailer transport for [smtpUrl], or null when it isn't set. */
function transportFor(smtpUrl) {
  const url = String(smtpUrl || "").trim();
  if (!url) return null;
  if (url === JSON_TRANSPORT) return nodemailer.createTransport({ jsonTransport: true });
  return nodemailer.createTransport(url);
}

/**
 * Sends one `mail` doc.
 * @param {{to: string, message: {subject: string, text?: string,
 *   html?: string}, replyTo?: string}} mail
 * @param {{transport: object|null, from: string, replyTo?: string}} options
 * @return {Promise<{state: string, error?: string, messageId?: string}>}
 */
async function sendMail(mail, { transport, from, replyTo }) {
  if (!transport) {
    return { state: "ERROR", error: "Email sending is not set up (SMTP_URL)." };
  }
  const message = mail.message || {};
  if (!mail.to || !message.subject) {
    return { state: "ERROR", error: "Missing recipient or subject." };
  }
  try {
    const info = await transport.sendMail({
      from,
      to: mail.to,
      replyTo: mail.replyTo || replyTo || undefined,
      subject: message.subject,
      text: message.text,
      html: message.html,
    });
    if (info.rejected && info.rejected.length > 0) {
      return {
        state: "ERROR",
        error: `Rejected by the mail server: ${info.rejected.join(", ")}`,
      };
    }
    return { state: "SUCCESS", messageId: info.messageId || null };
  } catch (error) {
    // e.g. bad credentials, unknown host, recipient refused.
    return { state: "ERROR", error: String(error.message || error) };
  }
}

module.exports = { transportFor, sendMail, JSON_TRANSPORT };
