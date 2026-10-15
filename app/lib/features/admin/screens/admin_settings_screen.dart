import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enums/app_enums.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/models/app_user.dart';
import '../../../core/providers/business_settings_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadow.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../../core/widgets/section_header.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/settings_providers.dart';

/// Admin settings: the signed-in admin's profile, who has admin/driver
/// access, the business's public details, and operations defaults (job
/// time-window hours, service area). No Stitch design exists for this
/// screen; it follows the pricing screen's card layout.
class AdminSettingsScreen extends ConsumerWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final settings = ref.watch(businessSettingsProvider);
    final live = ref.watch(liveBusinessSettingsProvider);
    final me = ref.watch(currentUserProvider).valueOrNull;

    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth > 900;
        return SingleChildScrollView(
          padding: EdgeInsets.all(desktop ? AppSpacing.lg : AppSpacing.md),
          child: Align(
            alignment: Alignment.topLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Settings', style: textTheme.displaySmall),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Your profile, your team, and the business details clients '
                    'see in the app.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (live.hasError)
                    _Banner(
                      message:
                          'Could not load saved business settings — '
                          'showing the defaults. ${_errorText(live.error!)}',
                      onRetry: () =>
                          ref.invalidate(liveBusinessSettingsProvider),
                    ),
                  if (me != null)
                    _ProfileSection(
                      key: ValueKey('${me.name}|${me.phone}'),
                      me: me,
                      wide: desktop,
                    ),
                  _TeamSection(myId: me?.id),
                  // Re-keyed on save so the fields show what is stored.
                  _BusinessSection(
                    key: ValueKey(('business', settings.updatedAt)),
                    settings: settings,
                    wide: desktop,
                  ),
                  _OperationsSection(
                    key: ValueKey(('operations', settings.updatedAt)),
                    settings: settings,
                    wide: desktop,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A save or load failure as one readable line.
String _errorText(Object error) => switch (error) {
  StateError(:final message) => message,
  AppException(:final message, :final code) => '$message ($code)',
  _ => '$error',
};

// ------------------------------------------------------------------ layout

class _Card extends StatelessWidget {
  const _Card({
    required this.title,
    required this.subtitle,
    required this.child,
    this.action,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.md,
        boxShadow: AppShadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: title, action: action),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.statusErrorBg,
        borderRadius: AppRadius.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.statusError),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

/// Fields side by side on desktop, stacked on mobile.
class _Fields extends StatelessWidget {
  const _Fields({required this.wide, required this.children});

  final bool wide;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (!wide) return Column(children: children);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.md),
          Expanded(child: children[i]),
        ],
      ],
    );
  }
}

Widget _field(
  TextEditingController controller,
  String label, {
  String? hint,
  TextInputType? keyboardType,
  String? Function(String?)? validator,
  bool enabled = true,
  int maxLines = 1,
}) => Padding(
  padding: const EdgeInsets.only(bottom: AppSpacing.md),
  child: TextFormField(
    controller: controller,
    enabled: enabled,
    keyboardType: maxLines > 1 ? TextInputType.multiline : keyboardType,
    minLines: maxLines > 1 ? 2 : null,
    maxLines: maxLines,
    validator: validator,
    decoration: InputDecoration(labelText: label, hintText: hint),
  ),
);

String? _required(String? value) =>
    (value ?? '').trim().isEmpty ? 'Required' : null;

/// Save button plus the last failure, shared by the form sections.
class _SaveRow extends StatelessWidget {
  const _SaveRow({
    required this.saving,
    required this.error,
    required this.onSave,
    this.secondary,
  });

  final bool saving;
  final String? error;
  final VoidCallback onSave;
  final Widget? secondary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              'Not saved: $error',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.statusError),
            ),
          ),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(160, 44)),
              onPressed: saving ? null : onSave,
              child: saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save changes'),
            ),
            // Null check kept as `if`: build_runner's analyzer can't parse
            // `?element` yet.
            // ignore: use_null_aware_elements
            if (secondary != null) secondary!,
          ],
        ),
      ],
    );
  }
}

/// Runs [save] for a form section: validates, tracks progress, and reports
/// success in a snackbar or the failure inline.
mixin _SavingForm<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  final formKey = GlobalKey<FormState>();
  bool saving = false;
  String? error;

  Future<void> runSave(Future<void> Function() save, String done) async {
    if (!formKey.currentState!.validate()) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      saving = true;
      error = null;
    });
    try {
      await save();
      messenger.showSnackBar(SnackBar(content: Text(done)));
    } catch (e) {
      if (mounted) setState(() => error = _errorText(e));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }
}

// ---------------------------------------------------------------- profile

class _ProfileSection extends ConsumerStatefulWidget {
  const _ProfileSection({super.key, required this.me, required this.wide});

  final AppUser me;
  final bool wide;

  @override
  ConsumerState<_ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends ConsumerState<_ProfileSection>
    with _SavingForm {
  late final _name = TextEditingController(text: widget.me.name);
  late final _phone = TextEditingController(text: widget.me.phone ?? '');
  late final _email = TextEditingController(text: widget.me.email);

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    final messenger = ScaffoldMessenger.of(context);
    final auth = ref.read(authNotifierProvider.notifier);
    await auth.resetPassword(widget.me.email);
    final result = ref.read(authNotifierProvider);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          result.hasError
              ? 'Could not send the email: ${_errorText(result.error!)}'
              : 'Password reset email sent to ${widget.me.email}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'My profile',
      subtitle: 'How you appear on jobs and in the audit log.',
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InitialsAvatar(name: widget.me.name, size: 48),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Admin',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _Fields(
              wide: widget.wide,
              children: [
                _field(_name, 'Full name', validator: _required),
                _field(_phone, 'Phone', keyboardType: TextInputType.phone),
              ],
            ),
            _field(_email, 'Email (used to sign in)', enabled: false),
            _SaveRow(
              saving: saving,
              error: error,
              onSave: () => runSave(
                () => ref
                    .read(profileEditorProvider.notifier)
                    .save(name: _name.text, phone: _phone.text),
                'Profile saved',
              ),
              secondary: OutlinedButton(
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
                onPressed: _sendReset,
                child: const Text('Send password reset email'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------- team

class _TeamSection extends ConsumerWidget {
  const _TeamSection({required this.myId});

  final String? myId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final admins = ref.watch(teamMembersProvider(UserRole.admin));
    final drivers = ref.watch(teamMembersProvider(UserRole.driver));

    Widget group(String label, AsyncValue<List<AppUser>> members) {
      final textTheme = Theme.of(context).textTheme;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.sm,
              bottom: AppSpacing.xs,
            ),
            child: Text(
              label,
              style: textTheme.labelLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ...members.when(
            data: (list) => list.isEmpty
                ? [
                    Text(
                      'None yet.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textHint,
                      ),
                    ),
                  ]
                : [
                    for (final user in list)
                      _MemberRow(user: user, isMe: user.id == myId),
                  ],
            loading: () => const [LinearProgressIndicator()],
            error: (e, _) => [
              Text(
                _errorText(e),
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.statusError,
                ),
              ),
            ],
          ),
        ],
      );
    }

    return _Card(
      title: 'Team & roles',
      subtitle:
          'Admins run operations; drivers get the driver app. People '
          'sign up in the app first, then you give them access here.',
      action: TextButton.icon(
        onPressed: () async {
          final picked = await _AddMemberDialog.show(context);
          if (picked == null || !context.mounted) return;
          await _confirmRoleChange(context, ref, picked.$1, picked.$2);
        },
        icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
        label: const Text('Add team member'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          group('Admins', admins),
          const SizedBox(height: AppSpacing.sm),
          group('Drivers', drivers),
        ],
      ),
    );
  }
}

String _roleTitle(UserRole role) => switch (role) {
  UserRole.admin => 'Admin',
  UserRole.driver => 'Driver',
  UserRole.client => 'Client',
};

/// Asks for confirmation, then changes [user]'s role; reports the outcome.
Future<void> _confirmRoleChange(
  BuildContext context,
  WidgetRef ref,
  AppUser user,
  UserRole role,
) async {
  final name = user.name.isEmpty ? user.email : user.name;
  final ok = await showConfirmDialog(
    context,
    title: role == UserRole.client
        ? 'Remove staff access?'
        : 'Make $name ${role == UserRole.admin ? 'an admin' : 'a driver'}?',
    message: switch (role) {
      UserRole.admin =>
        '$name will get full admin access: inventory, jobs, '
            'clients, pricing and settings.',
      UserRole.driver =>
        '$name will see the driver app with their assigned '
            'jobs.',
      UserRole.client =>
        '$name goes back to a client account and loses '
            'access to the ${_roleTitle(user.role).toLowerCase()} portal.',
    },
    confirmLabel: role == UserRole.client ? 'Remove access' : 'Confirm',
    isDestructive: role == UserRole.client,
  );
  if (!ok || !context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  try {
    await ref.read(teamEditorProvider.notifier).changeRole(user, role);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          '$name is now ${_roleTitle(role).toLowerCase()}. '
          'They see the change next time they open the app.',
        ),
      ),
    );
  } catch (e) {
    messenger.showSnackBar(
      SnackBar(content: Text('Not changed: ${_errorText(e)}')),
    );
  }
}

class _MemberRow extends ConsumerWidget {
  const _MemberRow({required this.user, required this.isMe});

  final AppUser user;
  final bool isMe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final others = UserRole.values.where((r) => r != user.role);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          InitialsAvatar(name: user.name, size: 36),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMe ? '${user.name} (you)' : user.name,
                  style: textTheme.titleSmall,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  user.email,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (!isMe)
            PopupMenuButton<UserRole>(
              tooltip: 'Change role',
              icon: const Icon(Icons.more_vert, color: AppColors.textHint),
              onSelected: (role) =>
                  _confirmRoleChange(context, ref, user, role),
              itemBuilder: (_) => [
                for (final role in others)
                  PopupMenuItem(
                    value: role,
                    child: Text(
                      role == UserRole.client
                          ? 'Remove staff access'
                          : 'Make ${_roleTitle(role).toLowerCase()}',
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Find a signed-up account by email and give it admin or driver access.
class _AddMemberDialog extends ConsumerStatefulWidget {
  const _AddMemberDialog();

  /// The account to change and the role to give it, or null if cancelled.
  static Future<(AppUser, UserRole)?> show(BuildContext context) =>
      showDialog<(AppUser, UserRole)>(
        context: context,
        builder: (_) => const _AddMemberDialog(),
      );

  @override
  ConsumerState<_AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends ConsumerState<_AddMemberDialog> {
  final _email = TextEditingController();
  var _role = UserRole.driver;
  var _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    if (!email.contains('@')) {
      setState(() => _error = 'Enter the email they signed up with.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final editor = ref.read(teamEditorProvider.notifier);
      final user = await editor.findAccount(email);
      if (user.role == _role) {
        throw StateError(
          '${user.name.isEmpty ? email : user.name} is '
          'already ${_role == UserRole.admin ? 'an admin' : 'a driver'}.',
        );
      }
      if (mounted) Navigator.of(context).pop((user, _role));
    } catch (e) {
      if (mounted) setState(() => _error = _errorText(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.md),
      title: const Text('Add team member'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'They need a StrongBox account first — ask them to sign up in '
              'the app, then enter the same email here.',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Their email'),
              onSubmitted: (_) => _busy ? null : _submit(),
            ),
            const SizedBox(height: AppSpacing.md),
            SegmentedButton<UserRole>(
              segments: const [
                ButtonSegment(
                  value: UserRole.driver,
                  label: Text('Driver'),
                  icon: Icon(Icons.local_shipping_outlined),
                ),
                ButtonSegment(
                  value: UserRole.admin,
                  label: Text('Admin'),
                  icon: Icon(Icons.admin_panel_settings_outlined),
                ),
              ],
              selected: {_role},
              onSelectionChanged: (s) => setState(() => _role = s.first),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md),
                child: Text(
                  _error!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.statusError,
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _busy ? null : _submit,
          child: _busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Continue'),
        ),
      ],
    );
  }
}

// --------------------------------------------------------------- business

class _BusinessSection extends ConsumerStatefulWidget {
  const _BusinessSection({
    super.key,
    required this.settings,
    required this.wide,
  });

  final BusinessSettings settings;
  final bool wide;

  @override
  ConsumerState<_BusinessSection> createState() => _BusinessSectionState();
}

class _BusinessSectionState extends ConsumerState<_BusinessSection>
    with _SavingForm {
  late final _name = TextEditingController(text: widget.settings.name);
  late final _phone = TextEditingController(text: widget.settings.contactPhone);
  late final _email = TextEditingController(text: widget.settings.contactEmail);
  late final _line1 = TextEditingController(
    text: widget.settings.address.line1,
  );
  late final _line2 = TextEditingController(
    text: widget.settings.address.line2 ?? '',
  );
  late final _city = TextEditingController(text: widget.settings.address.city);
  late final _postCode = TextEditingController(
    text: widget.settings.address.postCode,
  );
  late final _payment = TextEditingController(
    text: widget.settings.paymentInstructions,
  );

  @override
  void dispose() {
    for (final c in [
      _name, _phone, _email, _line1, _line2, _city, _postCode, _payment, //
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() => ref
      .read(businessSettingsEditorProvider.notifier)
      .save(
        (current) => current.copyWith(
          name: _name.text.trim(),
          contactPhone: _phone.text.trim(),
          contactEmail: _email.text.trim(),
          address: current.address.copyWith(
            line1: _line1.text.trim(),
            line2: _line2.text.trim().isEmpty ? null : _line2.text.trim(),
            city: _city.text.trim(),
            postCode: _postCode.text.trim(),
          ),
          paymentInstructions: _payment.text.trim(),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Business details',
      subtitle:
          'The contact details on the login screen and the "talk to a '
          'real person" cards in the client app, and how clients pay '
          'their invoices.',
      child: Form(
        key: formKey,
        child: Column(
          children: [
            _field(_name, 'Business name', validator: _required),
            _Fields(
              wide: widget.wide,
              children: [
                _field(
                  _phone,
                  'Contact phone',
                  hint: '+27 071 909 0839',
                  keyboardType: TextInputType.phone,
                  validator: _required,
                ),
                _field(
                  _email,
                  'Contact email',
                  keyboardType: TextInputType.emailAddress,
                  validator: _required,
                ),
              ],
            ),
            _Fields(
              wide: widget.wide,
              children: [
                _field(_line1, 'Address line 1'),
                _field(_line2, 'Address line 2 (optional)'),
              ],
            ),
            _Fields(
              wide: widget.wide,
              children: [
                _field(_city, 'City'),
                _field(
                  _postCode,
                  'Postal code',
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            _field(
              _payment,
              'EFT payment details (shown to clients with their invoices)',
              hint: 'FNB · StrongBox Logistics (Pty) Ltd\n'
                  'Acc 62000000000 · Branch 250655',
              maxLines: 4,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: _SaveRow(
                saving: saving,
                error: error,
                onSave: () => runSave(_save, 'Business details saved'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------- operations

class _OperationsSection extends ConsumerStatefulWidget {
  const _OperationsSection({
    super.key,
    required this.settings,
    required this.wide,
  });

  final BusinessSettings settings;
  final bool wide;

  @override
  ConsumerState<_OperationsSection> createState() => _OperationsSectionState();
}

class _OperationsSectionState extends ConsumerState<_OperationsSection>
    with _SavingForm {
  late final _area = TextEditingController(text: widget.settings.serviceArea);
  late final _hours = {
    for (final window in TimeWindow.values)
      window: (
        start: TextEditingController(
          text: widget.settings.hoursFor(window).start,
        ),
        end: TextEditingController(text: widget.settings.hoursFor(window).end),
      ),
  };

  @override
  void dispose() {
    _area.dispose();
    for (final pair in _hours.values) {
      pair.start.dispose();
      pair.end.dispose();
    }
    super.dispose();
  }

  WindowHours _read(TimeWindow window) => WindowHours(
    start: _hours[window]!.start.text.trim(),
    end: _hours[window]!.end.text.trim(),
  );

  Future<void> _save() => ref
      .read(businessSettingsEditorProvider.notifier)
      .save(
        (current) => current.copyWith(
          serviceArea: _area.text.trim(),
          morning: _read(TimeWindow.morning),
          afternoon: _read(TimeWindow.afternoon),
          evening: _read(TimeWindow.evening),
        ),
      );

  /// Opens the time picker over [controller]'s `HH:mm` value.
  Future<void> _pick(TextEditingController controller) async {
    final parts = controller.text.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts.first) ?? 8,
      minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked == null) return;
    String two(int n) => n.toString().padLeft(2, '0');
    controller.text = '${two(picked.hour)}:${two(picked.minute)}';
  }

  Widget _timeField(TextEditingController controller, String label) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.md),
    child: TextFormField(
      controller: controller,
      readOnly: true,
      onTap: () => _pick(controller),
      validator: _required,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.schedule, size: 18),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return _Card(
      title: 'Operations',
      subtitle:
          'Shown when admins create jobs and clients book a delivery. '
          'Jobs already booked keep their window.',
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _field(
              _area,
              'Service area',
              hint: 'e.g. Cape Town and surrounds',
              validator: _required,
            ),
            Text('Time windows', style: textTheme.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            for (final window in TimeWindow.values)
              _Fields(
                wide: true,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.md),
                    child: Text(window.title, style: textTheme.bodyLarge),
                  ),
                  _timeField(_hours[window]!.start, 'Starts'),
                  _timeField(_hours[window]!.end, 'Ends'),
                ],
              ),
            _SaveRow(
              saving: saving,
              error: error,
              onSave: () => runSave(_save, 'Operations settings saved'),
            ),
          ],
        ),
      ),
    );
  }
}
