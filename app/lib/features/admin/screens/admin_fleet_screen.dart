import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/models/app_user.dart';
import '../../../core/models/job.dart';
import '../providers/clients_providers.dart';
import '../providers/fleet_providers.dart';

const _pageSize = 10;

/// Fleet / drivers registry. Design: admin_drivers_fleet/screen.png.
class AdminFleetScreen extends ConsumerStatefulWidget {
  const AdminFleetScreen({super.key});

  @override
  ConsumerState<AdminFleetScreen> createState() => _AdminFleetScreenState();
}

class _AdminFleetScreenState extends ConsumerState<AdminFleetScreen> {
  int _page = 0;
  String _query = '';

  Future<void> _addDriver() async {
    final id = await _AddDriverDialog.show(context);
    if (id != null && mounted) context.go('/admin/fleet/$id');
  }

  @override
  Widget build(BuildContext context) {
    final drivers = ref.watch(driverUsersProvider);
    final activeJobs =
        ref.watch(activeJobsByDriverProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.onAccent,
        onPressed: _addDriver,
        child: const Icon(Icons.person_add),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        final desktop = constraints.maxWidth > 900;

        return SingleChildScrollView(
          padding: EdgeInsets.all(desktop ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Fleet', style: textTheme.displaySmall),
              const SizedBox(height: 4),
              Text('Driver readiness and dispatch across the fleet.',
                  style: textTheme.bodyMedium
                      ?.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              drivers.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(48),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => Text(
                    'Could not load drivers: $error',
                    style: textTheme.bodyMedium
                        ?.copyWith(color: AppColors.statusError)),
                data: (list) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SummaryRow(
                        drivers: list,
                        activeJobs: activeJobs,
                        desktop: desktop),
                    const SizedBox(height: 20),
                    AppSearchBar(
                      hint: 'Search driver names or phone...',
                      onChanged: (value) => setState(() {
                        _query = value.toLowerCase();
                        _page = 0;
                      }),
                    ),
                    const SizedBox(height: 16),
                    _buildTable(list, activeJobs, textTheme),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTable(List<AppUser> all, Map<String, Job> activeJobs,
      TextTheme textTheme) {
    final list = _query.isEmpty
        ? all
        : all
            .where((driver) =>
                driver.name.toLowerCase().contains(_query) ||
                (driver.phone ?? '').toLowerCase().contains(_query))
            .toList();

    if (list.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [AppTheme.cardShadow],
        ),
        child: Column(
          children: [
            const Icon(Icons.badge_outlined,
                size: 48, color: AppColors.border),
            const SizedBox(height: 12),
            Text(
              all.isEmpty
                  ? 'No drivers registered yet — add your first driver.'
                  : 'No drivers match your search.',
              style: textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    final pageCount = (list.length / _pageSize).ceil();
    final page = _page.clamp(0, pageCount - 1);
    final start = page * _pageSize;
    final visible = list.skip(start).take(_pageSize).toList();

    Widget headerCell(String label, {required int flex}) => Expanded(
          flex: flex,
          child: Text(label,
              style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [AppTheme.cardShadow],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Expanded(
                    child: Text('Active Fleet Registry',
                        style: textTheme.titleMedium)),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 820),
              child: Column(
                children: [
                  Container(
                    color: AppColors.surfaceContainer,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: Row(
                      children: [
                        headerCell('NAME', flex: 3),
                        headerCell('PHONE', flex: 3),
                        headerCell('STATUS', flex: 2),
                        headerCell('ACTIVE JOB', flex: 2),
                        const SizedBox(width: 150),
                      ],
                    ),
                  ),
                  for (final driver in visible)
                    _DriverRow(
                        driver: driver,
                        activeJob: activeJobs[driver.id]),
                ],
              ),
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Showing ${start + 1}-${(start + _pageSize).clamp(0, list.length)} of ${list.length} drivers',
                    style: textTheme.bodySmall,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_left, size: 20),
                  onPressed: page > 0
                      ? () => setState(() => _page = page - 1)
                      : null,
                ),
                Text('${page + 1} / $pageCount',
                    style: textTheme.bodySmall),
                IconButton(
                  icon: const Icon(Icons.chevron_right, size: 20),
                  onPressed: page < pageCount - 1
                      ? () => setState(() => _page = page + 1)
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.drivers,
    required this.activeJobs,
    required this.desktop,
  });

  final List<AppUser> drivers;
  final Map<String, Job> activeJobs;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final onJob = drivers
        .where((driver) => activeJobs.containsKey(driver.id))
        .length;
    final available = drivers.length - onJob;

    Widget card(String label, String value, {Color? accent, Widget? extra}) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: accent == null
              ? null
              : Border(left: BorderSide(color: accent, width: 3)),
          boxShadow: const [AppTheme.cardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(),
                style: textTheme.bodySmall?.copyWith(letterSpacing: 0.8)),
            const SizedBox(height: 8),
            Text(value, style: textTheme.displaySmall),
            if (extra != null) ...[const SizedBox(height: 6), extra],
          ],
        ),
      );
    }

    final cards = [
      card('Total Drivers', '${drivers.length}'),
      card('Available', '$available',
          accent: AppColors.statusSuccess,
          extra: Text(
            drivers.isEmpty
                ? '—'
                : 'Active readiness ${(available / drivers.length * 100).round()}%',
            style: Theme.of(context).textTheme.bodySmall,
          )),
      card('On Job', '$onJob',
          accent: AppColors.accentDeep,
          extra: Text('Active transits',
              style: Theme.of(context).textTheme.bodySmall)),
      card('Avg. Rating', '4.8',
          extra: Row(children: [
            const Icon(Icons.star, size: 16, color: AppColors.accentDeep),
            const SizedBox(width: 4),
            Text('Fleet standard: High',
                style: Theme.of(context).textTheme.bodySmall),
          ])),
    ];

    if (desktop) {
      return Row(
        children: [
          for (final (index, card) in cards.indexed) ...[
            if (index > 0) const SizedBox(width: 20),
            Expanded(child: card),
          ],
        ],
      );
    }
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.6,
      children: cards,
    );
  }
}

class _DriverRow extends StatefulWidget {
  const _DriverRow({required this.driver, required this.activeJob});

  final AppUser driver;
  final Job? activeJob;

  @override
  State<_DriverRow> createState() => _DriverRowState();
}

class _DriverRowState extends State<_DriverRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final driver = widget.driver;
    final job = widget.activeJob;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        onTap: () => context.go('/admin/fleet/${driver.id}'),
        child: Container(
          color:
              _hovered ? AppColors.surfaceContainer : Colors.transparent,
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    InitialsAvatar(name: driver.name, size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(driver.name,
                          style: textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                    (driver.phone ?? '').isEmpty ? '—' : driver.phone!,
                    style: textTheme.bodyMedium),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: StatusChip(
                      status: job == null ? 'available' : 'on_job'),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  job == null
                      ? '--'
                      : '#JB-${job.id.substring(0, job.id.length.clamp(0, 4)).toUpperCase()}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: job == null
                        ? AppColors.textSecondary
                        : AppColors.accentDeep,
                    fontWeight:
                        job == null ? FontWeight.w400 : FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(
                width: 150,
                child: Row(
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 36),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      onPressed: () =>
                          context.go('/admin/fleet/${driver.id}'),
                      child: const Text('View'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navy,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 36),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onPressed: () =>
                          _EditDriverDialog.show(context, driver),
                      child: const Text('Edit'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Add-driver modal; returns the new users-doc id.
class _AddDriverDialog extends ConsumerStatefulWidget {
  const _AddDriverDialog();

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
        context: context, builder: (_) => const _AddDriverDialog());
  }

  @override
  ConsumerState<_AddDriverDialog> createState() => _AddDriverDialogState();
}

class _AddDriverDialogState extends ConsumerState<_AddDriverDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final id = await ref.read(driverMutationsProvider.notifier).addDriver(
            name: _name.text.trim(),
            email: _email.text.trim(),
            phone: _phone.text.trim(),
          );
      if (mounted) Navigator.of(context).pop(id);
    } catch (error) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not add driver: $error')),
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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add Driver', style: textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(
                  'The driver signs in once account invites go live (Stage 7).',
                  style: textTheme.bodySmall,
                ),
                const SizedBox(height: 20),
                _field('Full Name', _name,
                    validator: (value) => (value ?? '').trim().isEmpty
                        ? 'Name is required'
                        : null),
                _field('Email', _email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => (value ?? '').contains('@')
                        ? null
                        : 'Enter a valid email'),
                _field('Phone', _phone,
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _saving
                          ? null
                          : () => Navigator.of(context).pop(),
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
                                  strokeWidth: 2,
                                  color: AppColors.accentDeep),
                            )
                          : const Text('Add Driver'),
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

  Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),
          TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              validator: validator),
        ],
      ),
    );
  }
}

/// Edit name/phone modal for a driver row.
class _EditDriverDialog extends ConsumerStatefulWidget {
  const _EditDriverDialog({required this.driver});

  final AppUser driver;

  static Future<void> show(BuildContext context, AppUser driver) {
    return showDialog<void>(
        context: context,
        builder: (_) => _EditDriverDialog(driver: driver));
  }

  @override
  ConsumerState<_EditDriverDialog> createState() =>
      _EditDriverDialogState();
}

class _EditDriverDialogState extends ConsumerState<_EditDriverDialog> {
  late final _name = TextEditingController(text: widget.driver.name);
  late final _phone = TextEditingController(text: widget.driver.phone);
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(driverMutationsProvider.notifier).updateDriver(
            widget.driver.id,
            name: _name.text.trim(),
            phone: _phone.text.trim(),
          );
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update driver: $error')),
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
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit Driver', style: textTheme.headlineSmall),
              const SizedBox(height: 20),
              Text('Full Name', style: textTheme.labelLarge),
              const SizedBox(height: 6),
              TextField(controller: _name),
              const SizedBox(height: 16),
              Text('Phone', style: textTheme.labelLarge),
              const SizedBox(height: 6),
              TextField(controller: _phone),
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
                                strokeWidth: 2,
                                color: AppColors.accentDeep),
                          )
                        : const Text('Save'),
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
