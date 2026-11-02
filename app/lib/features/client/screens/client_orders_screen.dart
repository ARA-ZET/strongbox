import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/contact_us_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../providers/client_providers.dart';
import '../utils/client_orders.dart';
import '../widgets/new_order_button.dart';
import '../widgets/order_tile.dart';

/// The client's orders — pickups, deliveries and supply drop-offs — split
/// into what's still happening and what's done. `?view=past` opens Past.
class ClientOrdersScreen extends ConsumerWidget {
  const ClientOrdersScreen({super.key, this.past = false});

  final bool past;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobs = ref.watch(myJobsProvider);
    final list = jobs.valueOrNull ?? const [];
    final active = activeOrders(list);
    final done = pastOrders(list);
    final shown = past ? done : active;
    final tt = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth > 900;

        return SingleChildScrollView(
          padding: EdgeInsets.all(desktop ? AppSpacing.lg : AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Orders', style: tt.displaySmall),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Your pickups and deliveries, live.',
                        style: tt.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const OrderActions(),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: false,
                    label: Text('Active (${active.length})'),
                  ),
                  ButtonSegment(
                    value: true,
                    label: Text('Past (${done.length})'),
                  ),
                ],
                selected: {past},
                onSelectionChanged: (value) => context.go(
                  value.first ? '/client/orders?view=past' : '/client/orders',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (jobs.isLoading && list.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(AppSpacing.xxl),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (jobs.hasError && list.isEmpty)
                Text(
                  'Could not load your orders. Please try again.',
                  style: tt.bodyMedium?.copyWith(color: AppColors.statusError),
                )
              else if (shown.isEmpty)
                EmptyState(
                  icon: Icons.local_shipping_outlined,
                  title: past ? 'No past orders yet' : 'No active orders',
                  subtitle: past
                      ? 'Finished pickups and deliveries will show here.'
                      : 'Book a pickup to store more, or get items back from '
                            'storage — progress shows here in real time.',
                )
              else
                for (final job in shown) OrderTile(job: job),
              const SizedBox(height: AppSpacing.lg),
              const ContactUsCard(dense: true),
            ],
          ),
        );
      },
    );
  }
}
