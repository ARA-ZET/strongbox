/**
 * Names shared with the Flutter app. Keep in sync with
 * app/lib/core/constants/firestore_collections.dart and
 * app/lib/core/enums/app_enums.dart — the app parses these strings back
 * into enums.
 */

const COL = {
  users: "users",
  clients: "clients",
  storageUnits: "storageUnits",
  jobs: "jobs",
  qrCodes: "qrCodes",
  auditEvents: "auditEvents",
  notifications: "notifications",
  invoices: "invoices",
  priceLists: "priceLists",
  tenants: "tenants",
  issueReports: "issueReports",
  // Read by the "Trigger Email from Firestore" extension (firestore-send-email).
  mail: "mail",
};

/** StorageStatus values that are charged for (StorageStatusX.isBillable). */
const BILLABLE_STATUSES = new Set(["inTransit", "inStorage", "pendingDelivery"]);

/** NotificationType values written by these functions. */
const NOTIFY = {
  jobScheduled: "jobScheduled",
  jobAssigned: "jobAssigned",
  jobStarted: "jobStarted",
  jobCompleted: "jobCompleted",
  jobCancelled: "jobCancelled",
  pickupConfirmed: "pickupConfirmed",
  deliveryCompleted: "deliveryCompleted",
  deliveryRequested: "deliveryRequested",
  invoiceReady: "invoiceReady",
  invoicePaid: "invoicePaid",
  qrUnlinkedAlert: "qrUnlinkedAlert",
  storageThreshold: "storageThreshold",
  issueReported: "issueReported",
  systemAlert: "systemAlert",
};

/** AuditAction values written by these functions. */
const AUDIT = {
  invoiceIssued: "invoiceIssued",
  subscriptionUpdated: "subscriptionUpdated",
  userRoleChanged: "userRoleChanged",
};

/** actorId on audit events written by these functions. */
const SYSTEM_ACTOR = "system";

/** The business runs on SAST (UTC+2, no daylight saving). */
const TIME_ZONE = "Africa/Johannesburg";
const SAST_OFFSET_MS = 2 * 60 * 60 * 1000;

/** Days after the 1st that a month's invoice falls due. */
const INVOICE_DUE_DAYS = 7;

/** Unlinked QR codes older than this are flagged to admins. */
const QR_UNLINKED_DAYS = 30;

const APP_URL = "https://app.strongbox.co.za";

module.exports = {
  COL,
  BILLABLE_STATUSES,
  NOTIFY,
  AUDIT,
  SYSTEM_ACTOR,
  TIME_ZONE,
  SAST_OFFSET_MS,
  INVOICE_DUE_DAYS,
  QR_UNLINKED_DAYS,
  APP_URL,
};
