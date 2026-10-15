import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../theme/app_colors.dart';

/// The StrongBox logo glyph — the marketing site's navbar/footer logo
/// (web/components/Navbar.tsx, Footer.tsx): Material Symbols Outlined
/// `package_2`, filled, with the same variation settings as the site's
/// `.material-symbols-filled` class (FILL 1, wght 400, GRAD 0, opsz 24).
///
/// accentDeep on light grounds; sky on navy grounds ([onDark]), as in the
/// site footer.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 30, this.onDark = false});

  final double size;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Symbols.package_2,
      size: size,
      fill: 1,
      weight: 400,
      grade: 0,
      opticalSize: 24,
      color: onDark ? AppColors.sky : AppColors.accentDeep,
      semanticLabel: 'StrongBox',
    );
  }
}

/// Glyph + "StrongBox" wordmark, matching the site navbar: 30px glyph, 8px gap,
/// 22px bold wordmark — navyDeep on light, white on dark. [fontSize] scales
/// all three together.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.fontSize = 22, this.onDark = false});

  final double fontSize;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final scale = fontSize / 22;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BrandMark(size: (30 * scale).roundToDouble(), onDark: onDark),
        SizedBox(width: (8 * scale).roundToDouble()),
        Text(
          'StrongBox',
          style: GoogleFonts.inter(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: onDark ? Colors.white : AppColors.navyDeep,
          ),
        ),
      ],
    );
  }
}
