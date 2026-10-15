import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/contact_info.dart';
import '../../../core/constants/pricing.dart';
import '../../../core/providers/business_settings_provider.dart';
import '../../../core/providers/price_catalog_provider.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadow.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/currency.dart';
import '../../../core/widgets/contact_us_card.dart';
import '../../../core/widgets/status_chip.dart';
import '../../billing/widgets/invoice_table.dart';
import '../providers/client_providers.dart';

/// Billing (ZAR). Storage is charged per box or loose item per month at the
/// shared price list — the same numbers as strongbox.co.za — with no
/// contract or term discounts. Pickups are a once-off fee per collection.
class ClientSubscriptionScreen extends ConsumerWidget {
  const ClientSubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(currentClientProvider).valueOrNull;
    final bill = ref.watch(myStorageBillProvider);
    final tt = Theme.of(context).textTheme;

    return LayoutBuilder(builder: (context, constraints) {
      final desktop = constraints.maxWidth > 900;

      final summary = _MonthlySummary(bill: bill);

      final termCard = Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(
          color: AppColors.navyDeep,
          borderRadius: AppRadius.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('BILLING',
                style: tt.bodySmall
                    ?.copyWith(color: AppColors.sky, letterSpacing: 1)),
            const SizedBox(height: AppSpacing.xs),
            Text('Monthly',
                style: tt.displaySmall?.copyWith(color: Colors.white)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'No contract, no minimum term — cancel any time.',
              style: tt.bodyMedium?.copyWith(color: AppColors.onNavyVariant),
            ),
            const SizedBox(height: AppSpacing.sm),
            StatusChip(
                status:
                    (client?.subscriptionStatus ?? SubscriptionStatus.active)
                        .name),
            const SizedBox(height: AppSpacing.md),
            const _PaymentPanel(),
          ],
        ),
      );

      return SingleChildScrollView(
        padding: EdgeInsets.all(desktop ? AppSpacing.lg : AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Billing', style: tt.displaySmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
                'You pay per box or item each month — only for what we are '
                'storing for you.',
                style:
                    tt.bodyMedium?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.lg),
            if (desktop)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 55, child: summary),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(flex: 45, child: termCard),
                  ],
                ),
              )
            else ...[
              summary,
              const SizedBox(height: AppSpacing.lg),
              termCard,
            ],
            const SizedBox(height: AppSpacing.lg),
            Text('Price List', style: tt.headlineSmall),
            const SizedBox(height: AppSpacing.sm + 4),
            const _PriceListCard(),
            const SizedBox(height: AppSpacing.lg),
            Text('Invoices', style: tt.headlineSmall),
            const SizedBox(height: AppSpacing.sm + 4),
            if (client != null)
              InvoiceTable(
                invoices: ref.watch(myInvoicesProvider),
                client: client,
                onRetry: () => ref.invalidate(myInvoicesProvider),
              ),
            const SizedBox(height: AppSpacing.lg),
            const ContactUsCard(dense: true),
          ],
        ),
      );
    });
  }
}

// ------------------------------------------------------------ how to pay

/// What is owed and how to pay it: EFT quoting the invoice reference, to
/// the bank details set in Admin → Settings.
class _PaymentPanel extends ConsumerWidget {
  const _PaymentPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final invoices = ref.watch(myInvoicesProvider).valueOrNull ?? const [];
    final open = invoices.where((invoice) => invoice.isOpen).toList();
    final instructions =
        ref.watch(businessSettingsProvider).paymentInstructions;
    final light = tt.bodyMedium?.copyWith(color: AppColors.onNavyVariant);

    if (open.isEmpty) {
      return Row(
        children: [
          const Icon(Icons.check_circle_outline, color: AppColors.sky),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              invoices.isEmpty
                  ? 'Invoices are issued on the 1st of each month.'
                  : 'You\'re all paid up — thank you.',
              style: light,
            ),
          ),
        ],
      );
    }

    final due = open.fold<double>(0, (sum, invoice) => sum + invoice.amount);
    final oldest = open.last;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.navy,
        borderRadius: AppRadius.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('AMOUNT DUE',
              style: tt.bodySmall
                  ?.copyWith(color: AppColors.sky, letterSpacing: 1)),
          const SizedBox(height: AppSpacing.xs),
          Text(formatZarExact(due),
              style: tt.headlineSmall?.copyWith(color: Colors.white)),
          if (oldest.dueAt != null)
            Text('Due ${DateFormat('d MMM y').format(oldest.dueAt!)}',
                style: light),
          const SizedBox(height: AppSpacing.sm),
          Text('Pay by EFT using reference', style: light),
          Row(
            children: [
              Flexible(
                child: SelectableText(
                  open.length == 1
                      ? oldest.reference
                      : open.map((invoice) => invoice.reference).join(', '),
                  style: tt.titleMedium?.copyWith(color: Colors.white),
                ),
              ),
              IconButton(
                tooltip: 'Copy reference',
                icon: const Icon(Icons.copy, size: 18, color: AppColors.sky),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: oldest.reference));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reference copied')),
                  );
                },
              ),
            ],
          ),
          if (instructions.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            SelectableText(instructions, style: light),
          ] else
            Text('Contact us below for our banking details.', style: light),
        ],
      ),
    );
  }
}

// --------------------------------------------------------- monthly summary

class _MonthlySummary extends ConsumerWidget {
  const _MonthlySummary({required this.bill});

  final StorageBill bill;

  static const _shown = 6;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final prices = ref.watch(priceCatalogProvider);
    final units = bill.billableUnits;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.md,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Monthly Storage', style: tt.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(formatZar(bill.monthlyZar), style: tt.displaySmall),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(' /mo', style: tt.bodyMedium),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(),
          if (units.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text(
                'Nothing in storage yet — billing starts once we collect.',
                style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
              ),
            )
          else ...[
            for (final unit in units.take(_shown))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        unit.label.isEmpty ? unit.qrCodeId : unit.label,
                        style: tt.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(prices.labelFor(unit.priceKey) ?? 'Being sized',
                        style: tt.bodySmall),
                    const SizedBox(width: AppSpacing.md),
                    SizedBox(
                      width: 72,
                      child: Text(
                        _rateLabel(unit.monthlyRateZar > 0
                            ? unit.monthlyRateZar
                            : prices.monthlyFor(unit.priceKey)),
                        textAlign: TextAlign.right,
                        style: tt.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            if (units.length > _shown)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text('and ${units.length - _shown} more',
                    style: tt.bodySmall),
              ),
          ],
          if (bill.unpricedUnits > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${bill.unpricedUnits} '
              '${bill.unpricedUnits == 1 ? 'unit is' : 'units are'} still '
              'being sized by our team and not yet included.',
              style: tt.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  static String _rateLabel(int? rate) =>
      rate == null || rate == 0 ? '—' : formatZar(rate);
}

// -------------------------------------------------------------- price list

class _PriceListCard extends ConsumerWidget {
  const _PriceListCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final prices = ref.watch(priceCatalogProvider);

    Widget row(String label, String detail, String price) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: tt.bodyMedium),
                    Text(detail, style: tt.bodySmall),
                  ],
                ),
              ),
              Text(price,
                  style: tt.bodyMedium?.copyWith(
                      color: AppColors.accentDeep,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        );

    Widget section(String title, List<Widget> rows) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: tt.labelSmall?.copyWith(
                    color: AppColors.textSecondary, letterSpacing: 0.8)),
            const SizedBox(height: AppSpacing.xs),
            ...rows,
          ],
        );

    final boxes = section('STORAGE BOXES · PER MONTH', [
      for (final box in prices.activeBoxes)
        row(box.label, box.description, '${formatZar(box.monthlyZar)}/mo'),
    ]);
    final pickups = section('PICKUP · ONCE-OFF PER COLLECTION', [
      for (final vehicle in prices.activeVehicles)
        row(vehicle.label, vehicle.description,
            formatZar(vehicle.onceOffZar)),
    ]);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.md,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(builder: (context, constraints) {
            if (constraints.maxWidth > 640) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: boxes),
                  const SizedBox(width: AppSpacing.xl),
                  Expanded(child: pickups),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [boxes, const SizedBox(height: AppSpacing.md), pickups],
            );
          }),
          const Divider(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Loose items (furniture, bikes, appliances) from '
                  '${formatZar(prices.looseItemFrom)}/mo. Prices include '
                  '15% VAT.',
                  style: tt.bodySmall,
                ),
              ),
              TextButton(
                onPressed: () => launchUrl(Uri.parse(ContactInfo.pricingUrl),
                    mode: LaunchMode.externalApplication),
                child: const Text('Full price list'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
