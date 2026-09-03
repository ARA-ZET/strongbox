import 'tokens.g.dart';

/// All StrongBox colour constants. Never hardcode hex values elsewhere.
///
/// Values come from the shared design tokens (`packages/tokens/tokens.json`),
/// generated into [DesignTokens]. Edit the JSON, run `node packages/tokens/build.mjs`.
class AppColors {
  AppColors._();

  // Brand
  static const navy = DesignTokens.navy;
  static const amber = DesignTokens.amber;
  static const amberDark = DesignTokens.amberDark;

  // Backgrounds
  static const scaffold = DesignTokens.scaffold;
  static const surface = DesignTokens.surface;
  static const surfaceContainer = DesignTokens.surfaceContainer;

  // Text
  static const textPrimary = DesignTokens.textPrimary;
  static const textSecondary = DesignTokens.textSecondary;
  static const textHint = DesignTokens.textHint;

  // Border
  static const border = DesignTokens.border;

  // Overlays
  static const overlay = DesignTokens.overlay; // 50% black
  static const cardShadow = DesignTokens.cardShadow; // 8% black

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
