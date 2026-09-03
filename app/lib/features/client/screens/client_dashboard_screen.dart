import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/models/item.dart';
import '../../../core/models/storage_unit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadow.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/contact_us_card.dart';
import '../../../core/widgets/status_chip.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/client_providers.dart';

/// Client home. Design: client_designs/client_dashboard/screen.png.
class ClientDashboardScreen extends ConsumerWidget {
  const ClientDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final tt = Theme.of(context).textTheme;

    return LayoutBuilder(builder: (context, constraints) {
      final desktop = constraints.maxWidth > 900;

      final main = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hello, ${_firstName(user?.name)} 👋',
              style: tt.displaySmall),
          const SizedBox(height: AppSpacing.xs),
          Text('Your belongings are safe.',
              style:
                  tt.bodyMedium?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.lg),
          _StatCards(desktop: desktop),
          const SizedBox(height: AppSpacing.lg),
          const _ActionRow(),
          const SizedBox(height: AppSpacing.lg),
          const _YourStorageSection(),
          const SizedBox(height: AppSpacing.lg),
          const _LooseItemsSection(),
        ],
      );

      const rail = _RightRail();

      return SingleChildScrollView(
        padding: EdgeInsets.all(desktop ? AppSpacing.lg : AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            desktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 65, child: main),
                      const SizedBox(width: AppSpacing.lg),
                      const Expanded(flex: 35, child: rail),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      main,
                      const SizedBox(height: AppSpacing.lg),
                      rail
                    ],
                  ),
            const SizedBox(height: AppSpacing.lg),
            const ContactUsCard(dense: true),
          ],
        ),
      );
    });
  }

  String _firstName(String? name) {
    final trimmed = name?.trim() ?? '';
    if (trimmed.isEmpty) return 'there';
    return trimmed.split(RegExp(r'\s+')).first;
  }
}

// -------------------------------------------------------------- stat cards

class _StatCards extends ConsumerWidget {
  const _StatCards({required this.desktop});

  final bool desktop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(currentClientProvider).valueOrNull;
    final units = ref.watch(myUnitsProvider).valueOrNull ?? const [];
    final items = ref.watch(myItemsProvider).valueOrNull ?? const [];
    final tt = Theme.of(context).textTheme;

    final plan = client?.subscriptionPlan ?? SubscriptionPlan.starter;
    final price = AppConstants.planPricesZar[plan.name] ?? 0;
    final active = units
        .where((unit) => unit.status != StorageStatus.archived)
        .toList();
    final priceLabel = price == 0
        ? 'Custom'
        : 'R${NumberFormat.decimalPattern().format(price)}';

    Widget card(String label, String value,
        {Widget? chip, String? caption, IconData? icon}) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.md,
          boxShadow: AppShadow.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(label,
                      style: tt.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
                if (icon != null)
                  Icon(icon, size: 18, color: AppColors.amberDark),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(value,
                style: tt.headlineSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: AppSpacing.sm),
            if (chip != null)
              chip
            else if (caption != null)
              Text(caption,
                  style: tt.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
          ],
        ),
      );
    }

    final cards = [
      card(
        'Monthly Storage',
        priceLabel,
        chip: StatusChip(
            status: (client?.subscriptionStatus ?? SubscriptionStatus.active)
                .name),
      ),
      card(
        'Items in Storage',
        '${active.length + items.length}',
        caption: '${active.length} units + ${items.length} items',
      ),
      card('Next Billing', '—',
          caption: 'Goes live with billing', icon: Icons.calendar_today),
      card('Balance', 'R0.00',
          chip: const StatusChip(status: 'paid'), icon: Icons.receipt_long),
    ];

    if (desktop) {
      return Row(
        children: [
          for (final (index, card) in cards.indexed) ...[
            if (index > 0) const SizedBox(width: AppSpacing.md),
            Expanded(child: card),
          ],
        ],
      );
    }
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.sm + 4,
      crossAxisSpacing: AppSpacing.sm + 4,
      childAspectRatio: 1.5,
      children: cards,
    );
  }
}

// -------------------------------------------------------------- action row

class _ActionRow extends StatelessWidget {
  const _ActionRow();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm + 4,
      runSpacing: AppSpacing.sm + 4,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(0, 48),
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          ),
          onPressed: () => context.go('/client/requests/new'),
          child: const Text('Request Delivery'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.navy,
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 48),
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          ),
          onPressed: () => context.go('/client/deliveries'),
          child: const Text('My Deliveries'),
        ),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 48),
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          ),
          onPressed: () => context.go('/client/storage'),
          child: const Text('View Inventory'),
        ),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 48),
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          ),
          onPressed: () => context.go('/client/subscription'),
          child: const Text('Invoices'),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------ your storage

class _YourStorageSection extends ConsumerWidget {
  const _YourStorageSection();

  static const _categoryIcons = <String, IconData>{
    'kitchen': Icons.kitchen_outlined,
    'books': Icons.menu_book_outlined,
    'clothes': Icons.checkroom_outlined,
    'garage': Icons.build_outlined,
    'office': Icons.work_outline,
    'electronics': Icons.devices_other_outlined,
    'documents': Icons.description_outlined,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final units = ref.watch(myUnitsProvider).valueOrNull ?? const [];
    final tt = Theme.of(context).textTheme;

    final active = units
        .where((unit) => unit.status != StorageStatus.archived)
        .toList();

    // Group by category; uncategorised units fall under "General".
    final groups = <String, List<StorageUnit>>{};
    for (final unit in active) {
      final key = (unit.category?.trim().isNotEmpty ?? false)
          ? unit.category!.trim()
          : 'General';
      groups.putIfAbsent(key, () => []).add(unit);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text('Your Storage', style: tt.headlineSmall)),
            TextButton(
              onPressed: () => context.go('/client/storage'),
              child: const Text('View All →'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (active.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.md,
              boxShadow: AppShadow.card,
            ),
            child: Text(
              'You have no items in storage yet. Request a quote to '
              'arrange your first pickup.',
              style:
                  tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          )
        else
          LayoutBuilder(builder: (context, constraints) {
            final columns = constraints.maxWidth > 560 ? 2 : 1;
            final entries = groups.entries.toList();
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: AppSpacing.sm + 4,
                crossAxisSpacing: AppSpacing.sm + 4,
                mainAxisExtent: 68,
              ),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                final icon = _categoryIcons[entry.key.toLowerCase()] ??
                    Icons.inventory_2_outlined;
                return InkWell(
                  onTap: () => context.go('/client/storage'),
                  borderRadius: AppRadius.md,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.md,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(icon, color: AppColors.amberDark),
                        const SizedBox(width: AppSpacing.sm + 4),
                        Expanded(
                          child: Text(entry.key,
                              style: tt.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm + 2, vertical: 4),
                          decoration: const BoxDecoration(
                            color: AppColors.statusWarningBg,
                            borderRadius: AppRadius.pill,
                          ),
                          child: Text(
                            '${entry.value.length} '
                            'unit${entry.value.length == 1 ? '' : 's'}',
                            style: tt.bodySmall
                                ?.copyWith(color: AppColors.amberDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
      ],
    );
  }
}

// ------------------------------------------------------------- loose items

class _LooseItemsSection extends ConsumerWidget {
  const _LooseItemsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(myItemsProvider).valueOrNull ?? const <Item>[];
    final tt = Theme.of(context).textTheme;
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Loose Items', style: tt.headlineSmall),
        const SizedBox(height: AppSpacing.sm + 4),
        LayoutBuilder(builder: (context, constraints) {
          final columns = constraints.maxWidth > 700
              ? 4
              : constraints.maxWidth > 420
                  ? 2
                  : 1;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: AppSpacing.sm + 4,
              crossAxisSpacing: AppSpacing.sm + 4,
              mainAxisExtent: 130,
            ),
            itemCount: items.length.clamp(0, 8),
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.md,
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.category_outlined,
                        color: AppColors.navy, size: 28),
                    const SizedBox(height: AppSpacing.sm),
                    Text(item.label,
                        style: tt.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: AppSpacing.xs),
                    StatusChip(status: item.status.name),
                  ],
                ),
              );
            },
          );
        }),
      ],
    );
  }
}

// -------------------------------------------------------------- right rail

class _RightRail extends ConsumerWidget {
  const _RightRail();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final delivery = ref.watch(activeDeliveryProvider);
    final client = ref.watch(currentClientProvider).valueOrNull;
    final units = ref.watch(myUnitsProvider).valueOrNull ?? const [];
    final tt = Theme.of(context).textTheme;

    final inStorage =
        units.where((u) => u.status == StorageStatus.inStorage).length;
    final plan = client?.subscriptionPlan ?? SubscriptionPlan.starter;
    final limit = AppConstants.planUnitLimits[plan.name] ?? 0;
    final fraction =
        limit > 0 ? (inStorage / limit).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (delivery != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.md,
              border: const Border(
                  left: BorderSide(color: AppColors.amberDark, width: 4)),
              boxShadow: AppShadow.card,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_shipping_outlined,
                        color: AppColors.amberDark),
                    const SizedBox(width: AppSpacing.sm + 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Delivering: ${delivery.storageUnitIds.length} '
                            'unit${delivery.storageUnitIds.length == 1 ? '' : 's'}',
                            style: tt.titleMedium,
                          ),
                          if (delivery.scheduledDate != null)
                            Text(
                              DateFormat('EEE d MMM')
                                  .format(delivery.scheduledDate!),
                              style: tt.bodySmall,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm + 4),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go('/client/deliveries'),
                    child: const Text('Track'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.md,
            boxShadow: AppShadow.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Storage Snapshot', style: tt.titleMedium),
              const SizedBox(height: AppSpacing.sm + 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    limit > 0 ? '$inStorage / $limit units' : '$inStorage units',
                    style: tt.bodyMedium,
                  ),
                  if (limit > 0)
                    Text('${(fraction * 100).round()}% Full',
                        style: tt.labelLarge
                            ?.copyWith(color: AppColors.amberDark)),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: AppRadius.pill,
                child: LinearProgressIndicator(
                  value: fraction,
                  minHeight: 8,
                  backgroundColor: AppColors.surfaceContainer,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.amber),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text('${units.length} units total', style: tt.bodySmall),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: const BoxDecoration(
            color: AppColors.navy,
            borderRadius: AppRadius.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Need more space?',
                  style: tt.titleMedium?.copyWith(color: Colors.white)),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Upgrade your plan for a bigger allowance and priority '
                'retrieval.',
                style: tt.bodySmall?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: AppSpacing.sm + 4),
              TextButton.icon(
                style:
                    TextButton.styleFrom(foregroundColor: AppColors.amber),
                onPressed: () => context.go('/client/subscription'),
                icon: const Text('View Plans'),
                label: const Icon(Icons.arrow_forward, size: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
