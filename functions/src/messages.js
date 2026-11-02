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
const { jobRef, publicRef } = require("./references");

const WINDOW_LABEL = {
  morning: "morning",
  afternoon: "afternoon",
  evening: "evening",
};

/** The app's jobRef(): "PU-4F8K2M" — never the Firebase id. */
function jobReference(job, jobId) {
  return jobRef(jobId, job.type);
}

/** A driver's E-ID, the app's staffRef(): "DRV-Q2N7HC". */
function staffRef(uid) {
  return publicRef("DRV", uid);
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
  if (job.type === "supplyDrop") return "supply drop-off";
  return job.type === "delivery" ? "delivery" : "pickup";
}

/** Whether a Firestore timestamp field went from unset to set. */
function newlySet(before, after, field) {
  return !before[field] && !!after[field];
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
    title: `New ${kind(job)} assigned — ${jobReference(job, jobId)}`,
    body: [jobWhen(job), where,
      job.type === "supplyDrop" ? "supplies" : itemCount(job)]
        .filter(Boolean).join(" · "),
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
  // A Path A supply drop-off travels with its pickup: one set of messages.
  if (job.type === "supplyDrop" && job.linkedJobId) return [];
  if (job.driverId) return [assignedMessage(job, jobId)];
  const who = clientName ? `${clientName} · ` : "";
  const ref = jobReference(job, jobId);
  const adminType = job.type === "delivery" ?
    NOTIFY.deliveryRequested :
    NOTIFY.jobScheduled;
  if (job.status === "pendingConfirmation") {
    const extras = [
      job.suppliesFirst ? "supplies first" : "",
      job.helperHours > 0 ? `${job.helperHours}h packing help` : "",
    ].filter(Boolean).join(", ");
    return [{
      to: "admins",
      type: adminType,
      title: `New ${kind(job)} to confirm — ${ref}`,
      body: `${who}${itemCount(job)} · ${jobWhen(job)}` +
        (extras ? ` · ${extras}` : ""),
      entityType: "job",
      entityId: jobId,
    }, {
      to: "client",
      type: NOTIFY.bookingReceived,
      title: job.type === "delivery" ?
        "Delivery request received" :
        "Pickup booking received",
      body: `We've got your ${kind(job)} for ${jobWhen(job)} (${ref}). ` +
        "We'll confirm it shortly.",
      entityType: "job",
      entityId: jobId,
    }];
  }
  return [{
    to: "admins",
    type: adminType,
    title: `${capitalise(kind(job))} awaiting a driver — ${ref}`,
    body: `${who}${itemCount(job)} · ${jobWhen(job)}`,
    entityType: "job",
    entityId: jobId,
  }];
}

/**
 * Messages for a job update: confirmed or declined, driver (re)assigned,
 * on the way, arrived, collected, received into storage, completed or
 * cancelled. Unit statuses are settled by the app in the same transaction
 * as the job (JobRepository) — this only notifies.
 * @param {object} before
 * @param {object} after
 * @param {string} jobId
 * @param {{driverName?: string}} context who is driving, for the client
 * @return {Array<object>}
 */
function jobUpdatedMessages(before, after, jobId, context = {}) {
  const out = [];
  const ref = jobReference(after, jobId);
  const type = after.type;
  const what = itemCount(after);
  const closed = after.status === "completed" || after.status === "cancelled";
  const pairedSupply = type === "supplyDrop" && after.linkedJobId;

  if (after.driverId && after.driverId !== before.driverId && !closed) {
    out.push(assignedMessage(after, jobId));
  }

  const client = (fields) => ({
    to: "client",
    entityType: "job",
    entityId: jobId,
    ...fields,
  });

  // Driver check-ins — the client sees who is coming and their E-ID.
  if (newlySet(before, after, "departedAt") && after.status === "inProgress") {
    const badge = after.driverId ? ` (E-ID ${staffRef(after.driverId)})` : "";
    const who = context.driverName ?
      `${context.driverName}${badge}` :
      `Your driver${badge}`;
    out.push(client({
      type: NOTIFY.driverEnRoute,
      title: type === "delivery" ?
        "Your delivery is on its way" :
        "Your driver is on the way",
      body: `${who} is on the way for your ${kind(after)} (${ref}). ` +
        "Check the E-ID on their badge when they arrive.",
    }));
  }
  if (newlySet(before, after, "arrivedAt") && after.status === "inProgress") {
    out.push(client({
      type: NOTIFY.driverArrived,
      title: "Your driver has arrived",
      body: `Your driver is at ${place(after) || "your address"} ` +
        `for ${ref}.`,
    }));
  }

  if (before.status === after.status) return out;

  if (before.status === "pendingConfirmation" &&
    (after.status === "scheduled" || after.status === "assigned")) {
    out.push(client({
      type: NOTIFY.bookingConfirmed,
      title: `Your ${kind(after)} is confirmed`,
      body: `${capitalise(kind(after))} ${ref} is booked for ` +
        `${jobWhen(after)}.` +
        (type === "pickup" ? " Print your labels from My Storage while " +
          "you pack." : ""),
    }));
    return out;
  }
  if (before.status === "pendingConfirmation" &&
    after.status === "cancelled") {
    if (pairedSupply) return out;
    const reason = after.cancelReason ? ` ${after.cancelReason}` : "";
    out.push(client({
      type: NOTIFY.bookingDeclined,
      title: `We couldn't confirm your ${kind(after)}`,
      body: `${ref} (${jobWhen(after)}) wasn't confirmed.${reason} ` +
        "Contact us and we'll find a time that works.",
    }));
    return out;
  }

  switch (after.status) {
    case "collected":
      out.push(client({
        type: NOTIFY.pickupConfirmed,
        title: "Your items are collected",
        body: `${capitalise(what)} collected and on the way to secure ` +
          `storage (${ref}).`,
      }));
      break;
    case "completed":
      out.push(client(type === "pickup" ? {
        type: NOTIFY.unitsReceived,
        title: "Your items are in storage",
        body: `${capitalise(what)} checked in at our facility (${ref}). ` +
          "See photos and details under My Storage.",
      } : type === "supplyDrop" ? {
        type: NOTIFY.suppliesDelivered,
        title: "Your packing supplies are here",
        body: "Pack and label your boxes with the printed QR labels " +
          `before your pickup (${ref}).`,
      } : {
        type: NOTIFY.deliveryCompleted,
        title: "Delivery complete",
        body: `${capitalise(what)} delivered and signed for` +
          (after.recipientName ? ` by ${after.recipientName}` : "") +
          ` (${ref}).`,
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
      if (!pairedSupply) out.push(client({
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
 * Where tapping a notification takes [role]. Drivers and clients open the
 * job itself; admins open the jobs list.
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
      if (n.entityType === "issue") return "/admin/issues";
      return "/admin/notifications";
    case "driver":
      if (n.entityType === "job" && id) return `/driver/jobs/${id}`;
      return "/driver/notifications";
    default:
      if (n.entityType === "job") {
        return id ? `/client/orders/${id}` : "/client/orders";
      }
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
  [NOTIFY.bookingReceived]: "bookingUpdatesEmail",
  [NOTIFY.bookingConfirmed]: "bookingUpdatesEmail",
  [NOTIFY.bookingDeclined]: "bookingUpdatesEmail",
  [NOTIFY.jobStarted]: "pickupStartedEmail",
  [NOTIFY.driverEnRoute]: "pickupStartedEmail",
  [NOTIFY.unitsReceived]: "deliveryCompletedEmail",
  [NOTIFY.suppliesDelivered]: "deliveryCompletedEmail",
  [NOTIFY.pickupConfirmed]: "deliveryCompletedEmail",
  [NOTIFY.deliveryCompleted]: "deliveryCompletedEmail",
  [NOTIFY.invoiceReady]: "invoiceReadyEmail",
  [NOTIFY.invoicePaid]: "invoiceReadyEmail",
  [NOTIFY.storageThreshold]: "storageThresholdEmail",
};
const EMAIL_PREF_DEFAULTS = {
  bookingUpdatesEmail: true,
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
  staffRef,
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
