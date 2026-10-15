/// Firestore top-level collection names (camelCase plural).
class Collections {
  Collections._();

  static const tenants = 'tenants';
  static const users = 'users';
  static const clients = 'clients';
  static const storageUnits = 'storageUnits';
  static const items = 'items';
  static const qrCodes = 'qrCodes';
  static const qrBatches = 'qrBatches';
  static const jobs = 'jobs';
  static const photos = 'photos';
  static const auditEvents = 'auditEvents';
  static const notifications = 'notifications';
  static const issueReports = 'issueReports';
  static const driverShifts = 'driverShifts';

  /// Fleet assets: cars, bakkies, vans, trucks and trailers.
  static const vehicles = 'vehicles';

  /// One doc per tenant, id = tenantId. Public read — the website shows it.
  static const priceLists = 'priceLists';

  /// Billing. `invoices` is written by the monthlyInvoices Cloud Function;
  /// `customers` / `subscriptions` are reserved for a future card provider.
  static const customers = 'customers';
  static const subscriptions = 'subscriptions';
  static const invoices = 'invoices';

  /// Outbound email queue — sent by the onMailCreated function.
  static const mail = 'mail';

  /// Job timeline events subcollection: jobs/{jobId}/events.
  static const jobEvents = 'events';
}
