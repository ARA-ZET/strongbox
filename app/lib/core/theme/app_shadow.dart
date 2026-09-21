import 'package:flutter/widgets.dart';

import 'app_colors.dart';

/// Elevation presets — the web's navy-tinted "tactile" shadows.
/// Use instead of ad-hoc BoxShadow lists.
class AppShadow {
  AppShadow._();

  static const List<BoxShadow> card = [
    BoxShadow(blurRadius: 20, color: AppColors.cardShadow, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> raised = [
    BoxShadow(
        blurRadius: 30, color: AppColors.cardShadowStrong, offset: Offset(0, 8)),
  ];

  static const List<BoxShadow> modal = [
    BoxShadow(
        blurRadius: 40, color: AppColors.cardShadowStrong, offset: Offset(0, 10)),
  ];
}
