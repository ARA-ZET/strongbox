import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enums/app_enums.dart';
import '../../../core/models/app_user.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_retry.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../../core/widgets/loading_skeleton.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/settings_providers.dart';

/// Wraps every route. While an admin is using "View as", pins a bar above
/// the app saying whose view this is, with an Exit button back to admin.
class ViewAsBanner extends ConsumerWidget {
  const ViewAsBanner({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewing = ref.watch(isViewingAsProvider);
    final user = ref.watch(currentUserProvider).valueOrNull;

    // Same tree shape either way, so the router below keeps its state.
    return Column(
      children: [
        viewing && user != null
            ? _ViewAsBar(user: user)
            : const SizedBox.shrink(),
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeTop: viewing,
            child: child,
          ),
        ),
      ],
    );
  }
}

class _ViewAsBar extends ConsumerWidget {
  const _ViewAsBar({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final name = user.name.isEmpty ? user.email : user.name;

    return Material(
      color: AppColors.navyDeep,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: [
              const Icon(Icons.visibility_outlined,
                  color: AppColors.sky, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Viewing as $name (${user.role.name}). '
                  'Anything you do here really happens.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall
                      ?.copyWith(color: AppColors.onNavy),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: AppColors.sky),
                onPressed: () => ref.read(viewAsProvider.notifier).stop(),
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Exit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Picks a client or driver account and switches the app to "View as" it:
/// their portal, their data, their role guards. The admin stays signed in
/// as themselves; [ViewAsBanner] offers the way back.
class ViewAsDialog extends ConsumerStatefulWidget {
  const ViewAsDialog({super.key});

  /// Opens the picker.
  static Future<void> show(BuildContext context) => showDialog<void>(
        context: context,
        builder: (_) => const ViewAsDialog(),
      );

  @override
  ConsumerState<ViewAsDialog> createState() => _ViewAsDialogState();
}

class _ViewAsDialogState extends ConsumerState<ViewAsDialog> {
  var _role = UserRole.client;
  var _query = '';

  bool _matches(AppUser user) =>
      _query.isEmpty ||
      user.name.toLowerCase().contains(_query) ||
      user.email.toLowerCase().contains(_query);

  void _view(AppUser user) {
    Navigator.of(context).pop();
    // The router follows the switch to [user]'s portal on its own.
    ref.read(viewAsProvider.notifier).start(user);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final users = ref.watch(teamMembersProvider(_role));

    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.md),
      title: const Text('View as user'),
      content: SizedBox(
        width: 460,
        height: 440,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'See the app exactly as they do. You stay signed in as '
              'yourself, and anything you do there is real and logged '
              'under your name.',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SegmentedButton<UserRole>(
              segments: const [
                ButtonSegment(
                  value: UserRole.client,
                  label: Text('Client'),
                  icon: Icon(Icons.person_outline),
                ),
                ButtonSegment(
                  value: UserRole.driver,
                  label: Text('Driver'),
                  icon: Icon(Icons.local_shipping_outlined),
                ),
              ],
              selected: {_role},
              onSelectionChanged: (s) => setState(() => _role = s.first),
            ),
            const SizedBox(height: AppSpacing.md),
            AppSearchBar(
              hint: 'Search by name or email',
              onChanged: (q) =>
                  setState(() => _query = q.trim().toLowerCase()),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: users.when(
                loading: () => ListView(
                  children: [
                    for (var i = 0; i < 4; i++) LoadingSkeleton.listTile(),
                  ],
                ),
                error: (error, _) => ErrorRetry(
                  error: error,
                  onRetry: () => ref.invalidate(teamMembersProvider(_role)),
                ),
                data: (all) {
                  final matches = all.where(_matches).toList()
                    ..sort((a, b) => a.name.toLowerCase()
                        .compareTo(b.name.toLowerCase()));
                  if (matches.isEmpty) {
                    return SingleChildScrollView(
                      child: EmptyState(
                        icon: Icons.person_search_outlined,
                        title: 'No ${_role.name}s found',
                        subtitle: _query.isEmpty
                            ? null
                            : 'Nobody matches "$_query".',
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: matches.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, color: AppColors.border),
                    itemBuilder: (context, i) {
                      final user = matches[i];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: InitialsAvatar(name: user.name, size: 36),
                        title: Text(
                            user.name.isEmpty ? user.email : user.name),
                        subtitle: user.name.isEmpty ? null : Text(user.email),
                        trailing: const Icon(Icons.chevron_right,
                            color: AppColors.textHint),
                        onTap: () => _view(user),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
