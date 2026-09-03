import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadow.dart';
import '../theme/app_spacing.dart';

/// Icon-less stat card for fleet/reports (doc 11). Optional coloured left
/// border and trend badge.
class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.value,
    required this.label,
    this.trend,
    this.trendPositive = true,
    this.borderColour,
  });

  final String value;
  final String label;
  final String? trend;
  final bool trendPositive;
  final Color? borderColour;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.md,
        border: borderColour == null
            ? null
            : Border(left: BorderSide(color: borderColour!, width: 3)),
        boxShadow: AppShadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: textTheme.bodySmall?.copyWith(letterSpacing: 0.8)),
          const SizedBox(height: AppSpacing.sm),
          Text(value, style: textTheme.displaySmall),
          if (trend != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              trend!,
              style: textTheme.bodySmall?.copyWith(
                color: trendPositive
                    ? AppColors.statusSuccess
                    : AppColors.statusError,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
