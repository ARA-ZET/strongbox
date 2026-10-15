/**
 * What to tell whom — pure functions, no Firestore access.
 *
 * A "message" here is a notification draft:
 *   { to: "client" | "driver" | "admins", userId?, type, title, body,
 *     entityType, entityId }
 * index.js resolves `to` into a recipient uid and writes it to
 * `notifications/{id}` in the app's AppNotification shape.
 */
const { NOTIFY, TIME_ZONE, APP_URL } = require("./constants");

const WINDOW_LABEL = {
  morning: "morning",
  afternoon: "afternoon",
  evening: "evening",
};

/** The app's Job.reference: "#JB-9042". */
function jobReference(jobId) {
  return `#JB-${jobId.slice(0, 4).toUpperCase()}`;
}

function toDate(value) {
  if (!value) return null;
  if (value instanceof Date) return value;
  if (typeof value.toDate === "function") return value.toDate();
  return new Date(value);
}

/**
 * "Tue 3 Nov" (or "3 Nov" without [weekday]) in SAST. Built from parts —
 * locale patterns differ between ICU builds.
 */
function sastDay(date, { weekday = true } = {}) {
  const parts = {};
  for (const part of new Intl.DateTimeFormat("en-US", {
    weekday: "short",
    day: "numeric",
    month: "short",
    timeZone: TIME_ZONE,
  }).formatToParts(date)) {
    parts[part.type] = part.value;
  }
  const day = `${parts.day} ${parts.month}`;
  return weekday ? `${parts.weekday} ${day}` : day;
}

/** "Tue 3 Nov, morning" — or just the window when there is no date. */
function jobWhen(job) {
  const date = toDate(job.scheduledDate);
  const window = WINDOW_LABEL[job.timeWindow] || "";
  if (!date) return window;
  const day = sastDay(date);
  return window ? `${day}, ${window}` : day;
}

function itemCount(job) {
  const n = (job.storageUnitIds || []).length;
  return `${n} ${n === 1 ? "item" : "items"}`;
}

function kind(job) {
  return job.type === "delivery" ? "delivery" : "pickup";
}

function capitalise(word) {
  return word.charAt(0).toUpperCase() + word.slice(1);
}

function place(job) {
  const address = job.address || {};
  return [address.line1, address.city].filter(Boolean).join(", ");
}

function assignedMessage(job, jobId) {
  const where = place(job);
  return {
    to: "driver",
    userId: job.driverId,
    type: NOTIFY.jobAssigned,
    title: `New ${kind(job)} assigned — ${jobReference(jobId)}`,
    body: [jobWhen(job), where, itemCount(job)].filter(Boolean).join(" · "),
    entityType: "job",
    entityId: jobId,
  };
}

/**
 * Messages for a job that was just created.
 * @param {object} job
 * @param {string} jobId
 * @param {string} clientName for the admin alert
 * @return {Array<object>}
 */
function jobCreatedMessages(job, jobId, clientName) {
  if (job.isDeleted || job.status === "cancelled") return [];
  if (job.driverId) return [assignedMessage(job, jobId)];
  const who = clientName ? `${clientName} · ` : "";
  return [{
    to: "admins",
    type: job.type === "delivery" ?
      NOTIFY.deliveryRequested :
      NOTIFY.jobScheduled,
    title: `${capitalise(kind(job))} awaiting a driver — ` +
      jobReference(jobId),
    body: `${who}${itemCount(job)} · ${jobWhen(job)}`,
    entityType: "job",
    entityId: jobId,
  }];
}

/**
 * Messages for a job update: driver (re)assigned, started, completed or
 * cancelled. Unit statuses are settled by the app in the same transaction
 * as the job (JobRepository) — this only notifies.
 * @param {object} before
 * @param {object} after
 * @param {string} jobId
 * @return {Array<object>}
 */
function jobUpdatedMessages(before, after, jobId) {
  const out = [];
  const ref = jobReference(jobId);
  const pickup = kind(after) === "pickup";
  const what = itemCount(after);
  const closed = after.status === "completed" || after.status === "cancelled";

  if (after.driverId && after.driverId !== before.driverId && !closed) {
    out.push(assignedMessage(after, jobId));
  }
  if (before.status === after.status) return out;

  const client = (fields) => ({
    to: "client",
    entityType: "job",
    entityId: jobId,
    ...fields,
  });

  switch (after.status) {
    case "inProgress":
      out.push(client({
        type: NOTIFY.jobStarted,
        title: pickup ?
          "Your driver is on the way" :
          "Your delivery is on its way",
        body: pickup ?
          `We're on our way to collect ${what} (${ref}).` :
          `Your driver has left our facility with ${what} (${ref}).`,
      }));
      break;
    case "completed":
      out.push(client(pickup ? {
        type: NOTIFY.pickupConfirmed,
        title: "Your items are safely collected",
        body: `${capitalise(what)} collected and on the way to secure ` +
          `storage (${ref}).`,
      } : {
        type: NOTIFY.deliveryCompleted,
        title: "Delivery complete",
        body: `${capitalise(what)} delivered and signed for (${ref}).`,
      }));
      out.push({
        to: "admins",
        type: NOTIFY.jobCompleted,
        title: `${capitalise(kind(after))} ${ref} completed`,
        body: `${capitalise(what)} · signed off by the client.`,
        entityType: "job",
        entityId: jobId,
      });
      break;
    case "cancelled": {
      const reason = after.cancelReason ? ` Reason: ${after.cancelReason}` : "";
      out.push(client({
        type: NOTIFY.jobCancelled,
        title: `Your ${kind(after)} was cancelled`,
        body: `${ref} (${jobWhen(after)}) was cancelled.${reason} ` +
          "Contact us if you need to rebook.",
      }));
      const driverId = after.driverId || before.driverId;
      if (driverId) {
        out.push({
          to: "driver",
          userId: driverId,
          type: NOTIFY.jobCancelled,
          title: `${capitalise(kind(after))} ${ref} cancelled`,
          body: `${jobWhen(after)} · ${place(after)}`,
          entityType: "job",
          entityId: jobId,
        });
      }
      break;
    }
    default:
      break;
  }
  return out;
}

/**
 * Where tapping a notification takes [role]. Admin and client have no job
 * detail route, so jobs open the list.
 * @param {string} role UserRole
 * @param {{entityType?: string, entityId?: string}} n
 * @return {string}
 */
function routeFor(role, n) {
  const id = n.entityId;
  switch (role) {
    case "admin":
      if (n.entityType === "job") return "/admin/jobs";
      if (n.entityType === "client" && id) return `/admin/clients/${id}`;
      if (n.entityType === "unit" && id) return `/admin/inventory/${id}`;
      if (n.entityType === "qr") return "/admin/qr";
      if (n.entityType === "settings") return "/admin/settings";
      return "/admin/notifications";
    case "driver":
      if (n.entityType === "job" && id) return `/driver/jobs/${id}`;
      return "/driver/notifications";
    default:
      if (n.entityType === "job") return "/client/deliveries";
      if (n.entityType === "invoice") return "/client/subscription";
      if (n.entityType === "unit" && id) return `/client/storage/${id}`;
      return "/client/notifications";
  }
}

/**
 * NotificationPrefs key that gates the email for each type, with the
 * app's defaults (app/lib/core/models/value_objects.dart). Types not listed
 * here are push / in-app only.
 */
const EMAIL_PREF = {
  [NOTIFY.jobStarted]: "pickupStartedEmail",
  [NOTIFY.pickupConfirmed]: "deliveryCompletedEmail",
  [NOTIFY.deliveryCompleted]: "deliveryCompletedEmail",
  [NOTIFY.invoiceReady]: "invoiceReadyEmail",
  [NOTIFY.invoicePaid]: "invoiceReadyEmail",
  [NOTIFY.storageThreshold]: "storageThresholdEmail",
};
const EMAIL_PREF_DEFAULTS = {
  pickupStartedEmail: true,
  deliveryCompletedEmail: true,
  invoiceReadyEmail: true,
  storageThresholdEmail: true,
};

/** Whether [user] wants this notification by email. Clients only. */
function wantsEmail(user, type) {
  if (!user || user.role !== "client" || !user.email) return false;
  const key = EMAIL_PREF[type];
  if (!key) return false;
  const prefs = user.notificationPrefs || {};
  return prefs[key] ?? EMAIL_PREF_DEFAULTS[key];
}

function escapeHtml(text) {
  return String(text)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;");
}

/** A short branded email: heading, paragraphs, one button. */
function renderEmail({ heading, paragraphs, cta, url }) {
  const text = [heading, "", ...paragraphs, "", `${cta}: ${url}`, "",
    "— StrongBox Logistics"].join("\n");
  const html = `<!doctype html><html><body style="margin:0;background:#F4F8FD;` +
    `font-family:Inter,Arial,sans-serif;color:#10203A">` +
    `<div style="max-width:560px;margin:0 auto;padding:32px 16px">` +
    `<p style="font-weight:700;font-size:18px;margin:0 0 24px">StrongBox</p>` +
    `<div style="background:#FFFFFF;border-radius:12px;padding:24px">` +
    `<h1 style="font-size:22px;margin:0 0 16px">${escapeHtml(heading)}</h1>` +
    paragraphs.map((p) => `<p style="font-size:14px;line-height:1.5;` +
      `color:#4A5A72;margin:0 0 12px">${escapeHtml(p)}</p>`).join("") +
    `<a href="${escapeHtml(url)}" style="display:inline-block;margin-top:12px;` +
    `background:#1D6FE0;color:#FFFFFF;text-decoration:none;font-weight:600;` +
    `padding:12px 20px;border-radius:12px">${escapeHtml(cta)}</a>` +
    `</div></div></body></html>`;
  return { subject: heading, text, html };
}

/** Email for a notification [n] sent to a client. */
function notificationEmail(n, route) {
  return renderEmail({
    heading: n.title,
    paragraphs: [n.body],
    cta: n.entityType === "invoice" ? "View billing" : "Open StrongBox",
    url: `${APP_URL}${route}`,
  });
}

/** Welcome email for a new client account. */
function welcomeEmail(client) {
  const name = (client.displayName || "").split(" ")[0];
  return renderEmail({
    heading: name ? `Welcome to StrongBox, ${name}` : "Welcome to StrongBox",
    paragraphs: [
      "Your account is ready. Book a pickup and we'll collect your boxes, " +
        "store them securely and bring them back whenever you ask.",
      "You pay per box or item each month, only for what we're storing — " +
        "no contract and no minimum term.",
    ],
    cta: "Go to your account",
    url: `${APP_URL}/client/dashboard`,
  });
}

module.exports = {
  sastDay,
  jobReference,
  jobWhen,
  jobCreatedMessages,
  jobUpdatedMessages,
  routeFor,
  wantsEmail,
  notificationEmail,
  welcomeEmail,
  renderEmail,
  escapeHtml,
};
