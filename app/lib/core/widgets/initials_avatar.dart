import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

/// Circular avatar showing a person's initials; grey "--" when [name] is null
/// or empty (e.g. an unassigned driver).
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    this.name,
    this.size = 32,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String? name;
  final double size;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final trimmed = name?.trim() ?? '';
    final unassigned = trimmed.isEmpty;

    final initials = unassigned
        ? '--'
        : trimmed
            .split(RegExp(r'\s+'))
            .take(2)
            .map((word) => word[0].toUpperCase())
            .join();

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: unassigned
            ? AppColors.statusPendingBg
            : backgroundColor ?? AppColors.navy,
        shape: BoxShape.circle,
      ),
      child: Text(
        initials,
        style: GoogleFonts.inter(
          fontSize: size * 0.35,
          fontWeight: FontWeight.w600,
          color: unassigned
              ? AppColors.statusPending
              : foregroundColor ?? Colors.white,
        ),
      ),
    );
  }
}
