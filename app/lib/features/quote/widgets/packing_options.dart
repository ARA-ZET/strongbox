import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/quote_pricing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/currency.dart';
import '../../../core/widgets/quantity_stepper.dart';
import '../providers/quote_draft_provider.dart';

/// "Pack it myself" vs "I need help" — the switch that reveals
/// [PackingCrewPicker].
class PackingChoice extends StatelessWidget {
  const PackingChoice({
    super.key,
    required this.packingRequired,
    required this.onChanged,
  });

  final bool packingRequired;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    // ListTiles paint their ink onto the nearest Material ancestor. Both
    // callers sit inside a coloured Container, so supply a transparent
    // Material here rather than letting the splash disappear behind it.
    return Material(
      type: MaterialType.transparency,
      child: RadioGroup<bool>(
        groupValue: packingRequired,
        onChanged: (value) => onChanged(value ?? false),
        child: const Column(
          children: [
            RadioListTile<bool>(
              value: false,
              contentPadding: EdgeInsets.zero,
              title: Text("No, I'll pack myself"),
            ),
            RadioListTile<bool>(
              value: true,
              contentPadding: EdgeInsets.zero,
              title: Text('Yes, I need help'),
              subtitle: Text('Our crew wraps and boxes everything on the day.'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Packer count and hours, with the running packing fee. Shared by the
/// calculator and the services step so both price packing identically.
class PackingCrewPicker extends ConsumerWidget {
  const PackingCrewPicker({super.key, required this.desktop});

  final bool desktop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final quote = ref.watch(quoteDraftProvider);
    final draft = ref.read(quoteDraftProvider.notifier);

    final packers = _CrewField(
      label: 'NUMBER OF PACKERS',
      value: quote.packers,
      min: 1,
      max: 6,
      onChanged: draft.setPackers,
    );
    final hours = _CrewField(
      label: 'HOURS REQUIRED',
      value: quote.packingHours,
      min: QuotePricing.minPackingHours,
      max: 12,
      onChanged: draft.setPackingHours,
    );
    final total = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Min ${QuotePricing.minPackingHours} hours',
            style: textTheme.bodySmall?.copyWith(color: AppColors.amberDark)),
        Text('Est. ${formatZar(quote.packingFeeZar)}',
            style: textTheme.titleLarge),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: AppRadius.md,
      ),
      child: desktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                packers,
                const SizedBox(width: AppSpacing.lg),
                hours,
                const Spacer(),
                total,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                packers,
                const SizedBox(height: AppSpacing.md),
                hours,
                const SizedBox(height: AppSpacing.md),
                Align(alignment: Alignment.centerRight, child: total),
              ],
            ),
    );
  }
}

class _CrewField extends StatelessWidget {
  const _CrewField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 0.6,
              ),
        ),
        const SizedBox(height: AppSpacing.xs),
        QuantityStepper(
          value: value,
          min: min,
          max: max,
          dense: true,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
