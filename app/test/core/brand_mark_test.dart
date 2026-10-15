import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:strong_box/core/theme/app_colors.dart';
import 'package:strong_box/core/widgets/brand_logo.dart';

/// The app's logo copies the marketing site's navbar/footer logo. These fail if
/// either side changes on its own — update `BrandMark` and the site together.
void main() {
  test('site navbar and footer still use the filled package_2 glyph', () {
    for (final file in ['Navbar.tsx', 'Footer.tsx']) {
      final source = File(
        '../web/components/$file',
      ).readAsStringSync().replaceAll(RegExp(r'\s+'), ' ');
      expect(
        source,
        contains('material-symbols-filled"> package_2 </span> StrongBox'),
        reason: 'web/components/$file logo changed — mirror it in BrandMark',
      );
    }
  });

  testWidgets('BrandLogo matches the navbar: filled package_2 + wordmark', (
    tester,
  ) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: BrandLogo())),
      ),
    );
    // Inter isn't bundled in tests; the fallback font is fine here.
    tester.takeException();

    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.icon, Symbols.package_2);
    expect(icon.fill, 1);
    expect(icon.size, 30);
    expect(icon.color, AppColors.accentDeep);
    expect(find.text('StrongBox'), findsOneWidget);
  });
}
