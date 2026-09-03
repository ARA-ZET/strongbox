import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/quote_pricing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadow.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/currency.dart';
import '../../../core/widgets/quantity_stepper.dart';
import '../providers/quote_draft_provider.dart';
import '../widgets/quote_shell.dart';
import 'quote_calculator_screen.dart' show BoxGlyph;

/// Step 1 — pick storage box tiers and quantities.
///
/// Design: `designs/client_designs/quote_select_boxes`.
class QuoteBoxesScreen extends ConsumerWidget {
  const QuoteBoxesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final quote = ref.watch(quoteDraftProvider);
    final draft = ref.read(quoteDraftProvider.notifier);

    return QuoteShell(
      currentStep: 0,
      onBack: () => context.go('/quote'),
      nextLabel: 'Next: Loose Items',
      onNext: () => context.go('/quote/items'),
      footerNote: quote.boxCount == 0
          ? 'No boxes yet — add loose items instead if nothing fits a box'
          : '${quote.boxCount} ${quote.boxCount == 1 ? "box" : "boxes"} · '
              '${formatZarMonthly(quote.boxesMonthlyZar)} · '
              'excluding pickup fee',
      showFooterTotal: false,
      child: LayoutBuilder(builder: (context, constraints) {
        final desktop = constraints.maxWidth > 900;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Choose Your Boxes',
                textAlign: TextAlign.center, style: textTheme.displaySmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Select the storage containers that best fit your needs.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: desktop ? 2 : 1,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: desktop ? 1.55 : 1.1,
              children: [
                for (final tier in QuotePricing.boxes)
                  _BoxTierCard(
                    tier: tier,
                    quantity: draft.boxQuantity(tier.size),
                    onChanged: (value) =>
                        draft.setBoxQuantity(tier.size, value),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const _AdviceBanner(
              text: 'Not sure? Our team can advise during collection — you '
                  'only pay for the boxes you actually fill.',
            ),
          ],
        );
      }),
    );
  }
}

class _BoxTierCard extends StatelessWidget {
  const _BoxTierCard({
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
    final selected = quantity > 0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.md,
        boxShadow: AppShadow.card,
        border: Border.all(
          color: selected ? AppColors.amberDark : AppColors.border,
          width: selected ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BoxGlyph(size: 44),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tier.name, style: textTheme.headlineSmall),
                    Text(tier.dimensionsCm,
                        style: textTheme.bodySmall
                            ?.copyWith(color: AppColors.textSecondary)),
                    Text('Max weight: ${tier.maxWeightKg}kg',
                        style: textTheme.bodySmall
                            ?.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Text(
                formatZarMonthly(tier.monthlyZar),
                style: textTheme.titleMedium
                    ?.copyWith(color: AppColors.amberDark),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: AppRadius.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final suit in tier.suits)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline,
                            size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                            child: Text(suit, style: textTheme.bodyMedium)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Text('Quantity', style: textTheme.labelLarge),
              const Spacer(),
              QuantityStepper(
                value: quantity,
                emphasiseAdd: true,
                onChanged: onChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdviceBanner extends StatelessWidget {
  const _AdviceBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.statusPastDueBg,
        borderRadius: AppRadius.md,
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: AppColors.statusPastDue),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.statusPastDue),
            ),
          ),
        ],
      ),
    );
  }
}
