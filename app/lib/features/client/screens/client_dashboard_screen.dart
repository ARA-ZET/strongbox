import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/enums/app_enums.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadow.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/currency.dart';
import '../../../core/widgets/contact_us_card.dart';
import '../../auth/providers/auth_provider.dart';
import '../../quote/providers/quote_providers.dart';
import '../providers/client_providers.dart';
import '../utils/client_orders.dart';
import '../widgets/new_order_button.dart';
import '../widgets/order_tile.dart';
import 'client_storage_screen.dart';

/// Client home: what needs doing, the numbers that matter, orders in
/// progress and what's where — each a way into the screen behind it.
///
/// A client who has never stored anything gets [_StartOrderCard] instead —
/// build a quote, book the pickup.
class ClientDashboardScreen extends ConsumerWidget {
  const ClientDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final units = ref.watch(myUnitsProvider).valueOrNull;
    // Only once loaded — a returning client shouldn't see a welcome flash.
    final firstOrder = units?.isEmpty ?? false;
    final tt = Theme.of(context).textTheme;

    return LayoutBuilder(builder: (context, constraints) {
      final desktop = constraints.maxWidth > 900;
      final padding = EdgeInsets.all(desktop ? AppSpacing.lg : AppSpacing.md);

      if (firstOrder) {
        return SingleChildScrollView(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome, ${_firstName(user?.name)} 👋',
                  style: tt.displaySmall),
              const SizedBox(height: AppSpacing.xs),
              Text('Let\'s get your first pickup booked.',
                  style: tt.bodyMedium
                      ?.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppSpacing.lg),
              _StartOrderCard(desktop: desktop),
              const SizedBox(height: AppSpacing.lg),
              const ContactUsCard(dense: true),
            ],
          ),
        );
      }

      final inStorage = (units ?? const [])
          .any((unit) => unit.status == StorageStatus.inStorage);

      return SingleChildScrollView(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hello, ${_firstName(user?.name)} 👋',
                        style: tt.displaySmall),
                    const SizedBox(height: AppSpacing.xs),
                    Text('Here\'s what\'s happening with your storage.',
                        style: tt.bodyMedium
                            ?.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
                OrderActions(canReturn: inStorage),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            const _TodoCard(),
            _StatCards(desktop: desktop),
            const SizedBox(height: AppSpacing.lg),
            if (desktop)
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 60, child: _ActiveOrders()),
                  SizedBox(width: AppSpacing.lg),
                  Expanded(flex: 40, child: _StorageSummary()),
                ],
              )
            else ...const [
              _ActiveOrders(),
              SizedBox(height: AppSpacing.lg),
              _StorageSummary(),
            ],
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

// ------------------------------------------------------------- first order

/// New client: the three steps and "Build your quote" — or, with a quote
/// already built (here or on the website), its total and "Book pickup".
class _StartOrderCard extends ConsumerWidget {
  const _StartOrderCard({required this.desktop});

  final bool desktop;

  static const _steps = [
    (
      Icons.calculate_outlined,
      'Build your quote',
      'Add boxes, furniture and loose items — see your monthly price as '
          'you go.',
    ),
    (
      Icons.event_available_outlined,
      'Book a pickup',
      'Choose a date, time window and the address we collect from.',
    ),
    (
      Icons.inventory_2_outlined,
      'We collect & store',
      'Track every item in My Storage and ask for anything back, any time.',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totals = ref.watch(quoteTotalsProvider);
    final tt = Theme.of(context).textTheme;

    Widget step(int index) {
      final (icon, title, body) = _steps[index];
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.skyTint,
              borderRadius: AppRadius.md,
            ),
            child: Icon(icon, color: AppColors.accentDeep, size: 22),
          ),
          const SizedBox(width: AppSpacing.sm + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${index + 1}. $title', style: tt.titleMedium),
                const SizedBox(height: 2),
                Text(body, style: tt.bodySmall),
              ],
            ),
          ),
        ],
      );
    }

    final buttonStyle = ElevatedButton.styleFrom(
      minimumSize: const Size(0, 48),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.md,
        boxShadow: AppShadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Start your first order', style: tt.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text('Pay per item, per month. No contract, no minimum term.',
              style:
                  tt.bodyMedium?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.lg),
          if (desktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < _steps.length; i++) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.lg),
                  Expanded(child: step(i)),
                ],
              ],
            )
          else
            for (var i = 0; i < _steps.length; i++) ...[
              if (i > 0) const SizedBox(height: AppSpacing.md),
              step(i),
            ],
          const SizedBox(height: AppSpacing.lg),
          if (totals.isEmpty)
            ElevatedButton.icon(
              style: buttonStyle,
              onPressed: () => context.go('/client/order'),
              icon: const Icon(Icons.add),
              label: const Text('Build your quote'),
            )
          else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: const BoxDecoration(
                color: AppColors.skyTint,
                borderRadius: AppRadius.md,
              ),
              child: Text(
                'Your quote: ${totals.itemCount} '
                '${totals.itemCount == 1 ? 'item' : 'items'} · '
                '${formatZar(totals.monthlyZar)}/month'
                '${totals.vehicle == null ? '' : ' + ${formatZar(totals.pickupZar)} pickup'}',
                style: tt.titleMedium?.copyWith(color: AppColors.accentDeep),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm + 4,
              runSpacing: AppSpacing.sm + 4,
              children: [
                ElevatedButton.icon(
                  style: buttonStyle,
                  onPressed: () => context.go('/client/order/book'),
                  icon: const Icon(Icons.local_shipping_outlined),
                  label: const Text('Book pickup'),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  ),
                  onPressed: () => context.go('/client/order'),
                  child: const Text('Edit quote'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Section heading with an optional "View all"-style link.
class _Heading extends StatelessWidget {
  const _Heading(this.title, {this.link, this.route});

  final String title;
  final String? link;
  final String? route;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(child: Text(title, style: tt.headlineSmall)),
          if (link != null && route != null)
            TextButton.icon(
              onPressed: () => context.go(route!),
              iconAlignment: IconAlignment.end,
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: Text(link!),
            ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------- to do

class _TodoCard extends ConsumerWidget {
  const _TodoCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(myTodosProvider);
    if (todos.isEmpty) return const SizedBox.shrink();
    final tt = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.md,
        boxShadow: AppShadow.card,
        border: const Border(
            left: BorderSide(color: AppColors.accent, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('To do', style: tt.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          for (final todo in todos) _TodoRow(todo: todo),
        ],
      ),
    );
  }
}

class _TodoRow extends StatelessWidget {
  const _TodoRow({required this.todo});

  final ClientTodo todo;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final icon = switch (todo.kind) {
      TodoKind.live => Icons.local_shipping_outlined,
      TodoKind.invoice => Icons.receipt_long_outlined,
      TodoKind.packing => Icons.inventory_2_outlined,
    };
    final (bg, fg) = todo.urgent
        ? (AppColors.statusErrorBg, AppColors.statusError)
        : (AppColors.skyTint, AppColors.accentDeep);

    return InkWell(
      borderRadius: AppRadius.sm,
      onTap: () => context.go(todo.route),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: bg, borderRadius: AppRadius.sm),
              child: Icon(icon, color: fg, size: 22),
            ),
            const SizedBox(width: AppSpacing.sm + 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(todo.title, style: tt.titleSmall),
                  Text(todo.detail, style: tt.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------- stat cards

class _StatCards extends ConsumerWidget {
  const _StatCards({required this.desktop});

  final bool desktop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final units = ref.watch(myUnitsProvider).valueOrNull ?? const [];
    final jobs = ref.watch(myJobsProvider).valueOrNull ?? const [];
    final invoices = ref.watch(myInvoicesProvider).valueOrNull ?? const [];
    final bill = ref.watch(myStorageBillProvider);
    final tt = Theme.of(context).textTheme;

    final stored = units
        .where((u) =>
            u.status == StorageStatus.inStorage ||
            u.status == StorageStatus.pendingDelivery)
        .length;
    final awaiting =
        units.where((u) => u.status == StorageStatus.pendingPickup).length;
    final active = activeOrders(jobs);
    final next = active
        .map((job) => job.scheduledDate)
        .whereType<DateTime>()
        .firstOrNull;
    final balance = balanceDue(invoices, DateTime.now());
    final day = DateFormat('EEE d MMM');

    Widget card({
      required String label,
      required String value,
      required String caption,
      required IconData icon,
      required String route,
      bool alert = false,
    }) {
      return Material(
        color: AppColors.surface,
        borderRadius: AppRadius.md,
        child: InkWell(
          borderRadius: AppRadius.md,
          onTap: () => context.go(route),
          child: Ink(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: const BoxDecoration(
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
                    Icon(icon, size: 18, color: AppColors.accentDeep),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(value,
                    style: tt.headlineSmall?.copyWith(
                        color: alert ? AppColors.statusError : null),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: AppSpacing.xs),
                Text(caption,
                    style: tt.bodySmall?.copyWith(
                        color: alert ? AppColors.statusError : null),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ),
      );
    }

    final cards = [
      card(
        label: 'In storage',
        value: '$stored',
        caption: awaiting > 0 ? '+ $awaiting awaiting pickup' : 'boxes & items',
        icon: Icons.inventory_2_outlined,
        route: '/client/storage?status=inStorage',
      ),
      card(
        label: 'Monthly storage',
        value: formatZar(bill.monthlyZar),
        caption: 'Billed on the 1st',
        icon: Icons.calendar_month_outlined,
        route: '/client/subscription',
      ),
      card(
        label: 'Active orders',
        value: '${active.length}',
        caption: next == null ? 'None scheduled' : 'Next: ${day.format(next)}',
        icon: Icons.local_shipping_outlined,
        route: '/client/orders',
      ),
      card(
        label: 'Balance due',
        value: formatZarExact(balance.due),
        caption: balance.overdue
            ? 'Overdue — please pay'
            : balance.due > 0 && balance.nextDue != null
                ? 'Due ${day.format(balance.nextDue!)}'
                : 'All paid up',
        icon: Icons.receipt_long_outlined,
        route: '/client/subscription',
        alert: balance.overdue,
      ),
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
      childAspectRatio: 1.45,
      children: cards,
    );
  }
}

// ----------------------------------------------------------- active orders

class _ActiveOrders extends ConsumerWidget {
  const _ActiveOrders();

  static const _shown = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobs = ref.watch(myJobsProvider).valueOrNull ?? const [];
    final active = activeOrders(jobs);
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Heading(
          'Active orders',
          link: active.length > _shown
              ? 'All ${active.length}'
              : 'All orders',
          route: '/client/orders',
        ),
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
              'Nothing on the move right now. Store more items or get '
              'something back with the buttons above.',
              style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          )
        else
          for (final job in active.take(_shown)) OrderTile(job: job),
      ],
    );
  }
}

// --------------------------------------------------------- storage summary

/// How many units are at each stage, each row opening My Storage filtered
/// to that stage.
class _StorageSummary extends ConsumerWidget {
  const _StorageSummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final units = ref.watch(myUnitsProvider).valueOrNull ?? const [];
    final tt = Theme.of(context).textTheme;
    final counts = <String, int>{};
    for (final unit in units) {
      counts.update(unit.status.name, (n) => n + 1, ifAbsent: () => 1);
    }
    final rows = [
      for (final (status, label) in ClientStorageScreen.filters)
        if (status != 'all' && (counts[status] ?? 0) > 0)
          (status, label, counts[status]!),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Heading('My storage',
            link: 'Browse all', route: '/client/storage'),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.md,
            boxShadow: AppShadow.card,
          ),
          child: rows.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Text('Nothing in storage right now.',
                      style: tt.bodyMedium
                          ?.copyWith(color: AppColors.textSecondary)),
                )
              : Column(
                  children: [
                    for (final (index, (status, label, count))
                        in rows.indexed) ...[
                      if (index > 0) const Divider(height: 1),
                      InkWell(
                        onTap: () =>
                            context.go('/client/storage?status=$status'),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.sm + 4),
                          child: Row(
                            children: [
                              Expanded(
                                  child: Text(label, style: tt.bodyMedium)),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm + 2,
                                    vertical: 2),
                                decoration: const BoxDecoration(
                                  color: AppColors.skyTint,
                                  borderRadius: AppRadius.pill,
                                ),
                                child: Text('$count',
                                    style: tt.labelLarge?.copyWith(
                                        color: AppColors.accentDeep)),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              const Icon(Icons.chevron_right,
                                  color: AppColors.textHint),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}
