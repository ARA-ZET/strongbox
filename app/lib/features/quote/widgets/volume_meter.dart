import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

/// Volume gauge shown on the estimate panel and the quote summary: a
/// progress bar plus a block grid where each block is one slot of the
/// selected vehicle's capacity.
class VolumeMeter extends StatelessWidget {
  const VolumeMeter({
    super.key,
    required this.title,
    required this.volumeM3,
    required this.capacityM3,
    this.caption,
    this.onDark = false,
    this.blockColumns = 4,
    this.blockRows = 3,
  });

  final String title;
  final double volumeM3;

  /// Capacity the bar is measured against — the selected vehicle.
  final double capacityM3;

  /// Optional line under the meter, e.g. the everyday-size comparison.
  final String? caption;

  /// Renders for the navy estimate panel instead of a light card.
  final bool onDark;

  final int blockColumns;
  final int blockRows;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final fraction =
        capacityM3 <= 0 ? 0.0 : (volumeM3 / capacityM3).clamp(0.0, 1.0);
    final labelColour = onDark ? Colors.white70 : AppColors.textSecondary;
    final trackColour =
        onDark ? Colors.white.withValues(alpha: 0.15) : AppColors.border;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: onDark
            ? Colors.white.withValues(alpha: 0.06)
            : AppColors.surfaceContainer,
        borderRadius: AppRadius.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: textTheme.labelMedium?.copyWith(
                    color: labelColour,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              Text(
                '${volumeM3.toStringAsFixed(volumeM3 < 10 ? 1 : 0)} m³',
                style: textTheme.titleMedium?.copyWith(
                  color: onDark ? AppColors.amber : AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: AppRadius.pill,
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 8,
              backgroundColor: trackColour,
              valueColor: const AlwaysStoppedAnimation(AppColors.amber),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _BlockGrid(
            filled: (fraction * blockColumns * blockRows).round(),
            columns: blockColumns,
            rows: blockRows,
            onDark: onDark,
          ),
          if (caption != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              caption!,
              style: textTheme.bodySmall?.copyWith(
                color: labelColour,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BlockGrid extends StatelessWidget {
  const _BlockGrid({
    required this.filled,
    required this.columns,
    required this.rows,
    required this.onDark,
  });

  final int filled;
  final int columns;
  final int rows;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var row = 0; row < rows; row++) ...[
          if (row > 0) const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              for (var column = 0; column < columns; column++) ...[
                if (column > 0) const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Container(
                    height: 22,
                    decoration: BoxDecoration(
                      color: row * columns + column < filled
                          ? (onDark ? AppColors.amber : AppColors.amberDark)
                          : Colors.transparent,
                      borderRadius: AppRadius.sm,
                      border: Border.all(
                        color: onDark
                            ? Colors.white.withValues(alpha: 0.2)
                            : AppColors.border,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}
