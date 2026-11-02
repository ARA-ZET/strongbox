import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/price_catalog_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/currency.dart';
import '../widgets/quote_widgets.dart';

/// Every price — boxes, loose items, pickup vehicles — from the live price
/// list, each addable to the quote (route `/prices`, open to everyone).
class PricesScreen extends ConsumerWidget {
  const PricesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(priceCatalogProvider);
    final tt = Theme.of(context).textTheme;

    return LayoutBuilder(builder: (context, constraints) {
      final desktop = constraints.maxWidth > 900;

      final boxes = QuoteSection(
        title: 'Storage boxes',
        subtitle: 'Per box, per month. We supply the boxes.',
        child: Column(children: [
          for (final box in catalog.activeBoxes) BoxQuoteRow(box: box),
        ]),
      );
      final vehicles = QuoteSection(
        title: 'Pickup',
        subtitle: 'Once-off per collection, by vehicle size.',
        child: Column(children: [
          for (final vehicle in catalog.activeVehicles)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                children: [
                  const Icon(Icons.local_shipping_outlined,
                      color: AppColors.accentDeep),
                  const SizedBox(width: AppSpacing.sm + 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(vehicle.label,
                            style: tt.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        if (vehicle.description.isNotEmpty)
                          Text(vehicle.description, style: tt.bodySmall),
                      ],
                    ),
                  ),
                  Text(formatZar(vehicle.onceOffZar), style: tt.titleSmall),
                ],
              ),
            ),
        ]),
      );
      const loose = QuoteSection(
        title: 'Furniture & loose items',
        subtitle: 'Per item, per month.',
        child: LooseItemPicker(shrinkWrap: true),
      );

      return PublicScaffold(
        current: '/prices',
        bottomBar: const QuoteBottomBar(viewQuote: true),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(desktop ? AppSpacing.lg : AppSpacing.md),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Prices', style: tt.displaySmall),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                      'All prices include 15% VAT. Add anything to your '
                      'quote as you go.',
                      style: tt.bodyMedium
                          ?.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: AppSpacing.lg),
                  if (desktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(children: [
                            boxes,
                            const SizedBox(height: AppSpacing.md),
                            vehicles,
                          ]),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        const Expanded(child: loose),
                      ],
                    )
                  else ...[
                    boxes,
                    const SizedBox(height: AppSpacing.md),
                    loose,
                    const SizedBox(height: AppSpacing.md),
                    vehicles,
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
