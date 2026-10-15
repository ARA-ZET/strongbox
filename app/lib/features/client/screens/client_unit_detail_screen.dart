// ignore_for_file: use_null_aware_elements
import '../../../core/providers/price_catalog_provider.dart';
import '../../../core/utils/currency.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/enums/app_enums.dart';
import '../../../core/models/photo.dart';
import '../../../core/models/storage_unit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadow.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/relative_time.dart';
import '../../../core/widgets/contact_us_card.dart';
import '../../../core/widgets/status_chip.dart';
import '../../admin/providers/notifications_providers.dart';
import '../providers/client_providers.dart';
import '../../../core/widgets/table_scroll.dart';

/// Client's read-only unit view with journey stepper and activity rail.
/// Design: client_designs/unit_details_sbx_9942_a1/screen.png.
class ClientUnitDetailScreen extends ConsumerWidget {
  const ClientUnitDetailScreen({super.key, required this.unitId});

  final String unitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unit = ref.watch(clientUnitDetailProvider(unitId));
    final tt = Theme.of(context).textTheme;

    return unit.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('Could not load unit: $error',
            style: tt.bodyMedium?.copyWith(color: AppColors.statusError)),
      ),
      data: (model) {
        if (model == null) {
          return Center(
              child: Text('Unit not found.', style: tt.titleMedium));
        }
        return _UnitDetailBody(unit: model);
      },
    );
  }
}

class _UnitDetailBody extends ConsumerWidget {
  const _UnitDetailBody({required this.unit});

  final StorageUnit unit;

  bool get _canRequestBack => unit.status == StorageStatus.inStorage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;

    return LayoutBuilder(builder: (context, constraints) {
      final desktop = constraints.maxWidth > 900;

      final left = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PhotoCollage(unitId: unit.id),
          const SizedBox(height: AppSpacing.md),
          _LocationBar(unit: unit, canRequest: _canRequestBack),
          const SizedBox(height: AppSpacing.lg),
          _JourneyCard(status: unit.status),
          if (unit.type == UnitType.open) ...[
            const SizedBox(height: AppSpacing.lg),
            _ItemsInside(unitId: unit.id),
          ],
        ],
      );

      final right = Column(
        children: [
          _VaultSpecCard(unit: unit),
          const SizedBox(height: AppSpacing.lg),
          _ActivityCard(unitId: unit.id),
        ],
      );

      return SingleChildScrollView(
        padding: EdgeInsets.all(desktop ? AppSpacing.lg : AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, size: 20),
                  onPressed: () => context.go('/client/storage'),
                ),
                Flexible(
                  child: Text.rich(
                    TextSpan(
                      style: tt.bodyMedium
                          ?.copyWith(color: AppColors.textSecondary),
                      children: [
                        const TextSpan(text: 'My Storage / '),
                        TextSpan(
                          text: unit.qrCodeId,
                          style: tt.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (desktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 65, child: left),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(flex: 35, child: right),
                ],
              )
            else ...[
              left,
              const SizedBox(height: AppSpacing.lg),
              right,
            ],
            const SizedBox(height: AppSpacing.lg),
            const ContactUsCard(dense: true),
          ],
        ),
      );
    });
  }
}

// ------------------------------------------------------------ photo collage

class _PhotoCollage extends ConsumerWidget {
  const _PhotoCollage({required this.unitId});

  final String unitId;

  void _openLightbox(BuildContext context, List<Photo> photos, int index) {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black87,
        insetPadding: const EdgeInsets.all(AppSpacing.lg),
        child: InteractiveViewer(
          child: CachedNetworkImage(
              imageUrl: photos[index].storageUrl, fit: BoxFit.contain),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photos =
        ref.watch(clientUnitPhotosProvider(unitId)).valueOrNull ?? const [];
    final tt = Theme.of(context).textTheme;

    Widget tile(int index, {BorderRadius? radius, Widget? overlay}) {
      if (index >= photos.length) {
        return ClipRRect(
          borderRadius: radius ?? BorderRadius.zero,
          child: const ColoredBox(
            color: AppColors.surfaceContainer,
            child: Center(
              child: Icon(Icons.inventory_2_outlined,
                  size: 40, color: AppColors.border),
            ),
          ),
        );
      }
      return InkWell(
        onTap: () => _openLightbox(context, photos, index),
        child: ClipRRect(
          borderRadius: radius ?? BorderRadius.zero,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                  imageUrl: photos[index].storageUrl, fit: BoxFit.cover),
              if (overlay != null) overlay,
            ],
          ),
        ),
      );
    }

    final extra = photos.length - 3;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.md,
        boxShadow: AppShadow.card,
      ),
      child: SizedBox(
        height: 320,
        child: Row(
          children: [
            Expanded(
              flex: 60,
              child: Stack(
                children: [
                  Positioned.fill(
                      child: tile(0, radius: AppRadius.sm)),
                  Positioned(
                    top: AppSpacing.sm + 4,
                    left: AppSpacing.sm + 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm + 4, vertical: 4),
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: AppRadius.pill,
                      ),
                      child: Text('MAIN EXTERIOR',
                          style: tt.bodySmall?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onAccent)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              flex: 40,
              child: Column(
                children: [
                  Expanded(child: tile(1, radius: AppRadius.sm)),
                  const SizedBox(height: AppSpacing.sm),
                  Expanded(
                    child: tile(
                      2,
                      radius: AppRadius.sm,
                      overlay: extra > 0
                          ? Container(
                              color: AppColors.overlay,
                              alignment: Alignment.center,
                              child: Text('+$extra\nView More',
                                  textAlign: TextAlign.center,
                                  style: tt.titleMedium
                                      ?.copyWith(color: Colors.white)),
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------- location bar

class _LocationBar extends ConsumerWidget {
  const _LocationBar({required this.unit, required this.canRequest});

  final StorageUnit unit;
  final bool canRequest;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.md,
        boxShadow: AppShadow.card,
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        final narrow = constraints.maxWidth < 560;
        final info = Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: AppRadius.sm,
              ),
              child:
                  const Icon(Icons.place_outlined, color: AppColors.navy),
            ),
            const SizedBox(width: AppSpacing.sm + 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    unit.warehouseLocationId == null
                        ? 'Secure StrongBox Facility'
                        : 'Secure Facility, ${unit.warehouseLocationId}',
                    style: tt.titleMedium,
                  ),
                  if (unit.updatedAt != null)
                    Text('Last updated ${relativeTime(unit.updatedAt!)}',
                        style: tt.bodySmall),
                ],
              ),
            ),
          ],
        );
        final button = ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(0, 48),
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          ),
          onPressed: canRequest
              ? () {
                  ref.read(deliveryRequestProvider.notifier)
                    ..reset()
                    ..toggleUnit(unit.id);
                  context.go('/client/requests/new');
                }
              : null,
          icon: const Icon(Icons.local_shipping_outlined, size: 18),
          label: Text(
              canRequest ? 'Request This Back' : 'Already on the move'),
        );

        if (narrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              info,
              const SizedBox(height: AppSpacing.sm + 4),
              SizedBox(width: double.infinity, child: button),
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: info),
            const SizedBox(width: AppSpacing.md),
            button,
          ],
        );
      }),
    );
  }
}

// ------------------------------------------------------------ journey card

class _JourneyCard extends StatelessWidget {
  const _JourneyCard({required this.status});

  final StorageStatus status;

  static const _steps = [
    (StorageStatus.pendingPickup, 'Pickup'),
    (StorageStatus.inTransit, 'In Transit'),
    (StorageStatus.inStorage, 'In Storage'),
    (StorageStatus.pendingDelivery, 'Pending Delivery'),
    (StorageStatus.delivered, 'Delivered'),
  ];

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    var current = _steps.indexWhere((step) => step.$1 == status);
    if (current < 0) current = 2; // cancelled/archived → show storage stage

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.md,
        boxShadow: AppShadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Current Journey Status', style: tt.titleMedium),
          const SizedBox(height: AppSpacing.md),
          TableScroll(
  minWidth: 560,
  child: Row(
                children: [
                  for (final (index, step) in _steps.indexed) ...[
                    if (index > 0)
                      Expanded(
                        child: Container(
                          height: 3,
                          color: index <= current
                              ? AppColors.accentDeep
                              : AppColors.border,
                        ),
                      ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: index <= current
                                ? AppColors.accentDeep
                                : AppColors.surfaceContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            index < current
                                ? Icons.check
                                : index == current
                                    ? Icons.inventory_2_outlined
                                    : Icons.more_horiz,
                            size: 18,
                            color: index <= current
                                ? Colors.white
                                : AppColors.textHint,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          step.$2,
                          style: tt.bodySmall?.copyWith(
                            fontWeight: index == current
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: index <= current
                                ? AppColors.accentDeep
                                : AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------- items inside

class _ItemsInside extends ConsumerWidget {
  const _ItemsInside({required this.unitId});

  final String unitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items =
        ref.watch(clientUnitItemsProvider(unitId)).valueOrNull ?? const [];
    final tt = Theme.of(context).textTheme;
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Items Inside (${items.length})', style: tt.headlineSmall),
        const SizedBox(height: AppSpacing.sm + 4),
        LayoutBuilder(builder: (context, constraints) {
          final columns = constraints.maxWidth > 700
              ? 4
              : constraints.maxWidth > 420
                  ? 2
                  : 1;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: AppSpacing.sm + 4,
              crossAxisSpacing: AppSpacing.sm + 4,
              mainAxisExtent: 96,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                padding: const EdgeInsets.all(AppSpacing.sm + 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.md,
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: AppRadius.sm,
                      ),
                      child: const Icon(Icons.category_outlined,
                          color: AppColors.navy, size: 20),
                    ),
                    const SizedBox(width: AppSpacing.sm + 4),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.label,
                              style: tt.labelLarge,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          Text(item.qrCodeId, style: tt.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ],
    );
  }
}

// -------------------------------------------------------------- vault spec

class _VaultSpecCard extends ConsumerWidget {
  const _VaultSpecCard({required this.unit});

  final StorageUnit unit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final prices = ref.watch(priceCatalogProvider);

    Widget label(String text) => Text(text.toUpperCase(),
        style: tt.bodySmall?.copyWith(letterSpacing: 0.8));

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.md,
        boxShadow: AppShadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Vault Specifications', style: tt.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    label('Serial label'),
                    const SizedBox(height: AppSpacing.xs),
                    Text(unit.qrCodeId, style: tt.titleMedium),
                  ],
                ),
              ),
              QrImageView(
                data: unit.qrCodeId,
                size: 64,
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: AppColors.navy,
                ),
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
          const Divider(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    label('Storage type'),
                    const SizedBox(height: AppSpacing.xs),
                    Text(unit.type.label, style: tt.bodyMedium),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  label('Status'),
                  const SizedBox(height: AppSpacing.xs),
                  StatusChip(status: unit.status.name),
                ],
              ),
            ],
          ),
          const Divider(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    label('Size'),
                    const SizedBox(height: AppSpacing.xs),
                    Text(prices.labelFor(unit.priceKey) ?? 'Being sized',
                        style: tt.bodyMedium),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  label('Monthly rate'),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    switch (unit.monthlyRateZar > 0
                        ? unit.monthlyRateZar
                        : prices.monthlyFor(unit.priceKey)) {
                      final int rate when rate > 0 => '${formatZar(rate)}/mo',
                      _ => '—',
                    },
                    style: tt.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: AppSpacing.lg),
          label('Added on'),
          const SizedBox(height: AppSpacing.xs),
          Text(
            unit.createdAt == null
                ? '—'
                : DateFormat('MMM d, y • HH:mm').format(unit.createdAt!),
            style: tt.bodyMedium,
          ),
          if (unit.description?.isNotEmpty ?? false) ...[
            const Divider(height: AppSpacing.lg),
            label('Notes'),
            const SizedBox(height: AppSpacing.xs),
            Text('"${unit.description}"',
                style: tt.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSecondary)),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------- activity rail

class _ActivityCard extends ConsumerWidget {
  const _ActivityCard({required this.unitId});

  final String unitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(clientUnitAuditProvider(unitId));
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.md,
        boxShadow: AppShadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Security & Activity', style: tt.titleMedium),
          const SizedBox(height: AppSpacing.md),
          events.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            // The audit trail is staff-only in firestore.rules; show the
            // empty state rather than a permission error.
            error: (_, _) => Text('Activity for this unit will appear here.',
                style: tt.bodyMedium
                    ?.copyWith(color: AppColors.textSecondary)),
            data: (list) => list.isEmpty
                ? Text('Activity for this unit will appear here.',
                    style: tt.bodyMedium
                        ?.copyWith(color: AppColors.textSecondary))
                : Column(
                    children: [
                      for (final event in list)
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: AppSpacing.md),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  color: AppColors.surfaceContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.shield_outlined,
                                    size: 18, color: AppColors.navy),
                              ),
                              const SizedBox(width: AppSpacing.sm + 4),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(auditTitle(event),
                                        style: tt.labelLarge),
                                    if (event.timestamp != null)
                                      Text(
                                          relativeTime(event.timestamp!),
                                          style: tt.bodySmall),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
