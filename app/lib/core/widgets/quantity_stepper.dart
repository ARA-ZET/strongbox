import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// Compact `− n +` control used wherever a count is edited inline —
/// box quantities, loose-item counts, packers and packing hours.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 99,
    this.emphasiseAdd = false,
    this.dense = false,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  /// Renders the `+` as a filled navy circle, as on the box cards.
  final bool emphasiseAdd;

  /// Tighter sizing for use inside table rows and the estimate panel.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final size = dense ? 28.0 : 36.0;

    return Container(
      padding: EdgeInsets.all(dense ? AppSpacing.xs / 2 : AppSpacing.xs),
      decoration: const BoxDecoration(
        color: AppColors.statusPendingBg,
        borderRadius: AppRadius.pill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: Icons.remove,
            size: size,
            onPressed: value > min ? () => onChanged(value - 1) : null,
            semanticLabel: 'Decrease',
          ),
          SizedBox(
            width: dense ? 28 : 36,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          _StepButton(
            icon: Icons.add,
            size: size,
            filled: emphasiseAdd,
            onPressed: value < max ? () => onChanged(value + 1) : null,
            semanticLabel: 'Increase',
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.size,
    required this.onPressed,
    required this.semanticLabel,
    this.filled = false,
  });

  final IconData icon;
  final double size;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final foreground = filled
        ? Colors.white
        : enabled
            ? AppColors.textPrimary
            : AppColors.textHint;

    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: filled && enabled ? AppColors.navy : Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(icon, size: size * 0.5, color: foreground),
          ),
        ),
      ),
    );
  }
}
