import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/models/audit_event.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/relative_time.dart';
import '../providers/notifications_providers.dart';
import '../providers/reports_providers.dart';

/// Notifications & alerts centre: category rail, inbox, operational health.
/// Design: admin_notifications_alerts_center/screen.png.
class AdminNotificationsScreen extends ConsumerWidget {
  const AdminNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(notificationFeedProvider);
    final textTheme = Theme.of(context).textTheme;

    return feed.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('Could not load notifications: $error',
            style:
                textTheme.bodyMedium?.copyWith(color: AppColors.statusError)),
      ),
      data: (all) => LayoutBuilder(builder: (context, constraints) {
        final desktop = constraints.maxWidth > 1100;

        if (desktop) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 260, child: _CategoryRail(all: all)),
              const VerticalDivider(width: 1),
              Expanded(child: _Inbox(all: all)),
              const VerticalDivider(width: 1),
              SizedBox(width: 300, child: _HealthPanel()),
            ],
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _CategoryRail(all: all, compact: true),
              const SizedBox(height: 16),
              _Inbox(all: all, scrollable: false),
            ],
          ),
        );
      }),
    );
  }
}

// --------------------------------------------------------- category rail

class _CategoryRail extends ConsumerWidget {
  const _CategoryRail({required this.all, this.compact = false});

  final List<AuditEvent> all;
  final bool compact;

  static const _categories = [
    ('all', 'All Notifications', Icons.inbox_outlined),
    ('critical', 'Critical Alerts', Icons.error_outline),
    ('operational', 'Operational', Icons.local_shipping_outlined),
    ('system', 'System', Icons.dns_outlined),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(notificationCategoryFilterProvider);

    int unread(String category) => all
        .where((event) =>
            category == 'all' || categoryOf(event) == category)
        .length;

    final rail = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!compact)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Text('Notifications',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                )),
          ),
        for (final (value, label, icon) in _categories)
          _railItem(context, ref, value, label, icon, unread(value),
              selected == value),
      ],
    );

    if (compact) {
      // Mobile: horizontal chip row instead of the navy rail.
      return SizedBox(
        height: 40,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            for (final (value, label, _) in _categories)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text('$label (${unread(value)})'),
                  selected: selected == value,
                  showCheckmark: false,
                  selectedColor: AppColors.navy,
                  labelStyle: TextStyle(
                    color: selected == value
                        ? Colors.white
                        : AppColors.textPrimary,
                  ),
                  onSelected: (_) => ref
                      .read(notificationCategoryFilterProvider.notifier)
                      .set(value),
                ),
              ),
          ],
        ),
      );
    }

    return Container(
      color: AppColors.navy,
      height: double.infinity,
      child: rail,
    );
  }

  Widget _railItem(BuildContext context, WidgetRef ref, String value,
      String label, IconData icon, int count, bool active) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: active ? Colors.white12 : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => ref
              .read(notificationCategoryFilterProvider.notifier)
              .set(value),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 20, color: Colors.white70),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(label,
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight:
                              active ? FontWeight.w600 : FontWeight.w400,
                          color: Colors.white)),
                ),
                if (count > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: value == 'critical'
                          ? AppColors.statusError
                          : AppColors.amber,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text('$count',
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: value == 'critical'
                                ? Colors.white
                                : AppColors.amberDark)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ inbox

class _Inbox extends ConsumerWidget {
  const _Inbox({required this.all, this.scrollable = true});

  final List<AuditEvent> all;
  final bool scrollable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ref.watch(notificationCategoryFilterProvider);
    final oldestFirst = ref.watch(notificationOldestFirstProvider);
    final textTheme = Theme.of(context).textTheme;

    var visible = category == 'all'
        ? [...all]
        : all.where((event) => categoryOf(event) == category).toList();
    if (oldestFirst) visible = visible.reversed.toList();

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('Inbox (${visible.length} items)',
                style: textTheme.headlineSmall),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Latest')),
                ButtonSegment(value: true, label: Text('Oldest')),
              ],
              selected: {oldestFirst},
              showSelectedIcon: false,
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: AppColors.navy,
                selectedForegroundColor: Colors.white,
                visualDensity: VisualDensity.compact,
              ),
              onSelectionChanged: (selection) => ref
                  .read(notificationOldestFirstProvider.notifier)
                  .toggle(selection.first),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (visible.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Text('Nothing here — all clear.',
                style: textTheme.bodyMedium
                    ?.copyWith(color: AppColors.textSecondary)),
          )
        else
          for (final event in visible) _NotificationCard(event: event),
      ],
    );

    if (!scrollable) return content;
    return SingleChildScrollView(
        padding: const EdgeInsets.all(24), child: content);
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.event});

  final AuditEvent event;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final (borderColor, icon) = switch (categoryOf(event)) {
      'critical' => (AppColors.statusError, Icons.warning_amber_rounded),
      'operational' => (AppColors.amberDark, Icons.local_shipping_outlined),
      _ => (AppColors.border, Icons.dns_outlined),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: borderColor, width: 4)),
        boxShadow: const [AppTheme.cardShadow],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: borderColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: borderColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(auditTitle(event),
                          style: textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
                    ),
                    if (event.timestamp != null)
                      Text(relativeTime(event.timestamp!),
                          style: textTheme.bodySmall),
                  ],
                ),
                Text('${event.entityType} · ${event.action.name}',
                    style: textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------- health panel

class _HealthPanel extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final fleet = ref.watch(fleetUtilisationProvider);
    final utilisation =
        fleet.total == 0 ? 0.0 : fleet.onJob / fleet.total;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Operational Health', style: textTheme.titleMedium),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [AppTheme.cardShadow],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Fleet On Job', style: textTheme.bodyMedium),
                    Text('${(utilisation * 100).round()}%',
                        style: textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: utilisation,
                    minHeight: 8,
                    backgroundColor: AppColors.surfaceContainer,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.statusSuccess),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${fleet.onJob} of ${fleet.total} drivers on a job',
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.navy,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Need Assistance?',
                    style: textTheme.titleMedium
                        ?.copyWith(color: Colors.white)),
                const SizedBox(height: 6),
                Text(
                  'Contact our priority 24/7 technical dispatch team for '
                  'immediate breakdown support.',
                  style:
                      textTheme.bodySmall?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Dispatch line: +1 (555) 010-0199')),
                    ),
                    icon: const Icon(Icons.phone, size: 18),
                    label: const Text('Call Dispatch'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
