import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// "Showing X-Y of N" text with prev/next + page controls (doc 11).
class PaginationRow extends StatelessWidget {
  const PaginationRow({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChange,
    required this.showingFrom,
    required this.showingTo,
    required this.total,
    this.noun = 'items',
  });

  /// 1-indexed current page.
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChange;
  final int showingFrom;
  final int showingTo;
  final int total;
  final String noun;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Showing $showingFrom-$showingTo of $total $noun',
              style: textTheme.bodySmall,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 20),
            onPressed: currentPage > 1
                ? () => onPageChange(currentPage - 1)
                : null,
          ),
          Text('$currentPage / $totalPages',
              style: textTheme.bodySmall
                  ?.copyWith(color: AppColors.textPrimary)),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 20),
            onPressed: currentPage < totalPages
                ? () => onPageChange(currentPage + 1)
                : null,
          ),
        ],
      ),
    );
  }
}
