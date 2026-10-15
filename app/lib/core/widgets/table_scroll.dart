import 'package:flutter/material.dart';

/// Horizontal scrolling for a table whose rows use `Expanded` cells.
///
/// Fills the available width, but never squeezes below [minWidth] — on
/// narrow screens the table scrolls sideways instead. The fixed width is
/// what matters: inside a horizontal scroll view the width is otherwise
/// unbounded, `Expanded` cells cannot lay out, and the table renders
/// nothing. Use this instead of a hand-built `SingleChildScrollView` +
/// `ConstrainedBox(minWidth: …)`.
class TableScroll extends StatelessWidget {
  const TableScroll({super.key, required this.minWidth, required this.child});

  final double minWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width:
              constraints.maxWidth.isFinite && constraints.maxWidth > minWidth
              ? constraints.maxWidth
              : minWidth,
          child: child,
        ),
      ),
    );
  }
}
