import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Horizontal stepper. Completed steps: accent filled circle with checkmark.
/// Active step: accent outlined circle with number. Future steps: grey.
class StepIndicator extends StatelessWidget {
  const StepIndicator({
    super.key,
    required this.steps,
    required this.currentStep,
  });

  final List<String> steps;

  /// Zero-based index of the active step.
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color:
                    i <= currentStep ? AppColors.accentDeep : AppColors.border,
              ),
            ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StepCircle(index: i, currentStep: currentStep),
              const SizedBox(height: 6),
              Text(
                steps[i],
                style: textTheme.bodySmall?.copyWith(
                  fontWeight:
                      i == currentStep ? FontWeight.w600 : FontWeight.w400,
                  color: i <= currentStep
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _StepCircle extends StatelessWidget {
  const _StepCircle({required this.index, required this.currentStep});

  final int index;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final completed = index < currentStep;
    final active = index == currentStep;

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: completed ? AppColors.accent : Colors.transparent,
        border: Border.all(
          color: completed || active ? AppColors.accentDeep : AppColors.border,
          width: 2,
        ),
      ),
      child: Center(
        child: completed
            ? const Icon(Icons.check, size: 18, color: AppColors.onAccent)
            : Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: active ? AppColors.accentDeep : AppColors.textSecondary,
                ),
              ),
      ),
    );
  }
}
