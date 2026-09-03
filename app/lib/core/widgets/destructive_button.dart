import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

/// Red button for dangerous actions (doc 11).
class DestructiveButton extends StatelessWidget {
  const DestructiveButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.fullWidth = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final style = ElevatedButton.styleFrom(
      backgroundColor: AppColors.statusError,
      foregroundColor: Colors.white,
      minimumSize: Size(fullWidth ? double.infinity : 0, 48),
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sm),
    );

    if (icon != null) {
      return ElevatedButton.icon(
        style: style,
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
      );
    }
    return ElevatedButton(style: style, onPressed: onPressed, child: Text(label));
  }
}
