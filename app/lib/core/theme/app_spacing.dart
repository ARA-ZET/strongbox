import 'tokens.g.dart';

/// Spacing scale (multiples of 4). Never hardcode spacing — use these.
///
/// Values come from the shared design tokens (`packages/tokens/tokens.json`).
class AppSpacing {
  AppSpacing._();

  static const double xs = DesignTokens.spaceXs;
  static const double sm = DesignTokens.spaceSm;
  static const double md = DesignTokens.spaceMd;
  static const double lg = DesignTokens.spaceLg;
  static const double xl = DesignTokens.spaceXl;
  static const double xxl = DesignTokens.spaceXxl;
}
