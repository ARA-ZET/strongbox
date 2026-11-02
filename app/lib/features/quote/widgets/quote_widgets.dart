import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/enums/app_enums.dart';
import '../../../core/models/price_catalog.dart';
import '../../../core/providers/price_catalog_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadow.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/currency.dart';
import '../../../core/widgets/brand_logo.dart';
import '../../../core/widgets/quantity_stepper.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/quote_providers.dart';

/// "Book pickup": signed-in clients go straight to booking; anyone else
/// signs up first and lands on booking with their quote intact.
void startBooking(BuildContext context, WidgetRef ref) {
  final user = ref.read(currentUserProvider).valueOrNull;
  if (user != null && user.role == UserRole.client) {
    context.go('/client/order/book');
    return;
  }
  ref.read(quoteControllerProvider.notifier).requestBooking();
  context.go(user == null ? '/register' : '/');
}

/// Page frame for the open screens (quote, prices): logo, links, and
/// "Sign in" or "My account".
class PublicScaffold extends ConsumerWidget {
  const PublicScaffold({
    super.key,
    required this.current,
    required this.body,
    this.bottomBar,
  });

  /// The route this page is, to highlight its link.
  final String current;
  final Widget body;
  final Widget? bottomBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signedIn = ref.watch(authStateProvider).valueOrNull != null;
    final wide = MediaQuery.sizeOf(context).width > 720;

    Widget link(String label, String route) => TextButton(
          onPressed: () => context.go(route),
          style: TextButton.styleFrom(
            foregroundColor: current == route
                ? AppColors.accentDeep
                : AppColors.textSecondary,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
          child: Text(label),
        );

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.surface,
        surfaceTintColor: AppColors.surface,
        titleSpacing: wide ? AppSpacing.lg : AppSpacing.md,
        title: InkWell(
          onTap: () => context.go('/quote'),
          child: const BrandLogo(fontSize: 20),
        ),
        actions: [
          if (wide) ...[
            link('Get a quote', '/quote'),
            link('Prices', '/prices'),
            const SizedBox(width: AppSpacing.sm),
          ] else
            PopupMenuButton<String>(
              tooltip: 'Menu',
              icon: const Icon(Icons.menu),
              onSelected: (route) => context.go(route),
              itemBuilder: (_) => const [
                PopupMenuItem(value: '/quote', child: Text('Get a quote')),
                PopupMenuItem(value: '/prices', child: Text('Prices')),
              ],
            ),
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: signedIn
                ? OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 40)),
                    onPressed: () => context.go('/'),
                    child: const Text('My account'),
                  )
                : OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 40)),
                    onPressed: () => context.go('/login'),
                    child: const Text('Sign in'),
                  ),
          ),
        ],
      ),
      body: body,
      bottomNavigationBar: bottomBar,
    );
  }
}

/// The quote's lines and totals, with "Book pickup". Desktop side panel.
class QuoteSummaryCard extends ConsumerWidget {
  const QuoteSummaryCard({super.key, this.showBookButton = true});

  final bool showBookButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totals = ref.watch(quoteTotalsProvider);
    final tt = Theme.of(context).textTheme;

    Widget row(String left, String right, {TextStyle? style}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: [
              Expanded(child: Text(left, style: style ?? tt.bodyMedium)),
              Text(right, style: style ?? tt.bodyMedium),
            ],
          ),
        );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.navyDeep,
        borderRadius: AppRadius.md,
        boxShadow: AppShadow.card,
      ),
      child: DefaultTextStyle.merge(
        style: const TextStyle(color: AppColors.onNavy),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('YOUR QUOTE',
                style: tt.bodySmall
                    ?.copyWith(color: AppColors.sky, letterSpacing: 1)),
            const SizedBox(height: AppSpacing.sm),
            if (totals.isEmpty)
              Text('Add boxes or items to see your monthly cost.',
                  style: tt.bodyMedium
                      ?.copyWith(color: AppColors.onNavyVariant))
            else
              for (final line in totals.lines)
                row('${line.quantity} × ${line.name}',
                    formatZar(line.quantity * line.unitZar),
                    style: tt.bodyMedium
                        ?.copyWith(color: AppColors.onNavyVariant)),
            const Divider(color: AppColors.navySoft, height: AppSpacing.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(formatZar(totals.monthlyZar),
                    style: tt.displaySmall?.copyWith(color: Colors.white)),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(' /month',
                      style: tt.bodyMedium
                          ?.copyWith(color: AppColors.onNavyVariant)),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text('ONCE-OFF',
                style: tt.bodySmall
                    ?.copyWith(color: AppColors.sky, letterSpacing: 1)),
            const SizedBox(height: AppSpacing.xs),
            if (totals.vehicle != null)
              row('Pickup (${totals.vehicle!.label})',
                  formatZar(totals.pickupZar),
                  style: tt.bodySmall
                      ?.copyWith(color: AppColors.onNavyVariant)),
            for (final line in totals.supplyLines)
              row('${line.quantity} × ${line.name}',
                  formatZar(line.quantity * line.unitZar),
                  style: tt.bodySmall
                      ?.copyWith(color: AppColors.onNavyVariant)),
            if (totals.helperHours > 0)
              row('Packing helper · ${totals.helperHours} h',
                  formatZar(totals.helperZar),
                  style: tt.bodySmall
                      ?.copyWith(color: AppColors.onNavyVariant)),
            row('Once-off total', formatZar(totals.onceOffZar),
                style: tt.bodyMedium?.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.xs),
            Text(
                'Storage is billed monthly from collection; once-off '
                'charges are on your first invoice. No contract.',
                style: tt.bodySmall?.copyWith(color: AppColors.onNavyVariant)),
            if (showBookButton) ...[
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed:
                      totals.isEmpty ? null : () => startBooking(context, ref),
                  icon: const Icon(Icons.local_shipping_outlined),
                  label: const Text('Book pickup'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Mobile: the running total pinned to the bottom, with "Book pickup" —
/// or, on the price list, "View quote".
class QuoteBottomBar extends ConsumerWidget {
  const QuoteBottomBar({super.key, this.viewQuote = false});

  /// Show "View quote" (to /quote) instead of "Book pickup".
  final bool viewQuote;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totals = ref.watch(quoteTotalsProvider);
    final tt = Theme.of(context).textTheme;
    if (viewQuote && totals.isEmpty) return const SizedBox.shrink();

    return Material(
      color: AppColors.navyDeep,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.sm + 4, AppSpacing.md, AppSpacing.sm + 4),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${formatZar(totals.monthlyZar)}/month',
                        style: tt.titleMedium?.copyWith(color: Colors.white)),
                    Text(
                        '${totals.itemCount} '
                        '${totals.itemCount == 1 ? 'item' : 'items'}'
                        ' · once-off ${formatZar(totals.onceOffZar)}',
                        style: tt.bodySmall
                            ?.copyWith(color: AppColors.onNavyVariant)),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: const Size(0, 44)),
                onPressed: totals.isEmpty
                    ? null
                    : viewQuote
                        ? () => context.go('/quote')
                        : () => startBooking(context, ref),
                child: Text(viewQuote ? 'View quote' : 'Book pickup'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A packing supply with its quantity in the quote (once-off).
class SupplyQuoteRow extends ConsumerWidget {
  const SupplyQuoteRow({super.key, required this.supply});

  final SupplyPrice supply;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(quoteControllerProvider
        .select((q) => q.draft.supplies[supply.id] ?? 0));
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          const Icon(Icons.layers_outlined, color: AppColors.accentDeep),
          const SizedBox(width: AppSpacing.sm + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(supply.label,
                    style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                Text(
                    [
                      if (supply.description.isNotEmpty) supply.description,
                      '${formatZar(supply.onceOffZar)} once-off',
                    ].join(' · '),
                    style: tt.bodySmall),
              ],
            ),
          ),
          QuantityStepper(
            value: count,
            onChanged: (n) => ref
                .read(quoteControllerProvider.notifier)
                .setSupply(supply.id, n),
          ),
        ],
      ),
    );
  }
}

/// Packing-helper hours: 0, or the minimum and up.
class HelperHoursRow extends ConsumerWidget {
  const HelperHoursRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final helper = ref.watch(priceCatalogProvider).packingHelper;
    final hours = ref
        .watch(quoteControllerProvider.select((q) => q.draft.helperHours));
    final tt = Theme.of(context).textTheme;
    final controller = ref.read(quoteControllerProvider.notifier);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          const Icon(Icons.groups_outlined, color: AppColors.accentDeep),
          const SizedBox(width: AppSpacing.sm + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${helper.label} (hours)',
                    style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                Text(
                    [
                      if (helper.description.isNotEmpty) helper.description,
                      '${formatZar(helper.hourlyZar)}/hour, minimum '
                          '${helper.minHours} hours',
                    ].join(' · '),
                    style: tt.bodySmall),
              ],
            ),
          ),
          QuantityStepper(
            value: hours,
            // Steps straight from none to the minimum and back.
            onChanged: (n) => controller.setHelperHours(n <= 0
                ? 0
                : n < helper.minHours
                    ? (n > hours ? helper.minHours : 0)
                    : n),
          ),
        ],
      ),
    );
  }
}

/// A box size with its count in the quote.
class BoxQuoteRow extends ConsumerWidget {
  const BoxQuoteRow({super.key, required this.box});

  final BoxPrice box;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(
        quoteControllerProvider.select((q) => q.draft.boxes[box.id] ?? 0));
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          const Icon(Icons.inventory_2_outlined, color: AppColors.accentDeep),
          const SizedBox(width: AppSpacing.sm + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(box.label,
                    style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                Text(
                    [
                      if (box.description.isNotEmpty) box.description,
                      '${formatZar(box.monthlyZar)}/mo',
                    ].join(' · '),
                    style: tt.bodySmall),
              ],
            ),
          ),
          QuantityStepper(
            value: count,
            emphasiseAdd: true,
            onChanged: (n) =>
                ref.read(quoteControllerProvider.notifier).setBox(box.id, n),
          ),
        ],
      ),
    );
  }
}

/// A loose item with its count in the quote.
class LooseItemQuoteRow extends ConsumerWidget {
  const LooseItemQuoteRow({super.key, required this.item, this.dense = false});

  final LooseItemPrice item;
  final bool dense;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(
        quoteControllerProvider.select((q) => q.draft.loose[item.id] ?? 0));
    final tt = Theme.of(context).textTheme;
    final controller = ref.read(quoteControllerProvider.notifier);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: dense ? 4 : AppSpacing.sm),
      child: Row(
        children: [
          const Icon(Icons.chair_outlined, color: AppColors.accentDeep),
          const SizedBox(width: AppSpacing.sm + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text('${item.category} · ${formatZar(item.monthlyZar)}/mo',
                    style: tt.bodySmall),
              ],
            ),
          ),
          if (count == 0)
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 36)),
              onPressed: () => controller.setLoose(item.id, 1),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
            )
          else
            QuantityStepper(
              value: count,
              dense: dense,
              onChanged: (n) => controller.setLoose(item.id, n),
            ),
        ],
      ),
    );
  }
}

/// Searchable, category-filtered list of every loose item, each addable.
class LooseItemPicker extends ConsumerStatefulWidget {
  const LooseItemPicker({super.key, this.shrinkWrap = false});

  /// Inside a scrolling page rather than a dialog.
  final bool shrinkWrap;

  /// Opens the picker as a dialog (desktop) or bottom sheet (mobile).
  static Future<void> show(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width > 720;
    const content = _PickerFrame();
    if (wide) {
      return showDialog<void>(
        context: context,
        builder: (_) => const Dialog(
          backgroundColor: AppColors.surface,
          child: SizedBox(width: 560, height: 640, child: content),
        ),
      );
    }
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (_) => FractionallySizedBox(heightFactor: 0.9, child: content),
    );
  }

  @override
  ConsumerState<LooseItemPicker> createState() => _LooseItemPickerState();
}

class _PickerFrame extends StatelessWidget {
  const _PickerFrame();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text('Add furniture & items',
                      style: tt.headlineSmall)),
              IconButton(
                tooltip: 'Done',
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          const Expanded(child: LooseItemPicker()),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }
}

class _LooseItemPickerState extends ConsumerState<LooseItemPicker> {
  String _query = '';
  String? _category;

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(priceCatalogProvider);
    final items = catalog.activeLooseItems;
    final categories = [
      ...{
        ...catalog.looseItemCategories.where((c) => c != 'All'),
        ...items.map((i) => i.category),
      },
    ];
    final visible = items
        .where((i) => _category == null || i.category == _category)
        .where((i) =>
            _query.isEmpty || i.name.toLowerCase().contains(_query))
        .toList();

    final list = visible.isEmpty
        ? const Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Text('No items match — try another word, or add the '
                'nearest size and tell us in the booking notes.'),
          )
        : ListView.builder(
            shrinkWrap: widget.shrinkWrap,
            physics: widget.shrinkWrap
                ? const NeverScrollableScrollPhysics()
                : null,
            itemCount: visible.length,
            itemBuilder: (_, i) =>
                LooseItemQuoteRow(item: visible[i], dense: true),
          );

    return Column(
      mainAxisSize: widget.shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Search e.g. sofa, fridge, bicycle',
          ),
          onChanged: (value) =>
              setState(() => _query = value.trim().toLowerCase()),
        ),
        const SizedBox(height: AppSpacing.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _category == null,
                onSelected: (_) => setState(() => _category = null),
              ),
              for (final category in categories) ...[
                const SizedBox(width: AppSpacing.xs),
                ChoiceChip(
                  label: Text(category),
                  selected: _category == category,
                  onSelected: (_) => setState(() => _category = category),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (widget.shrinkWrap) list else Expanded(child: list),
      ],
    );
  }
}

/// Picks the pickup vehicle for the quote.
class VehicleChoice extends ConsumerWidget {
  const VehicleChoice({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(priceCatalogProvider);
    final chosen = ref.watch(quoteTotalsProvider).vehicle;
    final tt = Theme.of(context).textTheme;

    return Column(
      children: [
        for (final vehicle in catalog.activeVehicles)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: InkWell(
              borderRadius: AppRadius.md,
              onTap: () => ref
                  .read(quoteControllerProvider.notifier)
                  .setVehicle(vehicle.id),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: chosen?.id == vehicle.id
                      ? AppColors.skyTint
                      : AppColors.surface,
                  borderRadius: AppRadius.md,
                  border: Border.all(
                    color: chosen?.id == vehicle.id
                        ? AppColors.accentDeep
                        : AppColors.border,
                    width: chosen?.id == vehicle.id ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      chosen?.id == vehicle.id
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: AppColors.accentDeep,
                    ),
                    const SizedBox(width: AppSpacing.sm + 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: AppSpacing.sm,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(vehicle.label,
                                  style: tt.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600)),
                              if (vehicle.recommended)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: const BoxDecoration(
                                    color: AppColors.statusSuccessBg,
                                    borderRadius: AppRadius.pill,
                                  ),
                                  child: Text('Most popular',
                                      style: tt.bodySmall?.copyWith(
                                          color: AppColors.statusSuccess,
                                          fontWeight: FontWeight.w600)),
                                ),
                            ],
                          ),
                          Text(
                              [
                                if (vehicle.description.isNotEmpty)
                                  vehicle.description,
                                if (vehicle.capacityM3 > 0)
                                  'up to ${vehicle.capacityM3.toStringAsFixed(vehicle.capacityM3 % 1 == 0 ? 0 : 1)} m³',
                              ].join(' · '),
                              style: tt.bodySmall),
                        ],
                      ),
                    ),
                    Text(formatZar(vehicle.onceOffZar),
                        style: tt.titleSmall),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// A titled white card section.
class QuoteSection extends StatelessWidget {
  const QuoteSection({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.child,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.md,
        boxShadow: AppShadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: tt.titleMedium)),
              // ignore: use_null_aware_elements — build_runner can't parse `?x` yet.
              if (trailing != null) trailing!,
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle!, style: tt.bodySmall),
          ],
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}
