import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/enums/app_enums.dart';
import '../../../core/models/job.dart';
import '../../../core/providers/business_settings_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadow.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/public_ref.dart';
import '../../../core/widgets/status_chip.dart';
import '../utils/client_orders.dart';

/// Icon + tint for an order type.
(IconData, Color, Color) orderTypeStyle(JobType type) => switch (type) {
  JobType.pickup => (
    Icons.archive_outlined,
    AppColors.skyTint,
    AppColors.accentDeep,
  ),
  JobType.delivery => (
    Icons.local_shipping_outlined,
    AppColors.statusSuccessBg,
    AppColors.statusSuccess,
  ),
  JobType.supplyDrop => (
    Icons.inventory_outlined,
    AppColors.statusPendingBg,
    AppColors.textSecondary,
  ),
};

/// One order (pickup, delivery or supply drop-off): what, when, where it's
/// at. Tapping opens the order.
class OrderTile extends ConsumerWidget {
  const OrderTile({super.key, required this.job});

  final Job job;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final settings = ref.watch(businessSettingsProvider);
    final (icon, bg, fg) = orderTypeStyle(job.type);
    final when = job.scheduledDate == null
        ? jobRef(job)
        : '${jobRef(job)} · '
              '${DateFormat('EEE d MMM').format(job.scheduledDate!)} · '
              '${settings.windowLabel(job.timeWindow)}';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm + 4),
      child: Material(
        color: AppColors.surface,
        borderRadius: AppRadius.md,
        child: InkWell(
          borderRadius: AppRadius.md,
          onTap: () => context.go('/client/orders/${job.id}'),
          child: Ink(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: const BoxDecoration(
              borderRadius: AppRadius.md,
              boxShadow: AppShadow.card,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: AppRadius.sm,
                  ),
                  child: Icon(icon, color: fg),
                ),
                const SizedBox(width: AppSpacing.sm + 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(orderTitle(job), style: tt.titleMedium),
                      Text(
                        when,
                        style: tt.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        orderNextStep(job),
                        style: tt.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    StatusChip(
                      status: job.status.name,
                      label: orderStatusLabel(job),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.textHint,
                      size: 20,
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
