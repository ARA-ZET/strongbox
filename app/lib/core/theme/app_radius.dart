import 'package:flutter/widgets.dart';

import 'tokens.g.dart';

/// Border-radius scale. Never hardcode radii — use these.
///
/// Values come from the shared design tokens (`packages/tokens/tokens.json`).
class AppRadius {
  AppRadius._();

  /// Inputs, buttons.
  static const sm = BorderRadius.all(Radius.circular(DesignTokens.radiusSm));

  /// Cards, modals.
  static const md = BorderRadius.all(Radius.circular(DesignTokens.radiusMd));

  /// Large panels.
  static const lg = BorderRadius.all(Radius.circular(DesignTokens.radiusLg));

  /// Status chips / full pill.
  static const pill = BorderRadius.all(Radius.circular(DesignTokens.radiusPill));
}
