import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/price_catalog_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/contact_us_card.dart';
import '../providers/quote_providers.dart';
import '../widgets/quote_widgets.dart';

/// Build a quote — open to everyone, no account needed (route `/quote`),
/// and a client's "New order" inside their portal (`/client/order`).
///
/// Quick calculator (boxes), furniture & loose items, pickup vehicle and a
/// live total. "Book pickup" signs the visitor up if needed and carries the
/// quote into booking. Quotes handed over from the website open here too.
class QuoteScreen extends ConsumerWidget {
  const QuoteScreen({super.key, this.inPortal = false});

  /// Inside the ClientShell: no public frame or price-list link.
  final bool inPortal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(priceCatalogProvider);
    final totals = ref.watch(quoteTotalsProvider);
    final tt = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth > 900;

        final builder = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            QuoteSection(
              title: 'Quick calculator',
              subtitle: 'How many StrongBoxes? You pay per box, per month.',
              child: Column(
                children: [
                  for (final box in catalog.activeBoxes) BoxQuoteRow(box: box),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            QuoteSection(
              title: 'Furniture & loose items',
              subtitle: 'Bikes, appliances, furniture — priced per item.',
              trailing: TextButton.icon(
                onPressed: () => LooseItemPicker.show(context),
                icon: const Icon(Icons.add),
                label: const Text('Add items'),
              ),
              child: totals.looseLines.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                      ),
                      child: Text(
                        'Nothing added yet.',
                        style: tt.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        for (final line in totals.looseLines)
                          LooseItemQuoteRow(item: catalog.looseItem(line.id)!),
                      ],
                    ),
            ),
            if (catalog.activeSupplies.isNotEmpty || catalog.offersHelper) ...[
              const SizedBox(height: AppSpacing.md),
              QuoteSection(
                title: 'Packing & supplies (optional)',
                subtitle: 'Empty boxes come free with every box you store. '
                    'Add wrapping, or a packer to help on the day — once-off.',
                child: Column(
                  children: [
                    for (final supply in catalog.activeSupplies)
                      SupplyQuoteRow(supply: supply),
                    if (catalog.offersHelper) const HelperHoursRow(),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            const QuoteSection(
              title: 'Pickup vehicle',
              subtitle:
                  'A once-off fee per collection — pick the size that '
                  'fits your load.',
              child: VehicleChoice(),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                if (!inPortal)
                  TextButton.icon(
                    onPressed: () => context.go('/prices'),
                    icon: const Icon(Icons.sell_outlined),
                    label: const Text('See every price'),
                  ),
                if (!totals.isEmpty)
                  TextButton.icon(
                    onPressed: () =>
                        ref.read(quoteControllerProvider.notifier).clear(),
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Start over'),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const ContactUsCard(dense: true),
          ],
        );

        final header = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Build your quote', style: tt.displaySmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              inPortal
                  ? 'Add the boxes and items you want us to store, choose a '
                        'pickup vehicle, then book your collection.'
                  : 'We collect, store and bring your things back when you '
                        'ask. No contract, no minimum term.',
              style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        );

        final page = SingleChildScrollView(
          padding: EdgeInsets.all(desktop ? AppSpacing.lg : AppSpacing.md),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  header,
                  if (desktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 62, child: builder),
                        const SizedBox(width: AppSpacing.lg),
                        const Expanded(flex: 38, child: QuoteSummaryCard()),
                      ],
                    )
                  else
                    builder,
                ],
              ),
            ),
          ),
        );

        // The ClientShell already has a Scaffold (and its own bottom nav), so
        // the running total sits under the page instead.
        if (inPortal) {
          if (desktop) return page;
          return Column(
            children: [
              Expanded(child: page),
              const QuoteBottomBar(),
            ],
          );
        }
        return PublicScaffold(
          current: '/quote',
          bottomBar: desktop ? null : const QuoteBottomBar(),
          body: page,
        );
      },
    );
  }
}
