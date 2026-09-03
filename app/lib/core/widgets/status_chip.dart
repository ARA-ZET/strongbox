import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

/// Pill-shaped status chip that auto-selects colours from a status string.
///
/// Accepts enum `.name` values (camelCase, e.g. `inStorage`) as well as the
/// legacy snake_case forms. Pass [label] to override the derived text.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status, this.label});

  final String status;
  final String? label;

  // Normalised (lowercased, separators stripped) status keys.
  static const _success = {
    'completed', 'active', 'delivered', 'instorage', 'available', 'paid'
  };
  static const _warning = {
    'inprogress', 'intransit', 'pendingdelivery', 'onjob', 'trialing'
  };
  // Everything else (scheduled, pending, pendingPickup, assigned, …) uses
  // the neutral pending style via the default branch.
  static const _error = {'cancelled', 'critical', 'archived', 'unpaid'};
  static const _pastDue = {'pastdue'};

  @override
  Widget build(BuildContext context) {
    final key = status.toLowerCase().replaceAll(RegExp('[_ ]'), '');

    final (Color bg, Color fg) = switch (key) {
      _ when _success.contains(key) =>
        (AppColors.statusSuccessBg, AppColors.statusSuccess),
      _ when _warning.contains(key) =>
        (AppColors.statusWarningBg, AppColors.statusWarning),
      _ when _error.contains(key) =>
        (AppColors.statusErrorBg, AppColors.statusError),
      _ when _pastDue.contains(key) =>
        (AppColors.statusPastDueBg, AppColors.statusPastDue),
      _ => (AppColors.statusPendingBg, AppColors.textSecondary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label ?? _humanise(status),
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: fg,
        ),
      ),
    );
  }

  /// "inStorage" / "in_storage" → "In Storage".
  static String _humanise(String raw) {
    final spaced = raw
        .replaceAll('_', ' ')
        .replaceAllMapped(RegExp('([a-z])([A-Z])'),
            (m) => '${m[1]} ${m[2]}');
    return spaced
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}
