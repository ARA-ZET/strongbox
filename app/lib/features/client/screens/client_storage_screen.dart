import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/enums/app_enums.dart';
import '../../../core/models/storage_unit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadow.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/relative_time.dart';
import '../../../core/providers/price_catalog_provider.dart';
import '../../../core/providers/business_settings_provider.dart';
import '../../../core/utils/report_failure.dart';
import '../../../core/utils/inventory_pdf.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/contact_us_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/label_print_dialog.dart';
import '../providers/client_providers.dart';
import '../../../core/widgets/storage_image.dart';

/// The client's unit grid with search + status chips. The chip is in the
/// URL (`?status=inStorage`) so other screens link to a filtered view.
/// Design: client_designs/my_storage_inventory/screen.png.
class ClientStorageScreen extends ConsumerWidget {
  const ClientStorageScreen({super.key, this.status = 'all'});

  /// A [StorageStatus] name, or 'all'.
  final String status;

  /// Status filters in the client's words, in the order things happen.
  static const filters = [
    ('all', 'All'),
    ('pendingPickup', 'Awaiting pickup'),
    ('inTransit', 'In transit'),
    ('inStorage', 'In storage'),
    ('pendingDelivery', 'On its way back'),
    ('delivered', 'Delivered'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = filters.any((f) => f.$1 == status) ? status : 'all';
    final units = ref.watch(filteredMyUnitsProvider(selected));
    final all = ref.watch(myUnitsProvider).valueOrNull ?? const [];
    final counts = <String, int>{};
    for (final unit in all) {
      if (unit.status == StorageStatus.archived) continue;
      counts.update(unit.status.name, (n) => n + 1, ifAbsent: () => 1);
    }
    final total = counts.values.fold(0, (sum, n) => sum + n);
    final tt = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth > 900;

        return SingleChildScrollView(
          padding: EdgeInsets.all(desktop ? AppSpacing.lg : AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text('My Storage', style: tt.displaySmall)),
                  if (all.isNotEmpty) ...[
                    IconButton(
                      tooltip: 'Export inventory (PDF)',
                      onPressed: () {
                        final client = ref
                            .read(currentClientProvider)
                            .valueOrNull;
                        if (client == null) return;
                        reportFailure(
                          context,
                          'Could not export inventory',
                          () => printInventory(
                            all,
                            client: client,
                            business: ref.read(businessSettingsProvider),
                            prices: ref.read(priceCatalogProvider),
                          ),
                        );
                      },
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  if (all.any((u) => u.qrCodeId.isNotEmpty))
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 44),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                      ),
                      onPressed: () => LabelPrintDialog.show(
                        context,
                        units: all,
                        preselected: {
                          for (final u in all)
                            if (u.status == StorageStatus.pendingPickup) u.id,
                        },
                      ),
                      icon: const Icon(Icons.print_outlined, size: 18),
                      label: const Text('Print labels'),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _PackingBanner(units: all),
              Wrap(
                spacing: AppSpacing.sm + 4,
                runSpacing: AppSpacing.sm + 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: desktop ? 380 : double.infinity,
                    child: AppSearchBar(
                      hint: 'Search storage units, items, or IDs...',
                      onChanged: (value) => ref
                          .read(storageSearchQueryProvider.notifier)
                          .set(value),
                    ),
                  ),
                  for (final (value, label) in filters)
                    // Empty statuses stay out of the way.
                    if (value == 'all' ||
                        value == selected ||
                        (counts[value] ?? 0) > 0)
                      ChoiceChip(
                        label: Text(
                          '$label (${value == 'all' ? total : counts[value] ?? 0})',
                        ),
                        selected: selected == value,
                        showCheckmark: false,
                        selectedColor: AppColors.navy,
                        backgroundColor: AppColors.surface,
                        labelStyle: tt.labelLarge?.copyWith(
                          color: selected == value
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.pill,
                          side: BorderSide(color: AppColors.border),
                        ),
                        onSelected: (_) => context.go(
                          value == 'all'
                              ? '/client/storage'
                              : '/client/storage?status=$value',
                        ),
                      ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              if (units.isEmpty)
                EmptyState(
                  icon: Icons.inventory_2_outlined,
                  title: all.isEmpty
                      ? 'No items in storage yet'
                      : 'Nothing matches your filters',
                  subtitle: all.isEmpty
                      ? 'Build a quote and book your first pickup — your '
                            'belongings will appear here.'
                      : 'Try a different search or filter.',
                  action: all.isEmpty
                      ? ElevatedButton(
                          onPressed: () => context.go('/client/order'),
                          child: const Text('New order'),
                        )
                      : null,
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth > 1100
                        ? 3
                        : constraints.maxWidth > 640
                        ? 2
                        : 1;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        mainAxisSpacing: AppSpacing.md,
                        crossAxisSpacing: AppSpacing.md,
                        mainAxisExtent: 300,
                      ),
                      itemCount: units.length,
                      itemBuilder: (context, index) =>
                          _ClientUnitCard(unit: units[index]),
                    );
                  },
                ),
              const SizedBox(height: AppSpacing.lg),
              const ContactUsCard(dense: true),
            ],
          ),
        );
      },
    );
  }
}

/// Items awaiting pickup: print their QR labels and stick one on each box
/// or item while packing — the driver scans them at collection.
class _PackingBanner extends StatelessWidget {
  const _PackingBanner({required this.units});

  final List<StorageUnit> units;

  @override
  Widget build(BuildContext context) {
    final toPack = units
        .where(
          (u) =>
              u.status == StorageStatus.pendingPickup && u.qrCodeId.isNotEmpty,
        )
        .toList();
    if (toPack.isEmpty) return const SizedBox.shrink();
    final tt = Theme.of(context).textTheme;
    final n = toPack.length;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.skyTint,
        borderRadius: AppRadius.md,
      ),
      child: Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.sm + 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Packing for your pickup',
                  style: tt.titleMedium?.copyWith(color: AppColors.accentDeep),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Print your $n QR ${n == 1 ? 'label' : 'labels'} and stick '
                  'one on each box or item — each label shows which one it '
                  'belongs to. No printer? Your driver brings them. Tap a '
                  'box to photograph what you packed and note what\'s inside.',
                  style: tt.bodyMedium,
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, 44),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            ),
            onPressed: () => LabelPrintDialog.show(
              context,
              units: units,
              preselected: {for (final u in toPack) u.id},
            ),
            icon: const Icon(Icons.print_outlined, size: 18),
            label: const Text('Print labels'),
          ),
        ],
      ),
    );
  }
}

/// Grid card with the status pill and OPEN/CLOSED tag overlaid on the photo.
class _ClientUnitCard extends ConsumerWidget {
  const _ClientUnitCard({required this.unit});

  final StorageUnit unit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final photos = ref.watch(clientUnitPhotosProvider(unit.id)).valueOrNull;
    final photoUrl = (photos != null && photos.isNotEmpty)
        ? photos.first.storageUrl
        : null;

    return InkWell(
      onTap: () => context.go('/client/storage/${unit.id}'),
      borderRadius: AppRadius.md,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.md,
          boxShadow: AppShadow.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: photoUrl == null
                      ? const ColoredBox(
                          color: AppColors.surfaceContainer,
                          child: Icon(
                            Icons.inventory_2_outlined,
                            size: 48,
                            color: AppColors.border,
                          ),
                        )
                      : StorageImage(photoUrl),
                ),
                Positioned(
                  top: AppSpacing.sm + 4,
                  left: AppSpacing.sm + 4,
                  child: _overlayChip(
                    unit.status.label.toUpperCase(),
                    unit.status.chipBgColour,
                    unit.status.chipTextColour,
                    dotted: true,
                    tt: tt,
                  ),
                ),
                Positioned(
                  top: AppSpacing.sm + 4,
                  right: AppSpacing.sm + 4,
                  child: _overlayChip(
                    unit.type == UnitType.open ? 'OPEN' : 'CLOSED',
                    unit.type == UnitType.open
                        ? AppColors.accent
                        : AppColors.navy,
                    unit.type == UnitType.open
                        ? AppColors.onAccent
                        : Colors.white,
                    tt: tt,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    unit.label.isEmpty ? 'Storage Unit' : unit.label,
                    style: tt.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          unit.qrCodeId.isEmpty
                              ? 'Label pending'
                              : '#${unit.qrCodeId}',
                          style: tt.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unit.updatedAt != null)
                        Text(
                          'Updated ${relativeTime(unit.updatedAt!)}',
                          style: tt.bodySmall,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _overlayChip(
    String label,
    Color bg,
    Color fg, {
    bool dotted = false,
    required TextTheme tt,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: 4,
      ),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.pill),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dotted) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: tt.bodySmall?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
