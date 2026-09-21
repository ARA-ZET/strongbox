import 'package:cached_network_image/cached_network_image.dart';
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
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/contact_us_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../providers/client_providers.dart';

/// The client's unit grid with search + status chips.
/// Design: client_designs/my_storage_inventory/screen.png.
class ClientStorageScreen extends ConsumerWidget {
  const ClientStorageScreen({super.key});

  static const _filters = [
    ('all', 'All'),
    ('inStorage', 'In Storage'),
    ('inTransit', 'In Transit'),
    ('pendingPickup', 'Pending Pickup'),
    ('delivered', 'Delivered'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final units = ref.watch(filteredMyUnitsProvider);
    final all = ref.watch(myUnitsProvider).valueOrNull ?? const [];
    final selected = ref.watch(storageStatusFilterProvider);
    final tt = Theme.of(context).textTheme;

    return LayoutBuilder(builder: (context, constraints) {
      final desktop = constraints.maxWidth > 900;

      return SingleChildScrollView(
        padding: EdgeInsets.all(desktop ? AppSpacing.lg : AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My Storage', style: tt.displaySmall),
            const SizedBox(height: AppSpacing.md),
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
                for (final (value, label) in _filters)
                  ChoiceChip(
                    label: Text(label),
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
                    onSelected: (_) => ref
                        .read(storageStatusFilterProvider.notifier)
                        .set(value),
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
                    ? 'Contact us to arrange your first pickup and your '
                        'belongings will appear here.'
                    : 'Try a different search or filter.',
              )
            else
              LayoutBuilder(builder: (context, constraints) {
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
              }),
            const SizedBox(height: AppSpacing.lg),
            const ContactUsCard(dense: true),
          ],
        ),
      );
    });
  }
}

/// Grid card with the status pill and OPEN/CLOSED tag overlaid on the photo.
class _ClientUnitCard extends ConsumerWidget {
  const _ClientUnitCard({required this.unit});

  final StorageUnit unit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final photos =
        ref.watch(clientUnitPhotosProvider(unit.id)).valueOrNull;
    final photoUrl =
        (photos != null && photos.isNotEmpty) ? photos.first.storageUrl : null;

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
                          child: Icon(Icons.inventory_2_outlined,
                              size: 48, color: AppColors.border),
                        )
                      : CachedNetworkImage(
                          imageUrl: photoUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => const ColoredBox(
                              color: AppColors.surfaceContainer),
                        ),
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
                        child: Text('#${unit.qrCodeId}',
                            style: tt.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      if (unit.updatedAt != null)
                        Text('Updated ${relativeTime(unit.updatedAt!)}',
                            style: tt.bodySmall),
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

  Widget _overlayChip(String label, Color bg, Color fg,
      {bool dotted = false, required TextTheme tt}) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm + 2, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.pill),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dotted) ...[
            Container(
              width: 6,
              height: 6,
              decoration:
                  BoxDecoration(color: fg, shape: BoxShape.circle),
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
