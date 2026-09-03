import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadow.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/contact_us_card.dart';
import '../../../core/widgets/status_chip.dart';
import '../providers/client_providers.dart';

/// Billing & subscription (ZAR). Design:
/// client_designs/subscription_billing/screen.png.
class ClientSubscriptionScreen extends ConsumerWidget {
  const ClientSubscriptionScreen({super.key});

  static String _priceLabel(SubscriptionPlan plan) {
    final price = AppConstants.planPricesZar[plan.name] ?? 0;
    return price == 0
        ? 'Custom'
        : 'R${NumberFormat.decimalPattern().format(price)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(currentClientProvider).valueOrNull;
    final units = ref.watch(myUnitsProvider).valueOrNull ?? const [];
    final tt = Theme.of(context).textTheme;

    final plan = client?.subscriptionPlan ?? SubscriptionPlan.starter;
    final limit = AppConstants.planUnitLimits[plan.name] ?? 0;
    final used = units
        .where((unit) => unit.status != StorageStatus.archived)
        .length;
    final fraction = limit > 0 ? (used / limit).clamp(0.0, 1.0) : 0.0;

    return LayoutBuilder(builder: (context, constraints) {
      final desktop = constraints.maxWidth > 900;

      final capacity = Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.md,
          boxShadow: AppShadow.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Warehouse Capacity', style: tt.titleMedium),
            const SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('$used', style: tt.displaySmall),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  limit > 0 ? '/ $limit units used' : 'units stored',
                  style: tt.bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                ),
                const Spacer(),
                if (limit > 0 && fraction >= 0.8)
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          size: 16, color: AppColors.statusWarning),
                      const SizedBox(width: AppSpacing.xs),
                      Text('Approaching plan limit',
                          style: tt.bodySmall?.copyWith(
                              color: AppColors.statusWarning,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm + 4),
            ClipRRect(
              borderRadius: AppRadius.pill,
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 10,
                backgroundColor: AppColors.surfaceContainer,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.amber),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm + 4,
              runSpacing: AppSpacing.sm,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md),
                  ),
                  onPressed: () => _stripeComingSoon(context),
                  child: const Text('Upgrade Plan'),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md),
                  ),
                  onPressed: () => _stripeComingSoon(context),
                  child: const Text('View Analytics'),
                ),
              ],
            ),
          ],
        ),
      );

      final activePlan = Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(
          color: AppColors.navy,
          borderRadius: AppRadius.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ACTIVE PLAN',
                style: tt.bodySmall?.copyWith(
                    color: AppColors.amber, letterSpacing: 1)),
            const SizedBox(height: AppSpacing.xs),
            Text(plan.label,
                style: tt.displaySmall?.copyWith(color: Colors.white)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              plan == SubscriptionPlan.enterprise
                  ? 'Custom pricing • talk to us'
                  : '${_priceLabel(plan)} / month',
              style: tt.bodyMedium?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: AppSpacing.sm),
            StatusChip(
                status:
                    (client?.subscriptionStatus ?? SubscriptionStatus.active)
                        .name),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _stripeComingSoon(context),
                child: const Text('Manage Billing'),
              ),
            ),
          ],
        ),
      );

      return SingleChildScrollView(
        padding: EdgeInsets.all(desktop ? AppSpacing.lg : AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Billing & Subscription', style: tt.displaySmall),
            const SizedBox(height: AppSpacing.xs),
            Text('Manage your warehouse allocation and subscription plans.',
                style:
                    tt.bodyMedium?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.lg),
            if (desktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 55, child: capacity),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(flex: 45, child: activePlan),
                ],
              )
            else ...[
              capacity,
              const SizedBox(height: AppSpacing.lg),
              activePlan,
            ],
            const SizedBox(height: AppSpacing.lg),
            Text('Available Plans', style: tt.headlineSmall),
            const SizedBox(height: AppSpacing.sm + 4),
            _PlanComparison(current: plan),
            const SizedBox(height: AppSpacing.lg),
            Text('Payment History', style: tt.headlineSmall),
            const SizedBox(height: AppSpacing.sm + 4),
            const _InvoiceTable(),
            const SizedBox(height: AppSpacing.lg),
            const ContactUsCard(dense: true),
          ],
        ),
      );
    });
  }

  static void _stripeComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content:
              Text('Online billing goes live with Stripe in Stage 7.')),
    );
  }
}

// ------------------------------------------------------------ plan compare

class _PlanComparison extends StatelessWidget {
  const _PlanComparison({required this.current});

  final SubscriptionPlan current;

  static const _features = <SubscriptionPlan, List<String>>{
    SubscriptionPlan.starter: ['20 Storage Units', 'Basic Analytics'],
    SubscriptionPlan.professional: [
      '100 Storage Units',
      'Advanced Analytics',
      'Priority Support',
    ],
    SubscriptionPlan.enterprise: [
      'Unlimited Units',
      'Dedicated Account Mgr',
    ],
  };

  static const _taglines = <SubscriptionPlan, String>{
    SubscriptionPlan.starter: 'Ideal for individuals & small setups.',
    SubscriptionPlan.professional: 'Scaling logistics for growing teams.',
    SubscriptionPlan.enterprise: 'Custom solutions for heavy logistics.',
  };

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    Widget planCard(SubscriptionPlan plan) {
      final isCurrent = plan == current;
      final price = AppConstants.planPricesZar[plan.name] ?? 0;

      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.md,
          border: Border.all(
            color: isCurrent ? AppColors.amberDark : AppColors.border,
            width: isCurrent ? 2 : 1,
          ),
          boxShadow: AppShadow.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isCurrent) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm + 4, vertical: 4),
                decoration: const BoxDecoration(
                  color: AppColors.amberDark,
                  borderRadius: AppRadius.pill,
                ),
                child: Text('CURRENT PLAN',
                    style: tt.bodySmall?.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            Text(plan.label, style: tt.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(_taglines[plan]!, style: tt.bodySmall),
            const SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price == 0
                      ? 'Custom'
                      : 'R${NumberFormat.decimalPattern().format(price)}',
                  style: tt.displaySmall,
                ),
                if (price != 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(' /mo', style: tt.bodySmall),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            for (final feature in _features[plan]!)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline,
                        size: 16, color: AppColors.statusSuccess),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                        child: Text(feature, style: tt.bodyMedium)),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: isCurrent
                  ? const ElevatedButton(
                      onPressed: null,
                      child: Text('Current Subscription'),
                    )
                  : plan == SubscriptionPlan.enterprise
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.navy,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () =>
                              ClientSubscriptionScreen._stripeComingSoon(
                                  context),
                          child: const Text('Contact Sales'),
                        )
                      : OutlinedButton(
                          onPressed: () =>
                              ClientSubscriptionScreen._stripeComingSoon(
                                  context),
                          child: Text(
                              plan.index < current.index
                                  ? 'Switch to ${plan.label}'
                                  : 'Upgrade Now'),
                        ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(builder: (context, constraints) {
      final wide = constraints.maxWidth > 900;
      final cards = SubscriptionPlan.values.map(planCard).toList();
      if (wide) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (index, card) in cards.indexed) ...[
              if (index > 0) const SizedBox(width: AppSpacing.md),
              Expanded(child: card),
            ],
          ],
        );
      }
      return Column(
        children: [
          for (final (index, card) in cards.indexed) ...[
            if (index > 0) const SizedBox(height: AppSpacing.md),
            card,
          ],
        ],
      );
    });
  }
}

// ------------------------------------------------------------ invoice table

class _InvoiceTable extends ConsumerWidget {
  const _InvoiceTable();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoices = ref.watch(myInvoicesProvider);
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.md,
        boxShadow: AppShadow.card,
      ),
      child: invoices.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Text('Could not load invoices: $error',
              style: tt.bodyMedium?.copyWith(color: AppColors.statusError)),
        ),
        data: (list) => list.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  'No invoices yet — statements appear here once online '
                  'billing goes live.',
                  style: tt.bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 640),
                  child: Column(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(12)),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm + 4),
                        child: Row(
                          children: [
                            _headerCell(tt, 'DATE', 2),
                            _headerCell(tt, 'DESCRIPTION', 4),
                            _headerCell(tt, 'AMOUNT', 2),
                            _headerCell(tt, 'STATUS', 2),
                          ],
                        ),
                      ),
                      for (final invoice in list)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm + 4),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  invoice.createdAt == null
                                      ? '—'
                                      : DateFormat('MMM d, y')
                                          .format(invoice.createdAt!),
                                  style: tt.bodyMedium,
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Text(
                                  invoice.description ?? 'Subscription',
                                  style: tt.bodyMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'R${invoice.amount.toStringAsFixed(2)}',
                                  style: tt.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: StatusChip(
                                      status: invoice.status.name),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _headerCell(TextTheme tt, String label, int flex) => Expanded(
        flex: flex,
        child: Text(label,
            style: tt.bodySmall?.copyWith(
                fontWeight: FontWeight.w600, letterSpacing: 0.5)),
      );
}
