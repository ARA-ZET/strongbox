import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/pricing.dart';
import '../../../core/providers/business_settings_provider.dart';
import '../../../core/providers/price_catalog_provider.dart';
import '../../../core/utils/currency.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/widgets/step_indicator.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/models/storage_unit.dart';
import '../providers/clients_providers.dart';
import '../providers/inventory_providers.dart';
import '../providers/jobs_providers.dart';

/// 4-step Create New Job wizard: Type → Items → Schedule → Confirm.
/// Designs: admin_create_new_job_step_1…4.
class AdminNewJobScreen extends ConsumerStatefulWidget {
  const AdminNewJobScreen({super.key});

  @override
  ConsumerState<AdminNewJobScreen> createState() => _AdminNewJobScreenState();
}

class _AdminNewJobScreenState extends ConsumerState<AdminNewJobScreen> {
  int _step = 0;
  bool _submitting = false;

  void _next() => setState(() => _step = (_step + 1).clamp(0, 3));
  void _back() => setState(() => _step = (_step - 1).clamp(0, 3));

  void _cancel() {
    ref.read(newJobDraftProvider.notifier).reset();
    context.go('/admin/jobs');
  }

  Future<void> _submit({required bool asDraft}) async {
    final data = ref.read(newJobDraftProvider);
    setState(() => _submitting = true);
    try {
      await ref
          .read(jobMutationsProvider.notifier)
          .submit(data, asDraft: asDraft);
      ref.read(newJobDraftProvider.notifier).reset();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(asDraft ? 'Draft saved' : 'Job submitted')),
        );
        context.go('/admin/jobs');
      }
    } catch (error) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save job: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(newJobDraftProvider);
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(builder: (context, constraints) {
      final desktop = constraints.maxWidth > 900;

      return SingleChildScrollView(
        padding: EdgeInsets.all(desktop ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create New Job', style: textTheme.displaySmall),
            const SizedBox(height: 4),
            Text(
              'Configure the service type and operational parameters.',
              style: textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            StepIndicator(
              steps: const ['Type', 'Items', 'Schedule', 'Confirm'],
              currentStep: _step,
            ),
            const SizedBox(height: 24),
            switch (_step) {
              0 => _TypeStep(
                  draft: draft,
                  onCancel: _cancel,
                  onNext: _next,
                ),
              1 => _ItemsStep(
                  draft: draft,
                  desktop: desktop,
                  onBack: _back,
                  onNext: _next,
                ),
              2 => _ScheduleStep(
                  draft: draft,
                  submitting: _submitting,
                  onBack: _back,
                  onSaveDraft: () => _submit(asDraft: true),
                  onNext: _next,
                ),
              _ => _ConfirmStep(
                  draft: draft,
                  desktop: desktop,
                  submitting: _submitting,
                  onSubmit: () => _submit(asDraft: false),
                  onSaveDraft: () => _submit(asDraft: true),
                ),
            },
          ],
        ),
      );
    });
  }
}

// ---------------------------------------------------------- step 1: type

class _TypeStep extends ConsumerWidget {
  const _TypeStep({
    required this.draft,
    required this.onCancel,
    required this.onNext,
  });

  final NewJobData draft;
  final VoidCallback onCancel;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(builder: (context, constraints) {
          final wide = constraints.maxWidth > 700;
          final cards = [
            _TypeCard(
              selected: draft.type == JobType.pickup,
              icon: Icons.forklift,
              iconBg: AppColors.navy,
              title: 'Pickup Request',
              description:
                  'Arrange for goods to be collected from a client or '
                  'warehouse location. Best for inbound inventory management.',
              bullets: const [
                'Quality control at source',
                'Standard collection windows',
              ],
              onTap: () =>
                  ref.read(newJobDraftProvider.notifier).setType(JobType.pickup),
            ),
            _TypeCard(
              selected: draft.type == JobType.delivery,
              icon: Icons.local_shipping,
              iconBg: AppColors.accent,
              title: 'Delivery Request',
              description:
                  'Schedule an outbound shipment back to the client. '
                  'Optimized for speed and tracking.',
              bullets: const [
                'Real-time carrier tracking',
                'Proof of delivery required',
              ],
              onTap: () =>
                  ref.read(newJobDraftProvider.notifier).setType(JobType.delivery),
            ),
          ];
          if (wide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: cards[0]),
                const SizedBox(width: 24),
                Expanded(child: cards[1]),
              ],
            );
          }
          return Column(
            children: [cards[0], const SizedBox(height: 16), cards[1]],
          );
        }),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.skyTint,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.bolt, color: AppColors.accentDeep),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Rush Processing — available for delivery within 4 hours.',
                  style: textTheme.bodyMedium
                      ?.copyWith(color: AppColors.accentDeep),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 12),
        Row(
          children: [
            TextButton.icon(
              onPressed: onCancel,
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Cancel Job'),
            ),
            const Spacer(),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 48),
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              onPressed: draft.type == null ? null : onNext,
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: const Text('Next Step'),
            ),
          ],
        ),
      ],
    );
  }
}

class _TypeCard extends StatelessWidget {
  const _TypeCard({
    required this.selected,
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.description,
    required this.bullets,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final Color iconBg;
  final String title;
  final String description;
  final List<String> bullets;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? AppColors.accentDeep : AppColors.border,
                width: selected ? 2 : 1,
              ),
              boxShadow: const [AppTheme.cardShadow],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration:
                      BoxDecoration(color: iconBg, shape: BoxShape.circle),
                  child: Icon(icon,
                      color: iconBg == AppColors.accent
                          ? AppColors.onAccent
                          : AppColors.accent,
                      size: 28),
                ),
                const SizedBox(height: 16),
                Text(title, style: textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(description,
                    style: textTheme.bodyMedium
                        ?.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                for (final bullet in bullets)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline,
                            size: 16, color: AppColors.statusSuccess),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(bullet,
                                style: textTheme.bodyMedium)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (selected)
            const Positioned(
              top: 16,
              right: 16,
              child: Icon(Icons.check_circle, color: AppColors.accentDeep),
            ),
        ],
      ),
    );
  }
}

// --------------------------------------------------------- step 2: items

class _ItemsStep extends ConsumerWidget {
  const _ItemsStep({
    required this.draft,
    required this.desktop,
    required this.onBack,
    required this.onNext,
  });

  final NewJobData draft;
  final bool desktop;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clients = ref.watch(clientsProvider).valueOrNull ?? [];
    final allBoxes = ref.watch(allUnitsProvider).valueOrNull ?? <StorageUnit>[];
    final textTheme = Theme.of(context).textTheme;

    // Delivery jobs pull from storage; pickups collect anything not
    // already in the warehouse.
    final clientBoxes = allBoxes.where((box) {
      if (box.clientId != draft.clientId || box.status == StorageStatus.archived) {
        return false;
      }
      return draft.type == JobType.delivery ? box.status == StorageStatus.inStorage : true;
    }).toList();

    final selection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Client Account', style: textTheme.labelLarge),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: draft.clientId,
          hint: const Text('Select client account'),
          items: [
            for (final client in clients)
              DropdownMenuItem(value: client.id, child: Text(client.displayName)),
          ],
          onChanged: (value) =>
              ref.read(newJobDraftProvider.notifier).setClient(value),
        ),
        const SizedBox(height: 16),
        if (draft.clientId != null) ...[
          Row(
            children: [
              Checkbox(
                value: clientBoxes.isNotEmpty &&
                    draft.unitIds.length == clientBoxes.length,
                onChanged: (checked) {
                  final notifier = ref.read(newJobDraftProvider.notifier);
                  notifier.setUnits(checked == true
                      ? clientBoxes.map((box) => box.id).toSet()
                      : {});
                },
              ),
              Text('Select All Items', style: textTheme.labelLarge),
              const Spacer(),
              Text('Showing ${clientBoxes.length} items',
                  style: textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 8),
          if (clientBoxes.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                draft.type == JobType.delivery
                    ? 'This client has no boxes in storage to deliver.'
                    : 'This client has no registered boxes yet — add them '
                        'from the Inventory screen first.',
                style: textTheme.bodyMedium
                    ?.copyWith(color: AppColors.textSecondary),
              ),
            )
          else
            LayoutBuilder(builder: (context, constraints) {
              final columns = constraints.maxWidth > 560 ? 2 : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  mainAxisExtent: 210,
                ),
                itemCount: clientBoxes.length,
                itemBuilder: (context, index) {
                  final box = clientBoxes[index];
                  return _SelectableBoxCard(
                    box: box,
                    selected: draft.unitIds.contains(box.id),
                    onToggle: () => ref
                        .read(newJobDraftProvider.notifier)
                        .toggleUnit(box.id),
                  );
                },
              );
            }),
        ],
      ],
    );

    final summary = _JobSummarySidebar(
      draft: draft,
      boxes: allBoxes,
      onBack: onBack,
      onNext: draft.unitIds.isEmpty ? null : onNext,
    );

    if (desktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: selection),
          const SizedBox(width: 24),
          SizedBox(width: 300, child: summary),
        ],
      );
    }
    return Column(
      children: [selection, const SizedBox(height: 24), summary],
    );
  }
}

class _SelectableBoxCard extends StatelessWidget {
  const _SelectableBoxCard({
    required this.box,
    required this.selected,
    required this.onToggle,
  });

  final StorageUnit box;
  final bool selected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.accentDeep : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                const SizedBox(
                  height: 110,
                  width: double.infinity,
                  child: ColoredBox(
                    color: AppColors.surfaceContainer,
                    child: Icon(Icons.inventory_2_outlined,
                        size: 32, color: AppColors.border),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.accent : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: selected
                              ? AppColors.accent
                              : AppColors.border),
                    ),
                    child: selected
                        ? const Icon(Icons.check,
                            size: 16, color: AppColors.onAccent)
                        : null,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    box.label.isEmpty ? box.qrCodeId : box.label,
                    style: textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(box.qrCodeId, style: textTheme.bodySmall),
                  const SizedBox(height: 6),
                  StatusChip(status: box.status.name),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JobSummarySidebar extends StatelessWidget {
  const _JobSummarySidebar({
    required this.draft,
    required this.boxes,
    required this.onBack,
    required this.onNext,
  });

  final NewJobData draft;
  final List<StorageUnit> boxes;
  final VoidCallback onBack;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final selected =
        boxes.where((box) => draft.unitIds.contains(box.id)).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Job Summary',
              style: textTheme.titleMedium?.copyWith(color: Colors.white)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Selected Items',
                  style:
                      textTheme.bodyMedium?.copyWith(color: Colors.white70)),
              Text('${selected.length}',
                  style: textTheme.headlineSmall
                      ?.copyWith(color: AppColors.sky)),
            ],
          ),
          const SizedBox(height: 8),
          for (final box in selected.take(6))
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 6, color: AppColors.sky),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      box.label.isEmpty ? box.qrCodeId : box.label,
                      style: textTheme.bodySmall
                          ?.copyWith(color: Colors.white70),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          if (selected.length > 6)
            Text('+ ${selected.length - 6} more',
                style:
                    textTheme.bodySmall?.copyWith(color: Colors.white70)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onNext,
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: const Text('Next Step: Logistics'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white54),
              ),
              onPressed: onBack,
              child: const Text('Back to Details'),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------ step 3: schedule

class _ScheduleStep extends ConsumerWidget {
  const _ScheduleStep({
    required this.draft,
    required this.submitting,
    required this.onBack,
    required this.onSaveDraft,
    required this.onNext,
  });

  final NewJobData draft;
  final bool submitting;
  final VoidCallback onBack;
  final VoidCallback onSaveDraft;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drivers = ref.watch(driverUsersProvider).valueOrNull ?? [];
    final settings = ref.watch(businessSettingsProvider);
    final textTheme = Theme.of(context).textTheme;
    final notifier = ref.read(newJobDraftProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [AppTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Job Schedule & Assignment', style: textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            'Define when this operation should take place and assign the '
            'responsible personnel.',
            style: textTheme.bodyMedium
                ?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(builder: (context, constraints) {
            final wide = constraints.maxWidth > 640;
            final dateField = _labelled(
              'Scheduled Date',
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  alignment: Alignment.centerLeft,
                  side: const BorderSide(color: AppColors.border),
                  foregroundColor: AppColors.textPrimary,
                  textStyle: textTheme.bodyMedium,
                ),
                onPressed: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: draft.scheduledDate ??
                        now.add(const Duration(days: 1)),
                    firstDate: now,
                    lastDate: now.add(const Duration(days: 365)),
                  );
                  if (picked != null) notifier.setSchedule(date: picked);
                },
                icon: const Icon(Icons.calendar_today_outlined, size: 18),
                label: Text(
                  draft.scheduledDate == null
                      ? 'Pick a date'
                      : DateFormat('MM/dd/yyyy')
                          .format(draft.scheduledDate!),
                ),
              ),
              textTheme,
              hint: 'Current lead time for most routes is 48 hours. '
                  'Service area: ${settings.serviceArea}.',
            );
            final windowField = _labelled(
              'Time Window',
              DropdownButtonFormField<TimeWindow>(
                initialValue: draft.timeWindow,
                items: [
                  for (final window in TimeWindow.values)
                    DropdownMenuItem(
                        value: window,
                        child: Text(settings.windowLabel(window))),
                ],
                onChanged: (value) =>
                    notifier.setSchedule(timeWindow: value),
              ),
              textTheme,
            );
            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: dateField),
                  const SizedBox(width: 24),
                  Expanded(child: windowField),
                ],
              );
            }
            return Column(
                children: [dateField, const SizedBox(height: 16), windowField]);
          }),
          const SizedBox(height: 20),
          _labelled(
            'Driver Assignment',
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: draft.driverId,
                    hint: const Text('Assign later (optional)'),
                    items: [
                      for (final driver in drivers)
                        DropdownMenuItem(
                            value: driver.id, child: Text(driver.name)),
                    ],
                    onChanged: (value) =>
                        notifier.setSchedule(driverId: value),
                  ),
                ),
                if (draft.driverId != null) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.statusSuccessBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'DRIVER STATUS\nFully Certified',
                      style: textTheme.bodySmall?.copyWith(
                          color: AppColors.statusSuccess,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ],
            ),
            textTheme,
          ),
          const SizedBox(height: 20),
          _labelled(
            'Dispatch Notes & Special Instructions',
            TextFormField(
              initialValue: draft.notes,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText:
                    'Enter gate codes, special handling instructions, or '
                    'client preferences here...',
              ),
              onChanged: notifier.setNotes,
            ),
            textTheme,
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TextButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Back to Items'),
              ),
              OutlinedButton(
                onPressed: submitting ? null : onSaveDraft,
                child: const Text('Save as Draft'),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
                onPressed: draft.scheduledDate == null ? null : onNext,
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text('Review & Confirm'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _labelled(String label, Widget child, TextTheme textTheme,
      {String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.labelLarge),
        const SizedBox(height: 8),
        child,
        if (hint != null) ...[
          const SizedBox(height: 6),
          Text(hint, style: textTheme.bodySmall),
        ],
      ],
    );
  }
}

// ------------------------------------------------------ step 4: confirm

class _ConfirmStep extends ConsumerWidget {
  const _ConfirmStep({
    required this.draft,
    required this.desktop,
    required this.submitting,
    required this.onSubmit,
    required this.onSaveDraft,
  });

  final NewJobData draft;
  final bool desktop;
  final bool submitting;
  final VoidCallback onSubmit;
  final VoidCallback onSaveDraft;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final settings = ref.watch(businessSettingsProvider);
    final boxes = ref.watch(allUnitsProvider).valueOrNull ?? <StorageUnit>[];
    final clientNames = ref.watch(clientNamesProvider);
    final driverNames = ref.watch(driverNamesProvider);
    final selected =
        boxes.where((box) => draft.unitIds.contains(box.id)).toList();
    final prices = ref.watch(priceCatalogProvider);
    final storage = StorageBill.fromUnits(
        selected.map((unit) => unit.copyWith(status: StorageStatus.inStorage)),
        prices);
    final pickup = draft.type == JobType.pickup;
    final vehicleFees = prices.activeVehicles.map((v) => v.onceOffZar).toList()
      ..sort();

    final overview = Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [AppTheme.cardShadow],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Job Overview', style: textTheme.headlineSmall),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                        pickup ? Icons.forklift : Icons.local_shipping,
                        color: AppColors.navy),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pickup ? 'Pickup Request' : 'Delivery Request',
                          style: textTheme.titleMedium),
                      Text(
                        'Client: ${clientNames[draft.clientId] ?? '—'}',
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
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
                  Text('Cargo & Items', style: textTheme.titleMedium),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.navy,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text('${selected.length} Boxes Total',
                        style: textTheme.bodySmall
                            ?.copyWith(color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (final box in selected)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              box.label.isEmpty ? box.qrCodeId : box.label,
                              style: textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            Text(box.qrCodeId, style: textTheme.bodySmall),
                          ],
                        ),
                      ),
                      StatusChip(status: box.status.name),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );

    final sidebar = Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.navy,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Assignment',
                  style:
                      textTheme.titleMedium?.copyWith(color: Colors.white)),
              const SizedBox(height: 16),
              Text('SCHEDULED ${pickup ? 'PICKUP' : 'DELIVERY'}',
                  style: textTheme.bodySmall
                      ?.copyWith(color: Colors.white54, letterSpacing: 1)),
              const SizedBox(height: 4),
              Text(
                draft.scheduledDate == null
                    ? '—'
                    : DateFormat('MMM d, y').format(draft.scheduledDate!),
                style:
                    textTheme.headlineSmall?.copyWith(color: Colors.white),
              ),
              Text(
                '${settings.windowRange(draft.timeWindow)} window',
                style: textTheme.bodySmall?.copyWith(color: Colors.white54),
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white24),
              const SizedBox(height: 12),
              Text('ASSIGNED DRIVER',
                  style: textTheme.bodySmall
                      ?.copyWith(color: Colors.white54, letterSpacing: 1)),
              const SizedBox(height: 8),
              Row(
                children: [
                  InitialsAvatar(
                    name: draft.driverId == null
                        ? null
                        : driverNames[draft.driverId],
                    size: 36,
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.onAccent,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      draft.driverId == null
                          ? 'Unassigned — dispatch later'
                          : driverNames[draft.driverId] ?? '—',
                      style: textTheme.bodyMedium
                          ?.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('MONTHLY STORAGE',
                  style: textTheme.bodySmall?.copyWith(letterSpacing: 1)),
              const SizedBox(height: 8),
              Text('${formatZar(storage.monthlyZar)}/mo',
                  style: textTheme.displaySmall),
              const SizedBox(height: 12),
              _feeRow('${selected.length} '
                  '${selected.length == 1 ? 'unit' : 'units'} at their rates',
                  storage.monthlyZar, textTheme),
              if (pickup && vehicleFees.isNotEmpty)
                _feeRow(
                    'Pickup (once-off, by vehicle)',
                    vehicleFees.first,
                    textTheme,
                    upTo: vehicleFees.last),
              if (storage.unpricedUnits > 0) ...[
                const SizedBox(height: 6),
                Text(
                    '${storage.unpricedUnits} unsized '
                    '${storage.unpricedUnits == 1 ? 'unit is' : 'units are'} '
                    'not included — set a size on the unit page.',
                    style: textTheme.bodySmall),
              ],
              const SizedBox(height: 6),
              Text('From the price list. Storage is invoiced on the 1st.',
                  style: textTheme.bodySmall),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: submitting ? null : onSubmit,
            icon: submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.accentDeep),
                  )
                : const Icon(Icons.send, size: 18),
            label: const Text('Submit Job'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: submitting ? null : onSaveDraft,
            child: const Text('Save as Draft'),
          ),
        ),
      ],
    );

    if (desktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 60, child: overview),
          const SizedBox(width: 24),
          Expanded(flex: 40, child: sidebar),
        ],
      );
    }
    return Column(children: [overview, const SizedBox(height: 24), sidebar]);
  }

  Widget _feeRow(String label, num amount, TextTheme textTheme, {num? upTo}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textSecondary)),
          Text(
              upTo == null || upTo == amount
                  ? formatZar(amount)
                  : '${formatZar(amount)}–${formatZar(upTo)}',
              style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}
