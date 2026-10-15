import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/enums/app_enums.dart';
import '../../../core/models/app_notification.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadow.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/relative_time.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_retry.dart';
import '../../../core/widgets/loading_skeleton.dart';
import '../providers/notification_providers.dart';

/// The signed-in user's notifications as a card list (doc 22): unread rows
/// tinted, newest first, "Mark all read" in the header. Tapping a row marks
/// it read and opens its [AppNotification.route].
///
/// [limit] caps the rows shown (e.g. a "Recent" preview); null shows all.
class NotificationInbox extends ConsumerWidget {
  const NotificationInbox({super.key, this.limit});

  final int? limit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(myNotificationsProvider);
    final unread = ref.watch(unreadNotificationCountProvider);
    final tt = Theme.of(context).textTheme;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.md,
        boxShadow: AppShadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.sm, AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    unread == 0 ? 'All caught up' : '$unread unread',
                    style: tt.titleSmall,
                  ),
                ),
                TextButton(
                  onPressed: unread == 0
                      ? null
                      : () => _run(context,
                          ref.read(notificationActionsProvider.notifier)
                              .markAllRead),
                  child: const Text('Mark all read'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          notifications.when(
            loading: () => Column(
              children: [
                for (var i = 0; i < 3; i++) LoadingSkeleton.listTile(),
              ],
            ),
            error: (error, _) => ErrorRetry(
              error: error,
              onRetry: () => ref.invalidate(myNotificationsProvider),
            ),
            data: (list) {
              if (list.isEmpty) {
                return const EmptyState(
                  icon: Icons.notifications_none,
                  title: 'No notifications yet',
                  subtitle: 'Job updates, invoices and messages from the '
                      'team will appear here.',
                );
              }
              final shown = limit == null ? list : list.take(limit!);
              return Column(
                children: [
                  for (final n in shown) _NotificationTile(notification: n),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  static Future<void> _run(
      BuildContext context, Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update notifications: $error')),
        );
      }
    }
  }
}

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final n = notification;
    final (icon, fg, bg) = _style(n.type);

    return Material(
      color: n.isRead ? AppColors.surface : AppColors.skyTint,
      child: InkWell(
        onTap: () {
          ref
              .read(notificationActionsProvider.notifier)
              .markRead(n)
              .catchError((_) {});
          final route = n.route;
          if (route != null && route.startsWith('/')) context.go(route);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm + 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                child: Icon(icon, size: 20, color: fg),
              ),
              const SizedBox(width: AppSpacing.sm + 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n.title,
                      style: tt.bodyMedium?.copyWith(
                          fontWeight:
                              n.isRead ? FontWeight.w500 : FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (n.body.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        n.body,
                        style: tt.bodySmall
                            ?.copyWith(color: AppColors.textSecondary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (n.createdAt != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(relativeTime(n.createdAt!),
                          style: tt.bodySmall
                              ?.copyWith(color: AppColors.textHint)),
                    ],
                  ],
                ),
              ),
              if (!n.isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(
                      left: AppSpacing.sm, top: AppSpacing.xs),
                  decoration: const BoxDecoration(
                      color: AppColors.accent, shape: BoxShape.circle),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static (IconData, Color, Color) _style(NotificationType type) =>
      switch (type) {
        NotificationType.jobCompleted ||
        NotificationType.pickupConfirmed ||
        NotificationType.deliveryCompleted ||
        NotificationType.invoicePaid =>
          (
            Icons.check_circle_outline,
            AppColors.statusSuccess,
            AppColors.statusSuccessBg
          ),
        NotificationType.jobCancelled => (
            Icons.cancel_outlined,
            AppColors.statusError,
            AppColors.statusErrorBg
          ),
        NotificationType.issueReported => (
            Icons.report_problem_outlined,
            AppColors.statusWarning,
            AppColors.statusWarningBg
          ),
        NotificationType.invoiceReady => (
            Icons.receipt_long_outlined,
            AppColors.accentDeep,
            AppColors.surfaceContainer
          ),
        NotificationType.qrUnlinkedAlert => (
            Icons.qr_code_2,
            AppColors.accentDeep,
            AppColors.surfaceContainer
          ),
        NotificationType.directMessage => (
            Icons.chat_bubble_outline,
            AppColors.accentDeep,
            AppColors.surfaceContainer
          ),
        NotificationType.jobScheduled ||
        NotificationType.jobAssigned ||
        NotificationType.jobStarted ||
        NotificationType.deliveryRequested =>
          (
            Icons.local_shipping_outlined,
            AppColors.accentDeep,
            AppColors.surfaceContainer
          ),
        NotificationType.storageThreshold ||
        NotificationType.systemAlert =>
          (
            Icons.notifications_outlined,
            AppColors.textSecondary,
            AppColors.surfaceContainer
          ),
      };
}
