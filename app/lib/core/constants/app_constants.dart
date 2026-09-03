/// App-wide constants not tied to Firestore structure or theme.
class AppConstants {
  AppConstants._();

  /// v1 is single-tenant; every query is scoped to this id.
  static const defaultTenantId = 'strongbox-default';

  /// Storage-unit allowance per subscription plan (0 = unlimited).
  static const planUnitLimits = <String, int>{
    'starter': 20,
    'professional': 100,
    'enterprise': 0,
  };

  /// Monthly plan pricing in Rand (0 = custom / contact sales).
  static const planPricesZar = <String, int>{
    'starter': 899,
    'professional': 3499,
    'enterprise': 0,
  };

  /// Max photo dimension (px) before upload compression.
  static const maxPhotoDimension = 1280;
}
