import 'package:flutter/widgets.dart';

import 'app_colors.dart';

/// Elevation presets. Use instead of ad-hoc BoxShadow lists.
class AppShadow {
  AppShadow._();

  static const List<BoxShadow> card = [
    BoxShadow(blurRadius: 8, color: AppColors.cardShadow, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> modal = [
    BoxShadow(blurRadius: 24, color: AppColors.cardShadow, offset: Offset(0, 8)),
  ];
}
