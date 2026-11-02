import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/enums/app_enums.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/models/value_objects.dart';
import '../../../core/providers/business_settings_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/currency.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/primary_button.dart';
import '../../client/providers/client_providers.dart';
import '../providers/quote_providers.dart';
import '../widgets/quote_widgets.dart';

final _day = DateFormat('EEEE d MMMM');

/// Book the pickup for the current quote (route `/client/order/book`,
/// inside the ClientShell).
///
/// The quote's items become storage units "awaiting pickup" in My Storage,
/// priced by the server from the live price list, each with its own QR
/// label to print. With "supplies first" (journey Path A) a driver drops
/// off empty boxes and the supplies on an earlier day; otherwise they come
/// with the driver on pickup day. The booking awaits an admin's
/// confirmation.
class BookPickupScreen extends ConsumerStatefulWidget {
  const BookPickupScreen({super.key});

  @override
  ConsumerState<BookPickupScreen> createState() => _BookPickupScreenState();
}

class _BookPickupScreenState extends ConsumerState<BookPickupScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _date = _tomorrow().add(const Duration(days: 1));
  TimeWindow _window = TimeWindow.morning;
  bool _suppliesFirst = false;
  late DateTime _supplyDate = _tomorrow();
  TimeWindow _supplyWindow = TimeWindow.morning;
  final _access = TextEditingController();
  bool _useSaved = true;
  final _line1 = TextEditingController();
  final _line2 = TextEditingController();
  final _city = TextEditingController();
  final _postCode = TextEditingController();
  final _notes = TextEditingController();
  bool _saving = false;

  static DateTime _tomorrow() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + 1);
  }

  @override
  void initState() {
    super.initState();
    // Arrived — the post-sign-in hop to booking is used up.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(quoteControllerProvider.notifier).bookingOpened(),
    );
  }

  @override
  void dispose() {
    for (final c in [_line1, _line2, _city, _postCode, _notes, _access]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final first = _tomorrow();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: first,
      lastDate: first.add(const Duration(days: 150)),
      helpText: 'Pickup date',
    );
    if (picked == null) return;
    setState(() {
      _date = picked;
      // Supplies must land at least a day before the pickup.
      if (!_supplyDate.isBefore(_date)) {
        _supplyDate = _date.subtract(const Duration(days: 1));
      }
    });
  }

  Future<void> _pickSupplyDate() async {
    final first = _tomorrow();
    final last = _date.subtract(const Duration(days: 1));
    if (last.isBefore(first)) return;
    final picked = await showDatePicker(
      context: context,
      initialDate: _supplyDate.isBefore(first) ? first : _supplyDate,
      firstDate: first,
      lastDate: last,
      helpText: 'Supply drop-off date',
    );
    if (picked != null) setState(() => _supplyDate = picked);
  }

  /// Supplies first needs a free day between tomorrow and the pickup.
  bool get _canSupplyFirst =>
      !_date.subtract(const Duration(days: 1)).isBefore(_tomorrow());

  Future<void> _book(Address? saved) async {
    final address = _useSaved && saved != null
        ? saved
        : Address(
            line1: _line1.text.trim(),
            line2: _line2.text.trim().isEmpty ? null : _line2.text.trim(),
            city: _city.text.trim(),
            postCode: _postCode.text.trim(),
          );
    if (!(_useSaved && saved != null) &&
        !(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() => _saving = true);
    final router = GoRouter.of(context);
    try {
      final booked = await ref
          .read(pickupBookingProvider.notifier)
          .book(
            date: _date,
            timeWindow: _window,
            address: address,
            notes: _notes.text,
            accessNotes: _access.text,
            suppliesFirst: _suppliesFirst && _canSupplyFirst
                ? (date: _supplyDate, timeWindow: _supplyWindow)
                : null,
          );
      if (!mounted) return;
      final settings = ref.read(businessSettingsProvider);
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: AppColors.surface,
          icon: const Icon(
            Icons.check_circle,
            color: AppColors.statusSuccess,
            size: 40,
          ),
          title: const Text('Booking received'),
          content: Text(
            'You asked us to collect ${booked.unitCount} '
            '${booked.unitCount == 1 ? 'item' : 'items'} on '
            '${_day.format(_date)}, ${settings.windowLabel(_window)}. '
            'We\'ll confirm the booking shortly and let you know.\n\n'
            '${booked.supplyJobId != null ? 'Your empty boxes and supplies '
                'arrive on ${_day.format(_supplyDate)}, '
                '${settings.windowLabel(_supplyWindow)}.\n\n' : ''}'
            'Your order lists each item with its own QR label — print '
            'them from the order and stick one on each box or item as you '
            'pack, then photograph what\'s inside. Storage of '
            '${formatZar(booked.monthlyZar)}/month starts once we\'ve '
            'collected them; ${formatZar(booked.onceOffZar)} once-off is '
            'on your first invoice.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('View my order'),
            ),
          ],
        ),
      );
      router.go('/client/orders/${booked.jobId}');
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error is AppException
                ? error.message
                : 'Could not book the pickup: $error',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totals = ref.watch(quoteTotalsProvider);
    final client = ref.watch(currentClientProvider).valueOrNull;
    final settings = ref.watch(businessSettingsProvider);
    final saved = client?.address;
    final hasSaved = saved != null && saved.line1.trim().isNotEmpty;
    final tt = Theme.of(context).textTheme;

    if (totals.isEmpty && !_saving) {
      return EmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'Your quote is empty',
        subtitle:
            'Add the boxes and items you want us to collect, then '
            'book the pickup.',
        action: ElevatedButton(
          onPressed: () => context.go('/client/order'),
          child: const Text('Build a quote'),
        ),
      );
    }

    String? required(String? v) => (v ?? '').trim().isEmpty ? 'Required' : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth > 900;

        final form = Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              QuoteSection(
                title: 'What we\'re collecting',
                trailing: TextButton(
                  onPressed: () => context.go('/client/order'),
                  child: const Text('Edit quote'),
                ),
                child: Column(
                  children: [
                    for (final line in totals.lines)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${line.quantity} × ${line.name}',
                                style: tt.bodyMedium,
                              ),
                            ),
                            Text(
                              '${formatZar(line.quantity * line.unitZar)}/mo',
                              style: tt.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    for (final line in totals.supplyLines)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text('${line.quantity} × ${line.name}',
                                  style: tt.bodyMedium),
                            ),
                            Text(
                                '${formatZar(line.quantity * line.unitZar)} '
                                'once-off',
                                style: tt.bodyMedium),
                          ],
                        ),
                      ),
                    if (totals.helperHours > 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                  'Packing helper · ${totals.helperHours} hours',
                                  style: tt.bodyMedium),
                            ),
                            Text('${formatZar(totals.helperZar)} once-off',
                                style: tt.bodyMedium),
                          ],
                        ),
                      ),
                    if (totals.helperTooShort)
                      Text(
                          'Packing help is a minimum of '
                          '${totals.helperMinHours} hours.',
                          style: tt.bodySmall
                              ?.copyWith(color: AppColors.statusError)),
                    if (totals.vehicle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.sm),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Pickup — ${totals.vehicle!.label}',
                                style: tt.bodyMedium,
                              ),
                            ),
                            Text(
                              '${formatZar(totals.pickupZar)} once-off',
                              style: tt.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              QuoteSection(
                title: 'When',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                      ),
                      onPressed: _pickDate,
                      icon: const Icon(Icons.event_outlined),
                      label: Text(_day.format(_date)),
                    ),
                    const SizedBox(height: AppSpacing.sm + 4),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        for (final window in TimeWindow.values)
                          ChoiceChip(
                            label: Text(settings.windowLabel(window)),
                            selected: _window == window,
                            onSelected: (_) => setState(() => _window = window),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              QuoteSection(
                title: 'Packing supplies',
                subtitle: 'Need empty boxes and wrapping before pickup day? '
                    'We\'ll drop them off first — free with your booking.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Own Material: the card behind would hide its ink.
                    Material(
                      type: MaterialType.transparency,
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _suppliesFirst && _canSupplyFirst,
                        onChanged: _canSupplyFirst
                            ? (v) => setState(() => _suppliesFirst = v)
                            : null,
                        title: const Text('Deliver supplies before the pickup'),
                        subtitle: Text(_canSupplyFirst
                            ? 'Otherwise your driver brings them on the day.'
                            : 'Pick a later pickup date to have supplies '
                                'delivered first.'),
                      ),
                    ),
                    if (_suppliesFirst && _canSupplyFirst) ...[
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                        ),
                        onPressed: _pickSupplyDate,
                        icon: const Icon(Icons.event_outlined),
                        label: Text('Drop-off ${_day.format(_supplyDate)}'),
                      ),
                      const SizedBox(height: AppSpacing.sm + 4),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          for (final window in TimeWindow.values)
                            ChoiceChip(
                              label: Text(settings.windowLabel(window)),
                              selected: _supplyWindow == window,
                              onSelected: (_) =>
                                  setState(() => _supplyWindow = window),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              QuoteSection(
                title: 'Where',
                subtitle: settings.serviceArea.isEmpty
                    ? null
                    : 'We collect in ${settings.serviceArea}.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasSaved) ...[
                      RadioGroup<bool>(
                        groupValue: _useSaved,
                        onChanged: (v) => setState(() => _useSaved = v ?? true),
                        child: Column(
                          children: [
                            RadioListTile<bool>(
                              contentPadding: EdgeInsets.zero,
                              value: true,
                              title: Text(
                                [
                                  saved.line1,
                                  saved.city,
                                ].where((s) => s.isNotEmpty).join(', '),
                              ),
                              subtitle: const Text('Saved address'),
                            ),
                            const RadioListTile<bool>(
                              contentPadding: EdgeInsets.zero,
                              value: false,
                              title: Text('A different address'),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (!hasSaved || !_useSaved) ...[
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: _line1,
                        validator: required,
                        decoration: const InputDecoration(
                          labelText: 'Street address',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm + 4),
                      TextFormField(
                        controller: _line2,
                        decoration: const InputDecoration(
                          labelText: 'Unit / complex (optional)',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm + 4),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _city,
                              validator: required,
                              decoration: const InputDecoration(
                                labelText: 'Suburb / city',
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: TextFormField(
                              controller: _postCode,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Postal code',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              QuoteSection(
                title: 'Anything we should know?',
                child: Column(
                  children: [
                    TextField(
                      controller: _access,
                      maxLength: 300,
                      decoration: const InputDecoration(
                        labelText: 'Access',
                        hintText: 'Gate code, parking, stairs, lift…',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _notes,
                      maxLines: 3,
                      maxLength: 500,
                      decoration: const InputDecoration(
                        labelText: 'Notes for the team',
                        hintText: 'Fragile items, things that need two '
                            'people…',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

        final confirm = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const QuoteSummaryCard(showBookButton: false),
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              label: 'Confirm booking',
              loading: _saving,
              onPressed: totals.helperTooShort
                  ? null
                  : () => _book(hasSaved ? saved : null),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Nothing is charged now. We confirm your booking first; '
              'you\'re invoiced monthly once your items are collected.',
              textAlign: TextAlign.center,
              style: tt.bodySmall,
            ),
          ],
        );

        return SingleChildScrollView(
          padding: EdgeInsets.all(desktop ? AppSpacing.lg : AppSpacing.md),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Book your pickup', style: tt.displaySmall),
                  const SizedBox(height: AppSpacing.lg),
                  if (desktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 62, child: form),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(flex: 38, child: confirm),
                      ],
                    )
                  else ...[
                    form,
                    const SizedBox(height: AppSpacing.md),
                    confirm,
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
