import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../repositories/push_repository.dart';
import '../providers/notification_providers.dart';

/// "Turn on push notifications" prompt. Only shows while this device can
/// receive push and the user has not yet answered the permission prompt —
/// browsers only show that prompt from a click, so web relies on this.
class PushPermissionBanner extends ConsumerWidget {
  const PushPermissionBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(pushNotificationsProvider).valueOrNull;
    if (status != PushPermission.notDetermined) return const SizedBox.shrink();
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.skyTint,
        borderRadius: AppRadius.md,
        border: Border.all(color: AppColors.border),
      ),
      child: Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.notifications_active_outlined,
                  color: AppColors.accentDeep),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  'Get job and billing updates on this device.',
                  style: tt.bodyMedium,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () =>
                ref.read(pushNotificationsProvider.notifier).enable(),
            child: const Text('Turn on notifications'),
          ),
        ],
      ),
    );
  }
}
