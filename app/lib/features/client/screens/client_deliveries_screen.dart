import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/enums/app_enums.dart';
import '../../../core/models/job.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadow.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/contact_us_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/status_chip.dart';
import '../providers/client_providers.dart';

/// The client's pickups & deliveries with live status.
class ClientDeliveriesScreen extends ConsumerWidget {
  const ClientDeliveriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobs = ref.watch(myJobsProvider);
    final tt = Theme.of(context).textTheme;

    return LayoutBuilder(builder: (context, constraints) {
      final desktop = constraints.maxWidth > 900;

      return SingleChildScrollView(
        padding: EdgeInsets.all(desktop ? AppSpacing.lg : AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                    child: Text('Deliveries', style: tt.displaySmall)),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg),
                  ),
                  onPressed: () => context.go('/client/requests/new'),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New Request'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text('Track your pickups and deliveries in real time.',
                style:
                    tt.bodyMedium?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.lg),
            jobs.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(AppSpacing.xxl),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => Text('Could not load deliveries: $error',
                  style: tt.bodyMedium
                      ?.copyWith(color: AppColors.statusError)),
              data: (list) => list.isEmpty
                  ? const EmptyState(
                      icon: Icons.local_shipping_outlined,
                      title: 'No deliveries yet',
                      subtitle:
                          'Request a delivery and its progress will show '
                          'here in real time.',
                    )
                  : Column(
                      children: [
                        for (final job in list) _JobTile(job: job),
                      ],
                    ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const ContactUsCard(dense: true),
          ],
        ),
      );
    });
  }
}

class _JobTile extends StatelessWidget {
  const _JobTile({required this.job});

  final Job job;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pickup = job.type == JobType.pickup;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm + 4),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.md,
        boxShadow: AppShadow.card,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: pickup
                  ? AppColors.statusWarningBg
                  : AppColors.statusSuccessBg,
              borderRadius: AppRadius.sm,
            ),
            child: Icon(
              pickup ? Icons.archive_outlined : Icons.local_shipping_outlined,
              color: pickup ? AppColors.amberDark : AppColors.statusSuccess,
            ),
          ),
          const SizedBox(width: AppSpacing.sm + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${pickup ? 'Pickup' : 'Delivery'} · '
                  '${job.storageUnitIds.length} '
                  'unit${job.storageUnitIds.length == 1 ? '' : 's'}',
                  style: tt.titleMedium,
                ),
                Text(
                  job.scheduledDate == null
                      ? job.reference
                      : '${job.reference} · '
                          '${DateFormat('EEE d MMM').format(job.scheduledDate!)}'
                          ' · ${job.timeWindow.label}',
                  style: tt.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          StatusChip(status: job.status.name),
        ],
      ),
    );
  }
}
