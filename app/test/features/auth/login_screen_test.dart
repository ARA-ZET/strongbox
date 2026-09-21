import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strong_box/core/theme/app_theme.dart';
import 'package:strong_box/features/auth/screens/login_screen.dart';

/// The desktop sign-in must fit on one screen on common laptop and desktop
/// browser viewports (screen size minus browser chrome) — no scrolling.
void main() {
  const viewports = <String, Size>{
    '1280×720 laptop': Size(1280, 610),
    '1366×768 laptop': Size(1366, 640),
    '1440×900 laptop': Size(1440, 780),
    '1536×864 laptop': Size(1536, 740),
    '1920×1080 desktop': Size(1920, 950),
    '1024×768 small laptop': Size(1024, 640),
  };

  for (final MapEntry(key: name, value: size) in viewports.entries) {
    testWidgets('fits without scrolling at $name', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(ProviderScope(
        child: MaterialApp(theme: AppTheme.light, home: const LoginScreen()),
      ));
      await tester.pumpAndSettle();

      final scrollable = tester.state<ScrollableState>(find.byType(Scrollable).first);
      expect(scrollable.position.maxScrollExtent, 0,
          reason: 'content is ${scrollable.position.maxScrollExtent}px taller '
              'than the ${size.height.toInt()}px viewport');
      expect(find.text('Sign In'), findsOneWidget);
    });
  }
}
