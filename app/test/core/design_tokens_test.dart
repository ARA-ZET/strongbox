import 'dart:convert';
import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strong_box/core/theme/app_colors.dart';
import 'package:strong_box/core/theme/app_radius.dart';
import 'package:strong_box/core/theme/app_spacing.dart';
import 'package:strong_box/core/theme/tokens.g.dart';

/// Guards the shared design tokens: fails if `tokens.g.dart` drifted from
/// `packages/tokens/tokens.json` (run `node packages/tokens/build.mjs`), or if
/// an `App*` constant stopped tracking the generated token.
void main() {
  final json = jsonDecode(
    File('../packages/tokens/tokens.json').readAsStringSync(),
  ) as Map<String, dynamic>;

  int hexToArgb(String hex) {
    final h = hex.replaceFirst('#', '');
    final rgb = h.substring(0, 6);
    final a = h.length == 8 ? h.substring(6, 8) : 'FF';
    return int.parse('$a$rgb', radix: 16);
  }

  test('generated colours match tokens.json', () {
    final colors = json['color'] as Map<String, dynamic>;
    expect(DesignTokens.navy.toARGB32(), hexToArgb(colors['navy'] as String));
    expect(DesignTokens.accent.toARGB32(), hexToArgb(colors['accent'] as String));
    expect(
      DesignTokens.statusPastDueBg.toARGB32(),
      hexToArgb(colors['statusPastDueBg'] as String),
    );
  });

  test('generated spacing / radius match tokens.json', () {
    final space = json['space'] as Map<String, dynamic>;
    final radius = json['radius'] as Map<String, dynamic>;
    expect(DesignTokens.spaceLg, (space['lg'] as num).toDouble());
    expect(DesignTokens.radiusMd, (radius['md'] as num).toDouble());
  });

  test('App* constants still delegate to DesignTokens', () {
    expect(AppColors.navy, DesignTokens.navy);
    expect(AppColors.accent, DesignTokens.accent);
    expect(AppSpacing.lg, DesignTokens.spaceLg);
    expect(AppRadius.md, BorderRadius.circular(DesignTokens.radiusMd));
  });
}
