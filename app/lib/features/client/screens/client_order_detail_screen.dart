// ignore_for_file: use_null_aware_elements
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/enums/app_enums.dart';
import '../../../core/models/job.dart';
import '../../../core/models/storage_unit.dart';
import '../../../core/providers/business_settings_provider.dart';
import '../../../core/providers/price_catalog_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadow.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/currency.dart';
import '../../../core/utils/public_ref.dart';
import '../../../core/widgets/contact_us_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/label_print_dialog.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/widgets/storage_image.dart';
import '../providers/client_providers.dart';
import '../utils/client_orders.dart';
import '../widgets/order_tile.dart';

final _day = DateFormat('EEE d MMM y');
final _time = DateFormat('EEE d MMM, HH:mm');

/// One order: where it's at, what's in it, when and where, and what it
/// costs. The items link to their pages in My Storage.
class ClientOrderDetailScreen extends ConsumerWidget {
  const ClientOrderDetailScreen({super.key, required this.jobId});

  final String jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobs = ref.watch(myJobsProvider);
    final job = ref.watch(myOrderProvider(jobId));
    final tt = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth > 900;
        final padding = EdgeInsets.all(desktop ? AppSpacing.lg : AppSpacing.md);

        if (job == null) {
          return SingleChildScrollView(
            padding: padding,
            child: Column(
              children: [
                const _BackRow(),
                if (jobs.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(AppSpacing.xxl),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  EmptyState(
                    icon: Icons.search_off,
                    title: 'Order not found',
                    subtitle:
                        'It may have been removed. Your current orders '
                        'are on the Orders page.',
                    action: ElevatedButton(
                      onPressed: () => context.go('/client/orders'),
                      child: const Text('See my orders'),
                    ),
                  ),
              ],
            ),
          );
        }

        final left = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProgressCard(job: job),
            const SizedBox(height: AppSpacing.lg),
            if (job.type == JobType.supplyDrop)
              _SuppliesCard(job: job)
            else
              _ItemsCard(job: job),
          ],
        );
        final right = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailsCard(job: job),
            if (job.onceOffZar > 0) ...[
              const SizedBox(height: AppSpacing.lg),
              _ChargesCard(job: job),
            ],
            if (job.linkedJobId != null) ...[
              const SizedBox(height: AppSpacing.lg),
              _LinkedOrder(jobId: job.linkedJobId!),
            ],
          ],
        );

        return SingleChildScrollView(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _BackRow(),
              Wrap(
                spacing: AppSpacing.sm + 4,
                runSpacing: AppSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(orderTitle(job), style: tt.displaySmall),
                  StatusChip(
                    status: job.status.name,
                    label: orderStatusLabel(job),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Order ${jobRef(job)} · ${orderNextStep(job)}',
                style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (desktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 60, child: left),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(flex: 40, child: right),
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

class _BackRow extends StatelessWidget {
  const _BackRow();

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: TextButton.icon(
        onPressed: () => context.go('/client/orders'),
        icon: const Icon(Icons.arrow_back, size: 18),
        label: const Text('Orders'),
      ),
    ),
  );
}

/// White card with a title row.
class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child, this.action});

  final String title;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
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
              Expanded(child: Text(title, style: tt.titleMedium)),
              if (action != null) action!,
            ],
          ),
          const SizedBox(height: AppSpacing.sm + 4),
          child,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- progress

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.job});

  final Job job;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final steps = orderSteps(job);
    final current = steps.indexWhere((step) => !step.done);
    final cancelled = job.status == JobStatus.cancelled;

    return _Card(
      title: 'Progress',
      child: Column(
        children: [
          for (var i = 0; i < steps.length; i++)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    child: Column(
                      children: [
                        _Dot(
                          done: steps[i].done,
                          current: i == current,
                          error: cancelled && i == steps.length - 1,
                        ),
                        if (i < steps.length - 1)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: steps[i + 1].done
                                  ? AppColors.accentDeep
                                  : AppColors.border,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm + 4),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            steps[i].label,
                            style: tt.titleSmall?.copyWith(
                              color: steps[i].done || i == current
                                  ? AppColors.textPrimary
                                  : AppColors.textHint,
                            ),
                          ),
                          if (steps[i].at != null)
                            Text(
                              _time.format(steps[i].at!),
                              style: tt.bodySmall,
                            ),
                          if (steps[i].note != null)
                            Text(steps[i].note!, style: tt.bodySmall),
                        ],
                      ),
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

class _Dot extends StatelessWidget {
  const _Dot({required this.done, required this.current, this.error = false});

  final bool done;
  final bool current;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final colour = error
        ? AppColors.statusError
        : done || current
        ? AppColors.accentDeep
        : AppColors.border;
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? colour : AppColors.surface,
        border: Border.all(color: colour, width: 2),
      ),
      child: done
          ? Icon(
              error ? Icons.close : Icons.check,
              size: 12,
              color: AppColors.onAccent,
            )
          : null,
    );
  }
}

// ------------------------------------------------------------------ items

class _ItemsCard extends ConsumerWidget {
  const _ItemsCard({required this.job});

  final Job job;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final all = ref.watch(myUnitsProvider).valueOrNull ?? const [];
    final ids = job.storageUnitIds.toSet();
    final units = [
      for (final unit in all)
        if (ids.contains(unit.id)) unit,
    ];
    final toPack = units
        .where((u) => u.status == StorageStatus.pendingPickup)
        .toList();
    final packing =
        job.type == JobType.pickup && job.status.isOpen && toPack.isNotEmpty;
    final photographed = toPack.where((u) => u.photoIds.isNotEmpty).length;

    return _Card(
      title: 'Items in this order (${job.storageUnitIds.length})',
      action: toPack.any((u) => u.qrCodeId.isNotEmpty)
          ? TextButton.icon(
              onPressed: () => LabelPrintDialog.show(
                context,
                units: units,
                preselected: {for (final u in toPack) u.id},
              ),
              icon: const Icon(Icons.print_outlined, size: 18),
              label: const Text('Print labels'),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (packing) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sm + 4),
              decoration: const BoxDecoration(
                color: AppColors.skyTint,
                borderRadius: AppRadius.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Getting ready for pickup',
                    style: tt.titleSmall?.copyWith(color: AppColors.accentDeep),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '1. Print the labels and stick one on each box or item '
                    '(no printer? your driver brings them).\n'
                    '2. Tap each item to photograph what you pack and note '
                    'what\'s inside.',
                    style: tt.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ClipRRect(
                    borderRadius: AppRadius.pill,
                    child: LinearProgressIndicator(
                      value: photographed / toPack.length,
                      minHeight: 6,
                      backgroundColor: AppColors.surface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '$photographed of ${toPack.length} photographed',
                    style: tt.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm + 4),
          ],
          if (units.isEmpty)
            Text('The items will show here shortly.', style: tt.bodySmall)
          else
            for (final unit in units) _UnitRow(unit: unit, packing: packing),
        ],
      ),
    );
  }
}

class _UnitRow extends ConsumerWidget {
  const _UnitRow({required this.unit, required this.packing});

  final StorageUnit unit;
  final bool packing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final photos = ref.watch(clientUnitPhotosProvider(unit.id)).valueOrNull;
    final url = photos == null || photos.isEmpty
        ? null
        : photos.first.storageUrl;
    final hint = packing && unit.status == StorageStatus.pendingPickup
        ? (unit.photoIds.isEmpty
              ? 'Add photos'
              : '${unit.photoIds.length} photo${unit.photoIds.length == 1 ? '' : 's'}')
        : null;

    return InkWell(
      borderRadius: AppRadius.sm,
      onTap: () => context.go('/client/storage/${unit.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: AppRadius.sm,
              child: SizedBox(
                width: 48,
                height: 48,
                child: url == null
                    ? const ColoredBox(
                        color: AppColors.surfaceContainer,
                        child: Icon(
                          Icons.inventory_2_outlined,
                          color: AppColors.textHint,
                          size: 22,
                        ),
                      )
                    : StorageImage(url, width: 48, height: 48),
              ),
            ),
            const SizedBox(width: AppSpacing.sm + 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    unit.label.isEmpty ? 'Storage unit' : unit.label,
                    style: tt.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    [
                      if (unit.qrCodeId.isNotEmpty) unit.qrCodeId,
                      if (hint != null) hint,
                    ].join(' · '),
                    style: tt.bodySmall?.copyWith(
                      color: hint == 'Add photos'
                          ? AppColors.accentDeep
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            StatusChip(status: unit.status.name),
            const Icon(Icons.chevron_right, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}

class _SuppliesCard extends ConsumerWidget {
  const _SuppliesCard({required this.job});

  final Job job;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final prices = ref.watch(priceCatalogProvider);
    final boxes = job.emptyBoxes.entries.where((e) => e.value > 0).toList();
    return _Card(
      title: 'What we\'re bringing',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final box in boxes)
            _Line(
              label: 'Empty box — ${prices.box(box.key)?.label ?? box.key}',
              value: '× ${box.value}',
            ),
          for (final line in job.supplies)
            _Line(label: line.label, value: '× ${line.qty}'),
          if (boxes.isEmpty && job.supplies.isEmpty)
            Text('Your packing supplies.', style: tt.bodySmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Plus a QR label for each item on your pickup.',
            style: tt.bodySmall,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- details

class _DetailsCard extends ConsumerWidget {
  const _DetailsCard({required this.job});

  final Job job;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(businessSettingsProvider);
    final address = job.address;
    final where = [
      address.line1,
      if (address.line2?.isNotEmpty == true) address.line2!,
      address.city,
      address.postCode,
    ].where((part) => part.trim().isNotEmpty).join(', ');
    final driver = job.driverId != null && job.status.isOpen
        ? '${job.driverName ?? 'Your driver'} · E-ID ${staffRef(job.driverId!)}'
        : null;

    return _Card(
      title: 'Details',
      child: Column(
        children: [
          _Info(
            icon: Icons.event_outlined,
            label: 'When',
            value: job.scheduledDate == null
                ? 'To be confirmed'
                : '${_day.format(job.scheduledDate!)}\n'
                      '${settings.windowLabel(job.timeWindow)}',
          ),
          _Info(
            icon: Icons.location_on_outlined,
            label: job.type == JobType.pickup ? 'Collect from' : 'Deliver to',
            value: where.isEmpty ? '—' : where,
          ),
          if (driver != null)
            _Info(
              icon: Icons.badge_outlined,
              label: 'Your driver',
              value: '$driver\nCheck the E-ID on their card when they arrive.',
            ),
          if (job.accessNotes?.isNotEmpty == true)
            _Info(
              icon: Icons.key_outlined,
              label: 'Access',
              value: job.accessNotes!,
            ),
          if (job.notes?.isNotEmpty == true)
            _Info(
              icon: Icons.notes_outlined,
              label: 'Notes',
              value: job.notes!,
            ),
          if (job.helperHours > 0)
            _Info(
              icon: Icons.people_outline,
              label: 'Packing helper',
              value: '${job.helperHours} hours',
            ),
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm + 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.accentDeep),
          const SizedBox(width: AppSpacing.sm + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: tt.bodySmall),
                Text(value, style: tt.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChargesCard extends StatelessWidget {
  const _ChargesCard({required this.job});

  final Job job;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return _Card(
      title: 'Once-off charges',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final line in job.supplies)
            _Line(
              label: '${line.label} × ${line.qty}',
              value: formatZar(line.unitZar * line.qty),
            ),
          const Divider(height: AppSpacing.lg),
          _Line(
            label: 'Total once-off',
            value: formatZar(job.onceOffZar),
            bold: true,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            job.invoicedIn != null
                ? 'Billed on your ${invoiceMonthLabel(job.invoicedIn!)} '
                      'invoice.'
                : 'Includes the pickup vehicle and any packing help. Billed '
                      'on your next monthly invoice once the job is done.',
            style: tt.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value, this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final style = bold ? tt.titleSmall : tt.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }
}

/// The paired order (a pickup's supply drop-off, or the other way round).
class _LinkedOrder extends ConsumerWidget {
  const _LinkedOrder({required this.jobId});

  final String jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linked = ref.watch(myOrderProvider(jobId));
    if (linked == null) return const SizedBox.shrink();
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          linked.type == JobType.supplyDrop
              ? 'Your supplies arrive first'
              : 'The pickup these supplies are for',
          style: tt.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        OrderTile(job: linked),
      ],
    );
  }
}
