// ignore_for_file: use_null_aware_elements
import '../../../core/providers/price_catalog_provider.dart';
import '../../../core/utils/currency.dart';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/enums/app_enums.dart';
import '../../../core/models/photo.dart';
import '../../../core/models/storage_unit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadow.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/qr_label_pdf.dart';
import '../../../core/utils/relative_time.dart';
import '../../../core/utils/report_failure.dart';
import '../../../core/widgets/camera_capture.dart';
import '../../../core/widgets/contact_us_card.dart';
import '../../../core/widgets/status_chip.dart';
import '../../admin/providers/notifications_providers.dart';
import '../../../core/utils/public_ref.dart';
import '../providers/client_providers.dart';
import '../utils/client_orders.dart';
import '../../../core/widgets/table_scroll.dart';
import '../../../core/utils/qr_link.dart';
import '../../../core/widgets/storage_image.dart';

/// Client's unit view with journey stepper and activity rail. While the
/// unit is awaiting pickup the client can photograph and describe it as
/// they pack ([_PackingCard]); after that it's read-only.
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
        child: Text(
          'Could not load unit: $error',
          style: tt.bodyMedium?.copyWith(color: AppColors.statusError),
        ),
      ),
      data: (model) {
        if (model == null) {
          return Center(child: Text('Unit not found.', style: tt.titleMedium));
        }
        return _UnitDetailBody(unit: model);
      },
    );
  }
}

/// The order this unit is on (its latest pickup or delivery).
class _OrderLink extends ConsumerWidget {
  const _OrderLink({required this.jobId});

  final String jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final job = ref.watch(myOrderProvider(jobId));
    if (job == null) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () => context.go('/client/orders/${job.id}'),
        icon: const Icon(Icons.local_shipping_outlined, size: 18),
        label: Text('${job.type.label} ${jobRef(job)} · '
            '${orderStatusLabel(job)}'),
      ),
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth > 900;

        final left = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PhotoCollage(unitId: unit.id),
            if (canPack(unit)) ...[
              const SizedBox(height: AppSpacing.md),
              _PackingCard(unit: unit),
            ],
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
                        style: tt.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        children: [
                          const TextSpan(text: 'My Storage / '),
                          TextSpan(
                            text: unit.qrCodeId,
                            style: tt.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (unit.jobId != null) _OrderLink(jobId: unit.jobId!),
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
      },
    );
  }
}

// ------------------------------------------------------------ packing

/// Packing help for a box awaiting pickup: what to photograph, the
/// client's own photos (add from camera or gallery, remove), and a note of
/// what's inside. Photos land on the unit, so the driver and ops see them.
class _PackingCard extends ConsumerStatefulWidget {
  const _PackingCard({required this.unit});

  final StorageUnit unit;

  @override
  ConsumerState<_PackingCard> createState() => _PackingCardState();
}

class _PackingCardState extends ConsumerState<_PackingCard> {
  final _picker = ImagePicker();
  late final _notes = TextEditingController(text: widget.unit.description);
  PhotoType _type = PhotoType.interior;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _add(ImageSource source, int room) async {
    final actions = ref.read(packingActionsProvider.notifier);
    // Downsized on the device: ~1600px is plenty to see what's packed.
    final List<Uint8List> shots;
    if (source == ImageSource.camera) {
      // Our own camera screen: opens the camera in every browser, not just
      // on phones.
      final shot = await CameraCapture.open(
        context,
        title: _type == PhotoType.exterior
            ? 'Photograph the sealed box'
            : 'Photograph what\'s inside',
      );
      shots = [if (shot != null) shot];
    } else {
      final files = await _picker.pickMultiImage(
        maxWidth: 1600,
        imageQuality: 80,
        limit: room > 1 ? room : null,
      );
      shots = [for (final f in files.take(room)) await f.readAsBytes()];
    }
    if (shots.isEmpty || !mounted) return;
    await reportFailure(context, 'Could not add the photo', () async {
      for (final bytes in shots) {
        await actions.addPhoto(widget.unit, bytes, type: _type);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final photos = ref.watch(myPackingPhotosProvider(widget.unit.id));
    final busy = ref.watch(packingActionsProvider).isLoading;
    final actions = ref.read(packingActionsProvider.notifier);
    final room = maxPackingPhotos - photos.length;

    Widget step(String n, String text) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: AppColors.skyTint,
            child: Text(
              n,
              style: tt.bodySmall?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.accentDeep,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: tt.bodyMedium)),
        ],
      ),
    );

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
          Row(
            children: [
              const Icon(
                Icons.photo_camera_outlined,
                color: AppColors.accentDeep,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Pack & photograph this box',
                  style: tt.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          step('1', 'Photograph what\'s inside before you seal it.'),
          step('2', 'Seal it and stick its QR label on top.'),
          step('3', 'Photograph the sealed box with the label showing.'),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Your photos help you find things later and are the record of '
            'how you packed. Your driver sees them at collection.',
            style: tt.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          if (photos.isNotEmpty) ...[
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final photo in photos)
                  _PackingThumb(
                    photo: photo,
                    onRemove: busy
                        ? null
                        : () => reportFailure(
                            context,
                            'Could not remove the photo',
                            () => actions.removePhoto(widget.unit, photo),
                          ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          SegmentedButton<PhotoType>(
            segments: const [
              ButtonSegment(
                value: PhotoType.interior,
                icon: Icon(Icons.inventory_2_outlined, size: 18),
                label: Text('Contents'),
              ),
              ButtonSegment(
                value: PhotoType.exterior,
                icon: Icon(Icons.qr_code_2, size: 18),
                label: Text('Sealed box'),
              ),
            ],
            selected: {_type},
            onSelectionChanged: (v) => setState(() => _type = v.first),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
                onPressed: busy || room <= 0
                    ? null
                    : () => _add(ImageSource.camera, room),
                icon: const Icon(Icons.photo_camera_outlined, size: 18),
                label: const Text('Take photo'),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
                onPressed: busy || room <= 0
                    ? null
                    : () => _add(ImageSource.gallery, room),
                icon: const Icon(Icons.photo_library_outlined, size: 18),
                label: const Text('Upload'),
              ),
              if (busy)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              Text('${photos.length}/$maxPackingPhotos', style: tt.bodySmall),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _notes,
            maxLines: 3,
            maxLength: 500,
            decoration: const InputDecoration(
              labelText: 'What\'s inside?',
              hintText:
                  'e.g. Winter clothes, 2 pairs of boots, fragile '
                  'picture frame',
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: busy
                  ? null
                  : () => reportFailure(
                      context,
                      'Could not save the note',
                      () async {
                        await actions.saveNotes(widget.unit, _notes.text);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Saved')),
                          );
                        }
                      },
                    ),
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Save note'),
            ),
          ),
        ],
      ),
    );
  }
}

/// One of the client's packing photos, with a remove button.
class _PackingThumb extends StatelessWidget {
  const _PackingThumb({required this.photo, this.onRemove});

  final Photo photo;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      height: 88,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: AppRadius.sm,
              child: StorageImage(photo.storageUrl),
            ),
          ),
          Positioned(
            left: 4,
            bottom: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: const BoxDecoration(
                color: AppColors.navyDeep,
                borderRadius: AppRadius.pill,
              ),
              child: Text(
                photo.type == PhotoType.exterior ? 'Sealed' : 'Contents',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: AppColors.onAccent,
                ),
              ),
            ),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: Material(
              color: AppColors.navyDeep,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onRemove,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close, size: 14, color: AppColors.onAccent),
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
          child: StorageImage(photos[index].storageUrl, fit: BoxFit.contain),
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
              child: Icon(
                Icons.inventory_2_outlined,
                size: 40,
                color: AppColors.border,
              ),
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
              StorageImage(photos[index].storageUrl),
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
                  Positioned.fill(child: tile(0, radius: AppRadius.sm)),
                  Positioned(
                    top: AppSpacing.sm + 4,
                    left: AppSpacing.sm + 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm + 4,
                        vertical: 4,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: AppRadius.pill,
                      ),
                      child: Text(
                        'MAIN EXTERIOR',
                        style: tt.bodySmall?.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onAccent,
                        ),
                      ),
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
                              child: Text(
                                '+$extra\nView More',
                                textAlign: TextAlign.center,
                                style: tt.titleMedium?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
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
      child: LayoutBuilder(
        builder: (context, constraints) {
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
                child: const Icon(Icons.place_outlined, color: AppColors.navy),
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
                      Text(
                        'Last updated ${relativeTime(unit.updatedAt!)}',
                        style: tt.bodySmall,
                      ),
                  ],
                ),
              ),
            ],
          );
          final button = ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, 48),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
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
              canRequest ? 'Request This Back' : 'Already on the move',
            ),
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
        },
      ),
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
        LayoutBuilder(
          builder: (context, constraints) {
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
                        child: const Icon(
                          Icons.category_outlined,
                          color: AppColors.navy,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm + 4),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.label,
                              style: tt.labelLarge,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(item.qrCodeId, style: tt.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
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

    Widget label(String text) => Text(
      text.toUpperCase(),
      style: tt.bodySmall?.copyWith(letterSpacing: 0.8),
    );

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
                    Text(
                      unit.qrCodeId.isEmpty ? 'Pending' : unit.qrCodeId,
                      style: tt.titleMedium,
                    ),
                    if (unit.qrCodeId.isNotEmpty)
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 36),
                        ),
                        onPressed: () => printQrLabels(
                          [unit.qrCodeId],
                          labels: {unit.qrCodeId: unit.label},
                        ),
                        icon: const Icon(Icons.print_outlined, size: 18),
                        label: const Text('Print label'),
                      ),
                  ],
                ),
              ),
              if (unit.qrCodeId.isNotEmpty)
                QrImageView(
                  data: qrPayload(unit.qrCodeId),
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
                    Text(
                      prices.labelFor(unit.priceKey) ?? 'Being sized',
                      style: tt.bodyMedium,
                    ),
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
                    style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
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
            Text(
              '"${unit.description}"',
              style: tt.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondary,
              ),
            ),
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
            loading: () => const Center(child: CircularProgressIndicator()),
            // The audit trail is staff-only in firestore.rules; show the
            // empty state rather than a permission error.
            error: (_, _) => Text(
              'Activity for this unit will appear here.',
              style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            data: (list) => list.isEmpty
                ? Text(
                    'Activity for this unit will appear here.',
                    style: tt.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  )
                : Column(
                    children: [
                      for (final event in list)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
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
                                child: const Icon(
                                  Icons.shield_outlined,
                                  size: 18,
                                  color: AppColors.navy,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm + 4),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      auditTitle(event),
                                      style: tt.labelLarge,
                                    ),
                                    if (event.timestamp != null)
                                      Text(
                                        relativeTime(event.timestamp!),
                                        style: tt.bodySmall,
                                      ),
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
