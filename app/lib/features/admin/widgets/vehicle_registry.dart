import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/enums/app_enums.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/models/app_user.dart';
import '../../../core/models/vehicle.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_data_table.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/dialog_actions.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_retry.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/widgets/summary_card.dart';
import '../providers/clients_providers.dart';
import '../providers/vehicle_providers.dart';

final _date = DateFormat('d MMM y');

IconData vehicleIcon(VehicleType type) => switch (type) {
      VehicleType.car => Icons.directions_car_outlined,
      VehicleType.bakkie => Icons.local_shipping_outlined,
      VehicleType.van => Icons.airport_shuttle_outlined,
      VehicleType.truck => Icons.fire_truck_outlined,
      VehicleType.trailer => Icons.rv_hookup_outlined,
    };

/// Which assets the registry lists.
enum _Kind { all, vehicles, trailers }

/// Fleet → Vehicles & trailers: summary, filter, search and the registry
/// table. Tapping a row edits it; [VehicleFormDialog] adds new ones.
class VehicleRegistry extends ConsumerStatefulWidget {
  const VehicleRegistry({super.key, required this.desktop});

  final bool desktop;

  @override
  ConsumerState<VehicleRegistry> createState() => _VehicleRegistryState();
}

class _VehicleRegistryState extends ConsumerState<VehicleRegistry> {
  _Kind _kind = _Kind.all;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final vehicles = ref.watch(fleetVehiclesProvider);
    final drivers = {
      for (final driver
          in ref.watch(driverUsersProvider).valueOrNull ?? const <AppUser>[])
        driver.id: driver,
    };

    return vehicles.when(
      loading: () => const AppDataTable(
          columns: _columns, rows: [], isLoading: true),
      error: (error, _) => ErrorRetry(
          error: error, onRetry: () => ref.invalidate(fleetVehiclesProvider)),
      data: (all) {
        final now = DateTime.now();
        final visible = all.where((vehicle) {
          final kindOk = switch (_kind) {
            _Kind.all => true,
            _Kind.vehicles => !vehicle.isTrailer,
            _Kind.trailers => vehicle.isTrailer,
          };
          if (!kindOk) return false;
          if (_query.isEmpty) return true;
          final driver = drivers[vehicle.assignedDriverId]?.name ?? '';
          return [
            vehicle.displayName,
            vehicle.registration,
            vehicle.make ?? '',
            vehicle.model ?? '',
            driver,
          ].any((field) => field.toLowerCase().contains(_query));
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Summary(vehicles: all, now: now, desktop: widget.desktop),
            const SizedBox(height: AppSpacing.lg - 4),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SegmentedButton<_Kind>(
                  segments: const [
                    ButtonSegment(value: _Kind.all, label: Text('All')),
                    ButtonSegment(
                        value: _Kind.vehicles, label: Text('Vehicles')),
                    ButtonSegment(
                        value: _Kind.trailers, label: Text('Trailers')),
                  ],
                  selected: {_kind},
                  showSelectedIcon: false,
                  onSelectionChanged: (selection) =>
                      setState(() => _kind = selection.first),
                ),
                SizedBox(
                  width: widget.desktop ? 360 : double.infinity,
                  child: AppSearchBar(
                    hint: 'Search registration, name or driver...',
                    onChanged: (value) =>
                        setState(() => _query = value.trim().toLowerCase()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (visible.isEmpty)
              EmptyState(
                icon: Icons.local_shipping_outlined,
                title: all.isEmpty
                    ? 'No vehicles or trailers yet'
                    : 'Nothing matches',
                subtitle: all.isEmpty
                    ? 'Add the cars, bakkies, vans, trucks and trailers you '
                        'dispatch.'
                    : 'Try another filter or search.',
              )
            else
              AppDataTable(
                columns: _columns,
                minWidth: 960,
                rows: [
                  for (final vehicle in visible)
                    _row(context, vehicle, drivers, now),
                ],
              ),
          ],
        );
      },
    );
  }

  static const _columns = [
    TableColumnSpec('Vehicle', flex: 4),
    TableColumnSpec('Registration', flex: 2),
    TableColumnSpec('Capacity', flex: 2),
    TableColumnSpec('Driver', flex: 3),
    TableColumnSpec('Licence disc', flex: 2),
    TableColumnSpec('Status', flex: 2),
    TableColumnSpec('', flex: 1),
  ];

  List<Widget> _row(BuildContext context, Vehicle vehicle,
      Map<String, AppUser> drivers, DateTime now) {
    final tt = Theme.of(context).textTheme;
    final details = [
      vehicle.type.label,
      [vehicle.make, vehicle.model]
          .whereType<String>()
          .where((s) => s.isNotEmpty)
          .join(' '),
      if (vehicle.year != null) '${vehicle.year}',
    ].where((s) => s.isNotEmpty).join(' · ');
    final capacity = [
      if (vehicle.capacityM3 != null)
        '${NumberFormat('0.#').format(vehicle.capacityM3)} m³',
      if (vehicle.payloadKg != null)
        '${NumberFormat.decimalPattern().format(vehicle.payloadKg)} kg',
    ].join(' · ');
    final expiry = vehicle.licenceExpiresAt;
    final licenceColour = vehicle.licenceExpired(now)
        ? AppColors.statusError
        : vehicle.licenceDueSoon(now)
            ? AppColors.statusWarning
            : null;

    return [
      Row(
        children: [
          Icon(vehicleIcon(vehicle.type), color: AppColors.accentDeep),
          const SizedBox(width: AppSpacing.sm + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vehicle.displayName,
                    style:
                        tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(details,
                    style: tt.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
      Text(vehicle.registration, style: tt.bodyMedium),
      Text(capacity.isEmpty ? '—' : capacity, style: tt.bodyMedium),
      Text(
        vehicle.isTrailer
            ? 'Towed'
            : drivers[vehicle.assignedDriverId]?.name ?? 'Unassigned',
        style: tt.bodyMedium?.copyWith(
            color: vehicle.assignedDriverId == null
                ? AppColors.textSecondary
                : null),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      Text(
        expiry == null
            ? '—'
            : vehicle.licenceExpired(now)
                ? 'Expired ${_date.format(expiry)}'
                : _date.format(expiry),
        style: tt.bodyMedium?.copyWith(
            color: licenceColour,
            fontWeight: licenceColour == null ? null : FontWeight.w600),
      ),
      Align(
        alignment: Alignment.centerLeft,
        child: StatusChip(
            status: vehicle.status.name, label: vehicle.status.label),
      ),
      Align(
        alignment: Alignment.centerRight,
        child: IconButton(
          tooltip: 'Edit ${vehicle.displayName}',
          icon: const Icon(Icons.edit_outlined, size: 20),
          onPressed: () => VehicleFormDialog.show(context, vehicle: vehicle),
        ),
      ),
    ];
  }
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.vehicles,
    required this.now,
    required this.desktop,
  });

  final List<Vehicle> vehicles;
  final DateTime now;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    final trailers = vehicles.where((v) => v.isTrailer).length;
    final available =
        vehicles.where((v) => v.status == VehicleStatus.available).length;
    final licenceAlerts = vehicles
        .where((v) => v.licenceExpired(now) || v.licenceDueSoon(now))
        .length;

    final cards = [
      SummaryCard(
          icon: Icons.local_shipping_outlined,
          value: '${vehicles.length - trailers}',
          label: 'Vehicles'),
      SummaryCard(
          icon: Icons.rv_hookup_outlined,
          value: '$trailers',
          label: 'Trailers'),
      SummaryCard(
          icon: Icons.check_circle_outline,
          value: '$available',
          label: 'Available'),
      SummaryCard(
        icon: Icons.event_busy_outlined,
        value: '$licenceAlerts',
        label: 'Licence discs due (30 days)',
        trend: licenceAlerts == 0 ? null : 'Renew',
        trendPositive: false,
      ),
    ];

    if (desktop) {
      return Row(
        children: [
          for (final (index, card) in cards.indexed) ...[
            if (index > 0) const SizedBox(width: AppSpacing.lg - 4),
            Expanded(child: card),
          ],
        ],
      );
    }
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.4,
      children: cards,
    );
  }
}

// ------------------------------------------------------------------- form

/// Add or edit a vehicle / trailer. Editing also offers "Retire".
class VehicleFormDialog extends ConsumerStatefulWidget {
  const VehicleFormDialog({super.key, this.vehicle});

  /// Null to add a new one.
  final Vehicle? vehicle;

  static Future<void> show(BuildContext context, {Vehicle? vehicle}) =>
      showDialog<void>(
        context: context,
        builder: (_) => VehicleFormDialog(vehicle: vehicle),
      );

  @override
  ConsumerState<VehicleFormDialog> createState() => _VehicleFormDialogState();
}

class _VehicleFormDialogState extends ConsumerState<VehicleFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final Vehicle _original = widget.vehicle ??
      const Vehicle(id: '', tenantId: '');
  late VehicleType _type = _original.type;
  late VehicleStatus _status = _original.status;
  late String? _driverId = _original.assignedDriverId;
  late DateTime? _licence = _original.licenceExpiresAt;
  late final _name = TextEditingController(text: _original.name);
  late final _registration =
      TextEditingController(text: _original.registration);
  late final _make = TextEditingController(text: _original.make);
  late final _model = TextEditingController(text: _original.model);
  late final _year =
      TextEditingController(text: _original.year?.toString() ?? '');
  late final _capacity = TextEditingController(
      text: _original.capacityM3 == null
          ? ''
          : NumberFormat('0.##').format(_original.capacityM3));
  late final _payload =
      TextEditingController(text: _original.payloadKg?.toString() ?? '');
  late final _notes = TextEditingController(text: _original.notes);
  bool _saving = false;

  bool get _editing => widget.vehicle != null;

  @override
  void dispose() {
    for (final c in [
      _name, _registration, _make, _model, _year, _capacity, _payload,
      _notes, //
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _text(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final vehicle = _original.copyWith(
      type: _type,
      name: _name.text.trim(),
      registration: normaliseRegistration(_registration.text),
      make: _text(_make),
      model: _text(_model),
      year: int.tryParse(_year.text.trim()),
      capacityM3: double.tryParse(_capacity.text.trim().replaceAll(',', '.')),
      payloadKg: int.tryParse(_payload.text.trim().replaceAll(' ', '')),
      status: _status,
      assignedDriverId: _type == VehicleType.trailer ? null : _driverId,
      licenceExpiresAt: _licence,
      notes: _text(_notes),
    );
    await _run(() => ref.read(vehicleMutationsProvider.notifier).save(vehicle),
        done: _editing
            ? '${vehicle.displayName} saved'
            : '${vehicle.displayName} added to the fleet');
  }

  Future<void> _retire() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Retire ${_original.displayName}?',
      message: 'It leaves the fleet list. Its history stays in the audit '
          'trail.',
      confirmLabel: 'Retire',
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;
    setState(() => _saving = true);
    await _run(
        () => ref.read(vehicleMutationsProvider.notifier).retire(_original),
        done: '${_original.displayName} retired');
  }

  Future<void> _run(Future<void> Function() action,
      {required String done}) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
      if (!mounted) return;
      Navigator.of(context).pop();
      messenger.showSnackBar(SnackBar(content: Text(done)));
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(
          content: Text(error is AppException
              ? error.message
              : 'Could not save: $error')));
    }
  }

  Future<void> _pickLicence() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _licence ?? DateTime(now.year + 1, now.month, now.day),
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 3),
      helpText: 'Licence disc expires',
    );
    if (picked != null) setState(() => _licence = picked);
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final drivers = ref.watch(driverUsersProvider).valueOrNull ?? const [];
    final trailer = _type == VehicleType.trailer;

    Widget pair(Widget a, Widget b) => LayoutBuilder(
          builder: (context, constraints) => constraints.maxWidth < 420
              ? Column(children: [a, b])
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: a),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: b),
                  ],
                ),
        );

    Widget field(
      TextEditingController controller,
      String label, {
      String? hint,
      TextInputType? keyboardType,
      String? Function(String?)? validator,
      List<TextInputFormatter>? formatters,
      TextCapitalization caps = TextCapitalization.words,
      int maxLines = 1,
    }) =>
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            inputFormatters: formatters,
            textCapitalization: caps,
            maxLines: maxLines,
            decoration: InputDecoration(labelText: label, hintText: hint),
          ),
        );

    final digits = [FilteringTextInputFormatter.digitsOnly];
    final decimal = [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))];

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_editing ? 'Edit ${_original.displayName}' : 'Add to fleet',
                    style: tt.headlineSmall),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final type in VehicleType.values)
                      ChoiceChip(
                        avatar: Icon(vehicleIcon(type), size: 18),
                        label: Text(type.label),
                        selected: _type == type,
                        onSelected: (_) => setState(() => _type = type),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                pair(
                  field(_name, 'Name (optional)',
                      hint: trailer ? 'e.g. Trailer 1' : 'e.g. Bakkie 2'),
                  field(_registration, 'Registration',
                      hint: 'e.g. CA 123-456',
                      caps: TextCapitalization.characters,
                      validator: (value) => (value ?? '').trim().isEmpty
                          ? 'Registration is required'
                          : null),
                ),
                pair(
                  field(_make, 'Make', hint: 'e.g. Toyota'),
                  field(_model, 'Model', hint: 'e.g. Hilux 2.4'),
                ),
                pair(
                  field(_year, 'Year',
                      keyboardType: TextInputType.number,
                      formatters: digits,
                      validator: (value) {
                        final text = (value ?? '').trim();
                        if (text.isEmpty) return null;
                        final year = int.tryParse(text);
                        final next = DateTime.now().year + 1;
                        return year == null || year < 1950 || year > next
                            ? 'Enter a year between 1950 and $next'
                            : null;
                      }),
                  field(_capacity, 'Load space (m³)',
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      formatters: decimal),
                ),
                pair(
                  field(_payload, 'Payload (kg)',
                      keyboardType: TextInputType.number, formatters: digits),
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: InkWell(
                      onTap: _pickLicence,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Licence disc expires',
                          suffixIcon: _licence == null
                              ? const Icon(Icons.event_outlined)
                              : IconButton(
                                  tooltip: 'Clear',
                                  icon: const Icon(Icons.clear),
                                  onPressed: () =>
                                      setState(() => _licence = null),
                                ),
                        ),
                        child: Text(_licence == null
                            ? 'Not set'
                            : _date.format(_licence!)),
                      ),
                    ),
                  ),
                ),
                pair(
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: DropdownButtonFormField<VehicleStatus>(
                      isExpanded: true,
                      initialValue: _status,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: [
                        for (final status in VehicleStatus.values)
                          DropdownMenuItem(
                              value: status, child: Text(status.label)),
                      ],
                      onChanged: (value) =>
                          setState(() => _status = value ?? _status),
                    ),
                  ),
                  trailer
                      ? const SizedBox.shrink()
                      : Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppSpacing.md),
                          child: DropdownButtonFormField<String?>(
                            isExpanded: true,
                            initialValue: drivers.any((d) => d.id == _driverId)
                                ? _driverId
                                : null,
                            decoration: const InputDecoration(
                                labelText: 'Usual driver'),
                            items: [
                              const DropdownMenuItem<String?>(
                                  value: null, child: Text('Unassigned')),
                              for (final driver in drivers)
                                DropdownMenuItem<String?>(
                                    value: driver.id,
                                    child: Text(driver.name.isEmpty
                                        ? driver.email
                                        : driver.name)),
                            ],
                            onChanged: (value) =>
                                setState(() => _driverId = value),
                          ),
                        ),
                ),
                field(_notes, 'Notes (optional)',
                    caps: TextCapitalization.sentences, maxLines: 3),
                Row(
                  children: [
                    if (_editing)
                      TextButton.icon(
                        style: TextButton.styleFrom(
                            foregroundColor: AppColors.statusError),
                        onPressed: _saving ? null : _retire,
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Retire'),
                      ),
                    const Spacer(),
                    DialogActions(
                      saving: _saving,
                      onSave: _save,
                      saveLabel: _editing ? 'Save' : 'Add to fleet',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
