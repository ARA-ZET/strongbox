import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/relative_time.dart';
import '../../../core/widgets/photo_upload_zone.dart';
import '../../../core/widgets/qr_display_card.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/models/storage_unit.dart';
import '../../../core/models/item.dart';
import '../../../core/models/job.dart';
import '../providers/clients_providers.dart';
import '../providers/inventory_providers.dart';
import '../utils/qr_pdf_generator.dart';

/// Single box view: inspection photos, items inside, QR panel and job
/// history timeline. Design: admin_box_detail/screen.png.
class AdminBoxDetailScreen extends ConsumerWidget {
  const AdminBoxDetailScreen({super.key, required this.boxId});

  final String boxId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final box = ref.watch(unitByIdProvider(boxId));
    final textTheme = Theme.of(context).textTheme;

    return box.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('Could not load box: $error',
            style:
                textTheme.bodyMedium?.copyWith(color: AppColors.statusError)),
      ),
      data: (model) {
        if (model == null) {
          return Center(
              child: Text('Box not found.', style: textTheme.titleMedium));
        }
        return _BoxDetailBody(box: model);
      },
    );
  }
}

class _BoxDetailBody extends ConsumerWidget {
  const _BoxDetailBody({required this.box});

  final StorageUnit box;

  Future<void> _editLabel(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(text: box.label);
    final label = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Edit Label'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Box label'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (label != null) {
      await ref.read(unitMutationsProvider.notifier).updateLabel(box.id, label);
    }
  }

  Future<void> _archive(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Archive this box?'),
        content: Text(
            'Box ${box.qrCodeId} will be removed from active inventory and '
            'released from the client\'s storage allowance.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusError,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Archive'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(unitMutationsProvider.notifier).archiveUnit(box);
    if (context.mounted) context.go('/admin/inventory');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final clientNames = ref.watch(clientNamesProvider);

    return LayoutBuilder(builder: (context, constraints) {
      final desktop = constraints.maxWidth > 900;

      final leftColumn = Column(
        children: [
          _PhotosCard(box: box),
          if (box.type == UnitType.open) ...[
            const SizedBox(height: 24),
            _ItemsCard(box: box),
          ],
        ],
      );
      final rightColumn = Column(
        children: [
          QRDisplayCard(
            qrData: box.qrCodeId,
            label: box.qrCodeId,
            onPrint: () => printQrLabels(
              [box.qrCodeId],
              labels: {box.qrCodeId: box.label},
            ),
          ),
          const SizedBox(height: 24),
          _DetailsCard(box: box, ownerName: clientNames[box.clientId]),
          const SizedBox(height: 24),
          const _ScannerPromoCard(),
        ],
      );

      return SingleChildScrollView(
        padding: EdgeInsets.all(desktop ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, size: 20),
                  onPressed: () => context.go('/admin/inventory'),
                ),
                Flexible(
                  child: Text(
                    'Inventory / Box #${box.qrCodeId}',
                    style: textTheme.bodyMedium
                        ?.copyWith(color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('Storage Unit #${box.qrCodeId}',
                    style: textTheme.displaySmall),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onPressed: () => _editLabel(context, ref),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit Label'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onPressed: () => printQrLabels(
                    [box.qrCodeId],
                    labels: {box.qrCodeId: box.label},
                  ),
                  icon: const Icon(Icons.print_outlined, size: 18),
                  label: const Text('Print QR'),
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.statusError,
                    side: const BorderSide(color: AppColors.statusError),
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onPressed: () => _archive(context, ref),
                  icon: const Icon(Icons.archive_outlined, size: 18),
                  label: const Text('Archive'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (desktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 65, child: leftColumn),
                  const SizedBox(width: 24),
                  Expanded(flex: 35, child: rightColumn),
                ],
              )
            else ...[
              leftColumn,
              const SizedBox(height: 24),
              rightColumn,
            ],
            const SizedBox(height: 24),
            _JobHistoryTimeline(boxId: box.id),
          ],
        ),
      );
    });
  }
}

// -------------------------------------------------- inspection photos card

class _PhotosCard extends ConsumerWidget {
  const _PhotosCard({required this.box});

  final StorageUnit box;

  Future<void> _addPhotos(WidgetRef ref) async {
    final picked = await ImagePicker().pickMultiImage(imageQuality: 85);
    if (picked.isEmpty) return;
    final bytes = await Future.wait(picked.map((file) => file.readAsBytes()));
    await ref.read(unitMutationsProvider.notifier).addPhotos(box.id, bytes);
  }

  void _openLightbox(BuildContext context, String url) {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black87,
        insetPadding: const EdgeInsets.all(24),
        child: InteractiveViewer(
          child: CachedNetworkImage(imageUrl: url, fit: BoxFit.contain),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final photos =
        ref.watch(entityPhotosProvider(box.id)).valueOrNull ?? const [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [AppTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Inspection Photos', style: textTheme.headlineSmall),
              TextButton.icon(
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.amberDark),
                onPressed: () => _addPhotos(ref),
                icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                label: const Text('Add New'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (photos.isEmpty)
            PhotoUploadZone(
              onPhotosSelected: (bytes) => ref
                  .read(unitMutationsProvider.notifier)
                  .addPhotos(box.id, bytes),
            )
          else
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: photos.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) => InkWell(
                  onTap: () =>
                      _openLightbox(context, photos[index].storageUrl),
                  borderRadius: BorderRadius.circular(8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: photos[index].storageUrl,
                      width: 150,
                      height: 120,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => const SizedBox(
                        width: 150,
                        child:
                            ColoredBox(color: AppColors.surfaceContainer),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// --------------------------------------------------------- items inside

class _ItemsCard extends ConsumerWidget {
  const _ItemsCard({required this.box});

  final StorageUnit box;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(unitItemsProvider(box.id));
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [AppTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Items Inside', style: textTheme.headlineSmall),
          const SizedBox(height: 16),
          items.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text('Could not load items: $error',
                style: textTheme.bodyMedium
                    ?.copyWith(color: AppColors.statusError)),
            data: (list) => LayoutBuilder(builder: (context, constraints) {
              final columns = constraints.maxWidth > 560 ? 2 : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  mainAxisExtent: 104,
                ),
                itemCount: list.length + 1,
                itemBuilder: (context, index) {
                  if (index == list.length) {
                    return _AddItemGhost(box: box);
                  }
                  return _ItemTile(item: list[index]);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({required this.item});

  final Item item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 80,
              height: 80,
              color: AppColors.border.withValues(alpha: 0.4),
              child: const Icon(Icons.category_outlined,
                  color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (item.description ?? '').isEmpty
                      ? item.qrCodeId
                      : item.description!,
                  style: textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(item.qrCodeId, style: textTheme.bodySmall),
                const SizedBox(height: 6),
                StatusChip(status: item.status.name),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddItemGhost extends ConsumerWidget {
  const _AddItemGhost({required this.box});

  final StorageUnit box;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => showDialog<void>(
        context: context,
        builder: (_) => _AddItemDialog(box: box),
      ),
      borderRadius: BorderRadius.circular(8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, color: AppColors.amberDark),
            const SizedBox(width: 8),
            Text('Add Item',
                style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
      ),
    );
  }
}

class _AddItemDialog extends ConsumerStatefulWidget {
  const _AddItemDialog({required this.box});

  final StorageUnit box;

  @override
  ConsumerState<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends ConsumerState<_AddItemDialog> {
  final _description = TextEditingController();
  StorageStatus _status = StorageStatus.inStorage;
  List<Uint8List> _photos = [];
  bool _saving = false;

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_description.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      await ref.read(unitMutationsProvider.notifier).addItem(
            unit: widget.box,
            description: _description.text.trim(),
            status: _status,
            photos: _photos,
          );
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not add item: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Item', style: textTheme.headlineSmall),
              const SizedBox(height: 20),
              Text('Description', style: textTheme.labelLarge),
              const SizedBox(height: 6),
              TextField(
                controller: _description,
                decoration: const InputDecoration(
                    hintText: 'e.g. RF-Scanner Z10 · Qty 2'),
              ),
              const SizedBox(height: 16),
              Text('Status', style: textTheme.labelLarge),
              const SizedBox(height: 6),
              DropdownButtonFormField<StorageStatus>(
                initialValue: _status,
                items: const [
                  DropdownMenuItem(
                      value: StorageStatus.inStorage,
                      child: Text('In Storage')),
                  DropdownMenuItem(
                      value: StorageStatus.inTransit,
                      child: Text('In Transit')),
                  DropdownMenuItem(
                      value: StorageStatus.delivered,
                      child: Text('Delivered')),
                ],
                onChanged: (value) =>
                    setState(() => _status = value ?? StorageStatus.inStorage),
              ),
              const SizedBox(height: 16),
              Text('Photos', style: textTheme.labelLarge),
              const SizedBox(height: 6),
              PhotoUploadZone(
                photos: _photos,
                onPhotosSelected: (bytes) =>
                    setState(() => _photos = [..._photos, ...bytes]),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _saving ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.amberDark),
                          )
                        : const Text('Add Item'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------------- details card

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.box, this.ownerName});

  final StorageUnit box;
  final String? ownerName;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    Widget row(String label, Widget value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: textTheme.bodyMedium
                      ?.copyWith(color: AppColors.textSecondary)),
              value,
            ],
          ),
        );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [AppTheme.cardShadow],
      ),
      child: Column(
        children: [
          Center(child: StatusChip(status: box.status.name)),
          const SizedBox(height: 8),
          const Divider(),
          row(
            'Unique ID',
            Text(box.qrCodeId,
                style: textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
          ),
          row(
            'Created Date',
            Text(DateFormat('MMM d, y').format(box.createdAt ?? DateTime.now()),
                style: textTheme.bodyMedium),
          ),
          row(
            'Owner',
            Text(ownerName ?? 'Warehouse',
                style: textTheme.bodyMedium),
          ),
          row(
            'Security Seal',
            Row(
              children: [
                const Icon(Icons.verified_outlined,
                    size: 16, color: AppColors.statusSuccess),
                const SizedBox(width: 4),
                Text('Verified',
                    style: textTheme.bodyMedium
                        ?.copyWith(color: AppColors.statusSuccess)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------- scanner promo card

class _ScannerPromoCard extends StatelessWidget {
  const _ScannerPromoCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.qr_code_scanner,
              color: AppColors.amber, size: 32),
          const SizedBox(height: 12),
          Text('Need an Update?',
              style: textTheme.titleMedium?.copyWith(color: Colors.white)),
          const SizedBox(height: 6),
          Text(
            'Scan to update location or report contents damage.',
            textAlign: TextAlign.center,
            style: textTheme.bodySmall
                ?.copyWith(color: Colors.white.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go('/admin/qr?tab=link'),
              child: const Text('Open Mobile Scanner'),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------ history timeline

class _JobHistoryTimeline extends ConsumerWidget {
  const _JobHistoryTimeline({required this.boxId});

  final String boxId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobs = ref.watch(unitJobsProvider(boxId));
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [AppTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Job History', style: textTheme.headlineSmall),
          const SizedBox(height: 16),
          jobs.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text('Could not load history: $error',
                style: textTheme.bodyMedium
                    ?.copyWith(color: AppColors.statusError)),
            data: (list) => list.isEmpty
                ? Text('No jobs have touched this box yet.',
                    style: textTheme.bodyMedium
                        ?.copyWith(color: AppColors.textSecondary))
                : Column(
                    children: [
                      for (final (index, job) in list.indexed)
                        _timelineEntry(job, index == 0,
                            index == list.length - 1, textTheme),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _timelineEntry(
      Job job, bool isLatest, bool isLast, TextTheme textTheme) {
    final title = job.type == JobType.pickup
        ? 'Pickup — ${_statusLabel(job.status.name)}'
        : 'Delivery — ${_statusLabel(job.status.name)}';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: isLatest ? AppColors.amberDark : AppColors.navy,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                const Expanded(
                  child: VerticalDivider(
                      width: 12, thickness: 1.5, color: AppColors.border),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  Text(
                    '${job.storageUnitIds.length} boxes on job'
                    '${job.notes == null || job.notes!.isEmpty ? '' : ' • ${job.notes}'}',
                    style: textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          Text(relativeTime(job.scheduledDate ?? DateTime.now()), style: textTheme.bodySmall),
        ],
      ),
    );
  }

  String _statusLabel(String status) => status
      .split('_')
      .map((word) =>
          word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');
}
