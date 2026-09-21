import 'tokens.g.dart';

/// All StrongBox colour constants. Never hardcode hex values elsewhere.
///
/// Values come from the shared design tokens (`packages/tokens/tokens.json`),
/// generated into [DesignTokens]. Edit the JSON, run `node packages/tokens/build.mjs`.
/// The palette mirrors the marketing site (web/tailwind.config.ts).
class AppColors {
  AppColors._();

  // Brand — navy family (dark grounds, headings)
  static const navyDeep = DesignTokens.navyDeep;
  static const navy = DesignTokens.navy;
  static const navySoft = DesignTokens.navySoft;

  // Brand — blue accent
  /// Primary CTA fill, active states, progress. As *text* use [accentDeep].
  static const accent = DesignTokens.accent;

  /// Links, emphasis text, borders and icons on light grounds.
  static const accentDeep = DesignTokens.accentDeep;

  /// Labels and icons on a solid [accent] fill.
  static const onAccent = DesignTokens.onAccent;

  /// Accent for icons and labels on navy / dark grounds.
  static const sky = DesignTokens.sky;

  /// Icon wells, chips, selected-state fills on white.
  static const skyTint = DesignTokens.skyTint;

  // Backgrounds
  static const scaffold = DesignTokens.scaffold;
  static const surface = DesignTokens.surface;
  static const surfaceContainer = DesignTokens.surfaceContainer;

  // Text
  static const textPrimary = DesignTokens.textPrimary;
  static const textSecondary = DesignTokens.textSecondary;
  static const textHint = DesignTokens.textHint;
  static const onNavy = DesignTokens.onNavy;
  static const onNavyVariant = DesignTokens.onNavyVariant;

  // Border
  static const border = DesignTokens.border;

  // Overlays
  static const overlay = DesignTokens.overlay; // 50% navy-deep
  static const cardShadow = DesignTokens.cardShadow; // 4% navy-deep
  static const cardShadowStrong = DesignTokens.cardShadowStrong; // 8% navy-deep

  // Status
  static const statusSuccess = DesignTokens.statusSuccess;
  static const statusSuccessBg = DesignTokens.statusSuccessBg;
  static const statusWarning = DesignTokens.statusWarning;
  static const statusWarningBg = DesignTokens.statusWarningBg;
  static const statusError = DesignTokens.statusError;
  static const statusErrorBg = DesignTokens.statusErrorBg;
  static const statusPending = DesignTokens.statusPending;
  static const statusPendingBg = DesignTokens.statusPendingBg;
  static const statusPastDue = DesignTokens.statusPastDue;
  static const statusPastDueBg = DesignTokens.statusPastDueBg;
}
