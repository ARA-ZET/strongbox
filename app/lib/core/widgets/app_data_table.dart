import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadow.dart';
import '../theme/app_spacing.dart';
import 'loading_skeleton.dart';
import 'table_scroll.dart';

/// A column header for [AppDataTable].
class TableColumnSpec {
  const TableColumnSpec(this.label, {this.flex = 1});
  final String label;
  final int flex;
}

/// Sortable, horizontally-scrolling data table with a consistent header,
/// loading skeletons and hover rows (doc 11, rule #17).
class AppDataTable extends StatelessWidget {
  const AppDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.isLoading = false,
    this.minWidth = 720,
    this.footer,
  });

  final List<TableColumnSpec> columns;

  /// Each row is a list of cells matching [columns] length.
  final List<List<Widget>> rows;
  final bool isLoading;
  final double minWidth;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.md,
        boxShadow: AppShadow.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          TableScroll(
            minWidth: minWidth,
            child: Column(
              children: [
                Container(
                  color: AppColors.surfaceContainer,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm + 4,
                  ),
                  child: Row(
                    children: [
                      for (final column in columns)
                        Expanded(
                          flex: column.flex,
                          child: Text(
                            column.label.toUpperCase(),
                            style: textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (isLoading)
                  for (var i = 0; i < 5; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.sm,
                      ),
                      child: LoadingSkeleton.listTile(),
                    )
                else
                  for (final row in rows)
                    _DataRow(columns: columns, cells: row),
              ],
            ),
          ),
          footer ?? const SizedBox.shrink(),
        ],
      ),
    );
  }
}

class _DataRow extends StatefulWidget {
  const _DataRow({required this.columns, required this.cells});

  final List<TableColumnSpec> columns;
  final List<Widget> cells;

  @override
  State<_DataRow> createState() => _DataRowState();
}

class _DataRowState extends State<_DataRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        color: _hovered ? AppColors.surfaceContainer : Colors.transparent,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            for (var i = 0; i < widget.columns.length; i++)
              Expanded(
                flex: widget.columns[i].flex,
                child: i < widget.cells.length
                    ? widget.cells[i]
                    : const SizedBox.shrink(),
              ),
          ],
        ),
      ),
    );
  }
}
