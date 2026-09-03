import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/quote_pricing.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/models/quote.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadow.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/currency.dart';
import '../../../core/widgets/quantity_stepper.dart';
import '../providers/quote_draft_provider.dart';
import '../widgets/add_loose_item_dialog.dart';
import '../widgets/quote_shell.dart';

/// Step 2 — furniture and oversized items that will not fit in a box.
///
/// Design: `designs/client_designs/quote_loose_items`.
class QuoteLooseItemsScreen extends ConsumerStatefulWidget {
  const QuoteLooseItemsScreen({super.key});

  @override
  ConsumerState<QuoteLooseItemsScreen> createState() =>
      _QuoteLooseItemsScreenState();
}

class _QuoteLooseItemsScreenState
    extends ConsumerState<QuoteLooseItemsScreen> {
  /// null = the "All" tab.
  LooseItemCategory? _category;

  List<LooseItemPreset> get _visiblePresets => _category == null
      ? QuotePricing.looseItemPresets
      : QuotePricing.looseItemPresets
          .where((preset) => preset.category == _category)
          .toList();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final quote = ref.watch(quoteDraftProvider);

    return QuoteShell(
      currentStep: 1,
      onBack: () => context.go('/quote/boxes'),
      nextLabel: 'Next: Services',
      onNext: () => context.go('/quote/services'),
      child: LayoutBuilder(builder: (context, constraints) {
        final desktop = constraints.maxWidth > 900;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Loose Items',
                textAlign: TextAlign.center, style: textTheme.displaySmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Add furniture and oversized items that will not fit in a '
              'standard box. We handle everything from beds to office chairs.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            _CategoryFilter(
              selected: _category,
              onSelected: (value) => setState(() => _category = value),
            ),
            const SizedBox(height: AppSpacing.lg),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: desktop ? 3 : 2,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              // Taller than wide: emoji, name, price and the Add button
              // have to stack without clipping at phone widths.
              childAspectRatio: desktop ? 1.05 : 0.82,
              children: [
                for (final preset in _visiblePresets)
                  _PresetCard(
                    preset: preset,
                    onAdd: () => ref
                        .read(quoteDraftProvider.notifier)
                        .addPreset(preset),
                  ),
                _CustomItemCard(
                  onTap: () => AddLooseItemDialog.show(context),
                ),
              ],
            ),
            if (quote.looseItems.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              _AddedItemsCard(items: quote.looseItems),
            ],
          ],
        );
      }),
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter({required this.selected, required this.onSelected});

  final LooseItemCategory? selected;
  final ValueChanged<LooseItemCategory?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        ChoiceChip(
          label: const Text('All'),
          selected: selected == null,
          onSelected: (_) => onSelected(null),
        ),
        for (final category in LooseItemCategory.values)
          ChoiceChip(
            label: Text(category.label),
            selected: selected == category,
            onSelected: (_) => onSelected(category),
          ),
      ],
    );
  }
}

class _PresetCard extends StatelessWidget {
  const _PresetCard({required this.preset, required this.onAdd});

  final LooseItemPreset preset;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.md,
        boxShadow: AppShadow.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(preset.emoji, style: const TextStyle(fontSize: 34)),
          const SizedBox(height: AppSpacing.sm),
          Text(preset.name,
              textAlign: TextAlign.center, style: textTheme.titleMedium),
          Text('${formatZar(preset.monthlyZar)}/mo',
              style: textTheme.bodySmall
                  ?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onAdd,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.amberDark,
                side: const BorderSide(color: AppColors.amberDark),
              ),
              child: const Text('Add'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomItemCard extends StatelessWidget {
  const _CustomItemCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: AppColors.surfaceContainer,
      borderRadius: AppRadius.md,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.md,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: AppRadius.md,
            border: Border.all(color: AppColors.amberDark),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.amber,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: AppColors.amberDark),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text('Custom Item',
                  style: textTheme.titleMedium
                      ?.copyWith(color: AppColors.amberDark)),
              Text('Specify dimensions',
                  style: textTheme.bodySmall
                      ?.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddedItemsCard extends ConsumerWidget {
  const _AddedItemsCard({required this.items});

  final List<QuoteLooseItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final draft = ref.read(quoteDraftProvider.notifier);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.md,
        boxShadow: AppShadow.card,
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Text(items[i].emoji, style: const TextStyle(fontSize: 26)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(items[i].name, style: textTheme.titleMedium),
                        Text(
                          items[i].description.isEmpty
                              ? items[i].dimensionsLabel
                              : '${items[i].description} · '
                                  '${items[i].dimensionsLabel}',
                          style: textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Text('${formatZarExact(items[i].lineMonthlyZar)}/mo',
                      style: textTheme.titleMedium
                          ?.copyWith(color: AppColors.amberDark)),
                  const SizedBox(width: AppSpacing.md),
                  QuantityStepper(
                    value: items[i].quantity,
                    min: 1,
                    dense: true,
                    onChanged: (value) =>
                        draft.setLooseItemQuantity(items[i].id, value),
                  ),
                  IconButton(
                    onPressed: () => draft.removeLooseItem(items[i].id),
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.statusError),
                    tooltip: 'Remove ${items[i].name.toLowerCase()}',
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
