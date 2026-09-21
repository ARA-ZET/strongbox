/// App-wide constants not tied to Firestore structure or theme.
class AppConstants {
  AppConstants._();

  /// v1 is single-tenant; every query is scoped to this id.
  static const defaultTenantId = 'strongbox-default';

  /// Max photo dimension (px) before upload compression.
  static const maxPhotoDimension = 1280;
}
