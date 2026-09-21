import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/enums/app_enums.dart';
import '../../../core/models/storage_unit.dart';
import '../../../core/models/value_objects.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadow.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/step_indicator.dart';
import '../providers/client_providers.dart';

/// 4-step delivery request: Items → Date → Address → Confirm.
/// Design: client_designs/request_delivery_step_1/screen.png.
class ClientDeliveryRequestScreen extends ConsumerStatefulWidget {
  const ClientDeliveryRequestScreen({super.key});

  @override
  ConsumerState<ClientDeliveryRequestScreen> createState() =>
      _ClientDeliveryRequestScreenState();
}

class _ClientDeliveryRequestScreenState
    extends ConsumerState<ClientDeliveryRequestScreen> {
  int _step = 0;
  bool _submitting = false;

  void _next() => setState(() => _step = (_step + 1).clamp(0, 3));
  void _back() => setState(() => _step = (_step - 1).clamp(0, 3));

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      await ref.read(deliveryRequestProvider.notifier).submit();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Delivery request submitted — we are on it!')),
        );
        context.go('/client/dashboard');
      }
    } catch (error) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not submit request: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return LayoutBuilder(builder: (context, constraints) {
      final desktop = constraints.maxWidth > 900;

      return SingleChildScrollView(
        padding: EdgeInsets.all(desktop ? AppSpacing.lg : AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('New Delivery Request', style: tt.displaySmall),
            const SizedBox(height: AppSpacing.md),
            StepIndicator(
              steps: const ['Items', 'Date', 'Address', 'Confirm'],
              currentStep: _step,
            ),
            const SizedBox(height: AppSpacing.lg),
            switch (_step) {
              0 => _ItemsStep(desktop: desktop, onNext: _next),
              1 => _DateStep(onBack: _back, onNext: _next),
              2 => _AddressStep(onBack: _back, onNext: _next),
              _ => _ConfirmStep(
                  submitting: _submitting,
                  onBack: _back,
                  onSubmit: _submit,
                ),
            },
          ],
        ),
      );
    });
  }
}

// ------------------------------------------------------------ step 1: items

class _ItemsStep extends ConsumerWidget {
  const _ItemsStep({required this.desktop, required this.onNext});

  final bool desktop;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(deliveryRequestProvider);
    final units = ref.watch(myUnitsProvider).valueOrNull ?? const [];
    final tt = Theme.of(context).textTheme;

    // Only units at the facility can be requested back (doc 15).
    final eligible = units
        .where((unit) => unit.status == StorageStatus.inStorage)
        .toList();
    final selected = eligible
        .where((unit) => draft.selectedUnitIds.contains(unit.id))
        .toList();

    final grid = eligible.isEmpty
        ? const EmptyState(
            icon: Icons.inventory_2_outlined,
            title: 'Nothing available to deliver',
            subtitle:
                'Only items currently in storage can be requested back.',
          )
        : LayoutBuilder(builder: (context, constraints) {
            final columns = constraints.maxWidth > 640 ? 2 : 1;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: AppSpacing.sm + 4,
                crossAxisSpacing: AppSpacing.sm + 4,
                mainAxisExtent: 104,
              ),
              itemCount: eligible.length,
              itemBuilder: (context, index) {
                final unit = eligible[index];
                final isSelected =
                    draft.selectedUnitIds.contains(unit.id);
                return InkWell(
                  onTap: () => ref
                      .read(deliveryRequestProvider.notifier)
                      .toggleUnit(unit.id),
                  borderRadius: AppRadius.md,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm + 4),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.md,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.accentDeep
                            : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.accent
                                : AppColors.surface,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(6)),
                            border: Border.all(
                                color: isSelected
                                    ? AppColors.accent
                                    : AppColors.border),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check,
                                  size: 16, color: AppColors.onAccent)
                              : null,
                        ),
                        const SizedBox(width: AppSpacing.sm + 4),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                unit.label.isEmpty
                                    ? unit.qrCodeId
                                    : unit.label,
                                style: tt.titleMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text('UNIT ${unit.qrCodeId}',
                                  style: tt.bodySmall),
                            ],
                          ),
                        ),
                        const Icon(Icons.check_circle_outline,
                            size: 16, color: AppColors.statusSuccess),
                        const SizedBox(width: AppSpacing.xs),
                        Text('In Storage',
                            style: tt.bodySmall?.copyWith(
                                color: AppColors.statusSuccess)),
                      ],
                    ),
                  ),
                );
              },
            );
          });

    final summary = Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.md,
        boxShadow: AppShadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Job Summary', style: tt.titleMedium),
          const SizedBox(height: AppSpacing.sm + 4),
          if (selected.isEmpty)
            Text('No items selected yet.',
                style:
                    tt.bodyMedium?.copyWith(color: AppColors.textSecondary))
          else
            for (final unit in selected)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
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
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.delete_outline,
                          size: 18, color: AppColors.statusError),
                      onPressed: () => ref
                          .read(deliveryRequestProvider.notifier)
                          .toggleUnit(unit.id),
                    ),
                  ],
                ),
              ),
          const Divider(height: AppSpacing.lg),
          Row(
            children: [
              const Icon(Icons.schedule,
                  size: 16, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.xs),
              Text('ESTIMATED: 1–2 BUSINESS DAYS',
                  style: tt.bodySmall?.copyWith(letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: selected.isEmpty ? null : onNext,
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: const Text('Continue to Date'),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Center(
            child: TextButton(
              onPressed: selected.isEmpty
                  ? null
                  : () => ref
                      .read(deliveryRequestProvider.notifier)
                      .clearSelection(),
              child: const Text('Clear Selection'),
            ),
          ),
        ],
      ),
    );

    final counter = Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm + 4, vertical: 4),
          decoration: const BoxDecoration(
            color: AppColors.accent,
            borderRadius: AppRadius.pill,
          ),
          child: Text(
            '${selected.length} item${selected.length == 1 ? '' : 's'} selected',
            style: tt.bodySmall?.copyWith(
                fontWeight: FontWeight.w700, color: AppColors.onAccent),
          ),
        ),
        const SizedBox(width: AppSpacing.sm + 4),
        Expanded(
          child: Text(
            'Select the units you wish to have delivered to your location.',
            style: tt.bodySmall
                ?.copyWith(fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );

    if (desktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                grid,
                const SizedBox(height: AppSpacing.md),
                counter,
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          SizedBox(width: 320, child: summary),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        grid,
        const SizedBox(height: AppSpacing.md),
        counter,
        const SizedBox(height: AppSpacing.lg),
        summary,
      ],
    );
  }
}

// ------------------------------------------------------------- step 2: date

class _DateStep extends ConsumerWidget {
  const _DateStep({required this.onBack, required this.onNext});

  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(deliveryRequestProvider);
    final notifier = ref.read(deliveryRequestProvider.notifier);
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.md,
        boxShadow: AppShadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Choose date & time window', style: tt.headlineSmall),
          const SizedBox(height: AppSpacing.lg),
          Text('Delivery Date', style: tt.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              alignment: Alignment.centerLeft,
              side: const BorderSide(color: AppColors.border),
              foregroundColor: AppColors.textPrimary,
              textStyle: tt.bodyMedium,
            ),
            onPressed: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate:
                    draft.date ?? now.add(const Duration(days: 1)),
                firstDate: now.add(const Duration(days: 1)),
                lastDate: now.add(const Duration(days: 30)),
              );
              if (picked != null) notifier.setSchedule(date: picked);
            },
            icon: const Icon(Icons.calendar_today_outlined, size: 18),
            label: Text(
              draft.date == null
                  ? 'Pick a delivery date (tomorrow – 30 days out)'
                  : DateFormat('EEEE, d MMMM y').format(draft.date!),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Time Window', style: tt.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm + 4,
            runSpacing: AppSpacing.sm,
            children: [
              for (final window in TimeWindow.values)
                ChoiceChip(
                  label: Text(window.label),
                  selected: draft.timeWindow == window,
                  showCheckmark: false,
                  selectedColor: AppColors.skyTint,
                  labelStyle: tt.labelLarge?.copyWith(
                    color: draft.timeWindow == window
                        ? AppColors.accentDeep
                        : AppColors.textPrimary,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.pill,
                    side: BorderSide(color: AppColors.border),
                  ),
                  onSelected: (_) =>
                      notifier.setSchedule(timeWindow: window),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Special Instructions', style: tt.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            initialValue: draft.instructions,
            maxLines: 3,
            decoration: const InputDecoration(
                hintText:
                    'Gate codes, parking notes, fragile handling requests…'),
            onChanged: notifier.setInstructions,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              TextButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Back'),
              ),
              const Spacer(),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg),
                ),
                onPressed: draft.date == null ? null : onNext,
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text('Continue to Address'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------- step 3: address

class _AddressStep extends ConsumerStatefulWidget {
  const _AddressStep({required this.onBack, required this.onNext});

  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  ConsumerState<_AddressStep> createState() => _AddressStepState();
}

class _AddressStepState extends ConsumerState<_AddressStep> {
  late final _line1 = TextEditingController(
      text: ref.read(deliveryRequestProvider).address.line1);
  late final _line2 = TextEditingController(
      text: ref.read(deliveryRequestProvider).address.line2 ?? '');
  late final _city = TextEditingController(
      text: ref.read(deliveryRequestProvider).address.city);
  late final _postCode = TextEditingController(
      text: ref.read(deliveryRequestProvider).address.postCode);

  @override
  void dispose() {
    _line1.dispose();
    _line2.dispose();
    _city.dispose();
    _postCode.dispose();
    super.dispose();
  }

  void _continue() {
    final notifier = ref.read(deliveryRequestProvider.notifier);
    final draft = ref.read(deliveryRequestProvider);
    if (!draft.useSavedAddress) {
      notifier.setAddress(Address(
        line1: _line1.text.trim(),
        line2: _line2.text.trim().isEmpty ? null : _line2.text.trim(),
        city: _city.text.trim(),
        postCode: _postCode.text.trim(),
      ));
    }
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(deliveryRequestProvider);
    final client = ref.watch(currentClientProvider).valueOrNull;
    final tt = Theme.of(context).textTheme;
    final saved = client?.address ?? const Address();
    final savedLabel = [
      saved.line1,
      saved.city,
      saved.postCode,
    ].where((part) => part.isNotEmpty).join(', ');

    final customValid = _line1.text.trim().isNotEmpty &&
        _city.text.trim().isNotEmpty &&
        _postCode.text.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.md,
        boxShadow: AppShadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Confirm delivery address', style: tt.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          RadioGroup<bool>(
            groupValue: draft.useSavedAddress,
            onChanged: (value) => ref
                .read(deliveryRequestProvider.notifier)
                .setUseSavedAddress(value ?? true),
            child: Column(
              children: [
                RadioListTile<bool>(
                  value: true,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Use my saved address'),
                  subtitle: Text(
                      savedLabel.isEmpty ? 'No saved address yet' : savedLabel),
                ),
                RadioListTile<bool>(
                  value: false,
                  contentPadding: EdgeInsets.zero,
                  title:
                      const Text('Use a different address for this delivery'),
                ),
              ],
            ),
          ),
          if (!draft.useSavedAddress) ...[
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _line1,
              decoration:
                  const InputDecoration(hintText: 'Address line 1'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.sm + 4),
            TextField(
              controller: _line2,
              decoration: const InputDecoration(
                  hintText: 'Address line 2 (optional)'),
            ),
            const SizedBox(height: AppSpacing.sm + 4),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _city,
                    decoration: const InputDecoration(hintText: 'City'),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm + 4),
                SizedBox(
                  width: 140,
                  child: TextField(
                    controller: _postCode,
                    decoration:
                        const InputDecoration(hintText: 'Postcode'),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              TextButton.icon(
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Back'),
              ),
              const Spacer(),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg),
                ),
                onPressed: (draft.useSavedAddress && savedLabel.isNotEmpty) ||
                        (!draft.useSavedAddress && customValid)
                    ? _continue
                    : null,
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text('Review Request'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------------- step 4: confirm

class _ConfirmStep extends ConsumerWidget {
  const _ConfirmStep({
    required this.submitting,
    required this.onBack,
    required this.onSubmit,
  });

  final bool submitting;
  final VoidCallback onBack;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(deliveryRequestProvider);
    final units = ref.watch(myUnitsProvider).valueOrNull ??
        const <StorageUnit>[];
    final client = ref.watch(currentClientProvider).valueOrNull;
    final tt = Theme.of(context).textTheme;

    final selected = units
        .where((unit) => draft.selectedUnitIds.contains(unit.id))
        .toList();
    final address =
        draft.useSavedAddress ? (client?.address ?? const Address()) : draft.address;
    final addressLabel = [
      address.line1,
      if (address.line2 != null) address.line2!,
      address.city,
      address.postCode,
    ].where((part) => part.isNotEmpty).join(', ');

    Widget row(String label, String value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 130,
                child: Text(label.toUpperCase(),
                    style: tt.bodySmall?.copyWith(letterSpacing: 0.5)),
              ),
              Expanded(child: Text(value, style: tt.bodyMedium)),
            ],
          ),
        );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.md,
        boxShadow: AppShadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Review & submit', style: tt.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          row(
            'Items',
            selected
                .map((unit) =>
                    unit.label.isEmpty ? unit.qrCodeId : unit.label)
                .join(', '),
          ),
          row(
            'Date',
            draft.date == null
                ? '—'
                : DateFormat('EEEE, d MMMM y').format(draft.date!),
          ),
          row('Time window', draft.timeWindow.label),
          row('Address', addressLabel.isEmpty ? '—' : addressLabel),
          if (draft.instructions.isNotEmpty)
            row('Instructions', draft.instructions),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm + 4),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: AppRadius.sm,
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user_outlined,
                    size: 18, color: AppColors.accentDeep),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'StrongBox Guard Protection is active for all items '
                    'in transit.',
                    style: tt.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              TextButton.icon(
                onPressed: submitting ? null : onBack,
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Back'),
              ),
              const Spacer(),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 52),
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl),
                ),
                onPressed: submitting ? null : onSubmit,
                icon: submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.accentDeep),
                      )
                    : const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Confirm Request'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
