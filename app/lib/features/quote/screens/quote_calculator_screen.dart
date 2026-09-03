import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/quote_pricing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadow.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/currency.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/quantity_stepper.dart';
import '../../../core/widgets/section_header.dart';
import '../providers/quote_draft_provider.dart';
import '../widgets/add_loose_item_dialog.dart';
import '../widgets/packing_options.dart';
import '../widgets/quote_estimate_panel.dart';
import '../widgets/quote_shell.dart';
import '../widgets/vehicle_option_card.dart';

/// Public entry point to the quote flow — everything on one page with a
/// live price panel, so a visitor gets a number without signing up or
/// stepping through a wizard.
///
/// Design: `designs/client_designs/quick_storage_calculator`.
class QuoteCalculatorScreen extends ConsumerWidget {
  const QuoteCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quote = ref.watch(quoteDraftProvider);

    return QuoteShell(
      child: LayoutBuilder(builder: (context, constraints) {
        final desktop = constraints.maxWidth > 900;

        final form = _CalculatorForm(desktop: desktop);
        final panel = QuoteEstimatePanel(
          quote: quote,
          title: 'Price Estimate',
          footnote: 'Prices include standard insurance up to '
              '${formatZar(QuotePricing.includedInsuranceZar)}.',
          actions: [
            PrimaryButton(
              label: 'Continue to Full Quote',
              onPressed: quote.isEmpty
                  ? null
                  : () => context.go(quoteSteps.first.path),
            ),
          ],
        );

        if (!desktop) {
          return Column(
            children: [
              form,
              const SizedBox(height: AppSpacing.md),
              panel,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: form),
            const SizedBox(width: AppSpacing.lg),
            Expanded(flex: 2, child: panel),
          ],
        );
      }),
    );
  }
}

class _CalculatorForm extends ConsumerWidget {
  const _CalculatorForm({required this.desktop});

  final bool desktop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final quote = ref.watch(quoteDraftProvider);
    final draft = ref.read(quoteDraftProvider.notifier);

    return Container(
      padding: EdgeInsets.all(desktop ? AppSpacing.lg : AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.md,
        boxShadow: AppShadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Storage Calculator', style: textTheme.displaySmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Instant price estimate — no signup needed.',
            style: textTheme.bodyMedium
                ?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),

          const SectionHeader(title: 'Storage Boxes'),
          const Divider(),
          for (final tier in QuotePricing.boxes)
            _BoxRow(
              tier: tier,
              quantity: draft.boxQuantity(tier.size),
              onChanged: (value) => draft.setBoxQuantity(tier.size, value),
            ),

          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Loose Items'),
          const Divider(),
          if (quote.looseItems.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text(
                'No items added yet',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            for (final item in quote.looseItems)
              _LooseItemRow(
                emoji: item.emoji,
                name: item.name,
                subtitle: item.dimensionsLabel,
                price: '${formatZarExact(item.lineMonthlyZar)}/mo',
                quantity: item.quantity,
                onQuantityChanged: (value) =>
                    draft.setLooseItemQuantity(item.id, value),
                onRemove: () => draft.removeLooseItem(item.id),
              ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => AddLooseItemDialog.show(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Loose Item'),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Pickup Vehicle'),
          const Divider(),
          const SizedBox(height: AppSpacing.sm),
          VehicleOptionGrid(
            selected: quote.vehicle,
            recommended: quote.recommendedVehicle,
            wrap: !desktop,
            onSelected: draft.setVehicle,
          ),

          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Packing Service'),
          const Divider(),
          PackingChoice(
            packingRequired: quote.packingRequired,
            onChanged: draft.setPackingRequired,
          ),
          if (quote.packingRequired) ...[
            const SizedBox(height: AppSpacing.sm),
            PackingCrewPicker(desktop: desktop),
          ],
        ],
      ),
    );
  }
}

class _BoxRow extends StatelessWidget {
  const _BoxRow({
    required this.tier,
    required this.quantity,
    required this.onChanged,
  });

  final BoxTier tier;
  final int quantity;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          const BoxGlyph(),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tier.name, style: textTheme.titleMedium),
                Text(formatZarMonthly(tier.monthlyZar),
                    style: textTheme.bodySmall
                        ?.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          QuantityStepper(value: quantity, onChanged: onChanged),
        ],
      ),
    );
  }
}

/// Amber disc with a box icon, the visual marker for a storage tier.
class BoxGlyph extends StatelessWidget {
  const BoxGlyph({super.key, this.size = 36});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.amber,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.inventory_2_outlined,
          size: size * 0.55, color: AppColors.amberDark),
    );
  }
}

class _LooseItemRow extends StatelessWidget {
  const _LooseItemRow({
    required this.emoji,
    required this.name,
    required this.subtitle,
    required this.price,
    required this.quantity,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  final String emoji;
  final String name;
  final String subtitle;
  final String price;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: textTheme.titleMedium),
                Text(subtitle,
                    style: textTheme.bodySmall
                        ?.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(price,
              style: textTheme.bodyMedium
                  ?.copyWith(color: AppColors.amberDark)),
          const SizedBox(width: AppSpacing.sm),
          QuantityStepper(
            value: quantity,
            min: 1,
            dense: true,
            onChanged: onQuantityChanged,
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline,
                size: 20, color: AppColors.statusError),
            tooltip: 'Remove ${name.toLowerCase()}',
          ),
        ],
      ),
    );
  }
}
