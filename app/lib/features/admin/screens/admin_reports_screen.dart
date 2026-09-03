import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../providers/reports_providers.dart';

/// Reports & analytics dashboard: job volume bars, revenue, fleet
/// efficiency, top clients. Design: admin_reports_analytics_dashboard.
class AdminReportsScreen extends ConsumerWidget {
  const AdminReportsScreen({super.key});

  Future<void> _exportCsv(BuildContext context, WidgetRef ref) async {
    final rows = ref.read(topClientsByVolumeProvider);
    final volume = ref.read(monthlyJobVolumeProvider);

    final buffer = StringBuffer()
      ..writeln('Monthly Job Volume')
      ..writeln('Month,Completed,Total');
    for (final month in volume) {
      buffer.writeln('${month.label},${month.completed},${month.total}');
    }
    buffer
      ..writeln()
      ..writeln('Top Clients by Volume')
      ..writeln('Client,Boxes Stored,Jobs MTD,Est Revenue');
    for (final row in rows) {
      buffer.writeln(
          '${row.client.displayName},${row.client.storageUnitCount},${row.jobsMtd},${row.estRevenue.toStringAsFixed(2)}');
    }

    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('CSV copied to clipboard — paste into a sheet')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(builder: (context, constraints) {
      final desktop = constraints.maxWidth > 900;

      return SingleChildScrollView(
        padding: EdgeInsets.all(desktop ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('Reports & Analytics', style: textTheme.displaySmall),
                const Spacer(),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onPressed: () => _exportCsv(context, ref),
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('Export CSV'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('Operational overview across the last six months.',
                style: textTheme.bodyMedium
                    ?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            if (desktop)
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 60, child: _VolumeChartCard()),
                  SizedBox(width: 24),
                  Expanded(flex: 40, child: _RevenueCard()),
                ],
              )
            else ...const [
              _VolumeChartCard(),
              SizedBox(height: 24),
              _RevenueCard(),
            ],
            const SizedBox(height: 24),
            if (desktop)
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 35, child: _FleetEfficiencyCard()),
                  SizedBox(width: 24),
                  Expanded(flex: 65, child: _TopClientsCard()),
                ],
              )
            else ...const [
              _FleetEfficiencyCard(),
              SizedBox(height: 24),
              _TopClientsCard(),
            ],
          ],
        ),
      );
    });
  }
}

// ------------------------------------------------------------ volume bars

class _VolumeChartCard extends ConsumerWidget {
  const _VolumeChartCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final volume = ref.watch(monthlyJobVolumeProvider);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(24),
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
              Text('Monthly Job Volume', style: textTheme.titleMedium),
              Row(
                children: [
                  _legendDot(AppColors.amber, 'Completed', textTheme),
                  const SizedBox(width: 12),
                  _legendDot(const Color(0xFFFCE8C6), 'All Jobs', textTheme),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 240,
            child: AsyncData(volume).when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text('Could not load chart: $error',
                    style: textTheme.bodyMedium
                        ?.copyWith(color: AppColors.statusError)),
              ),
              data: (months) {
                final maxY = months
                    .fold<int>(0, (max, month) =>
                        month.total > max ? month.total : max)
                    .toDouble();
                return BarChart(
                  BarChartData(
                    maxY: maxY < 5 ? 5 : maxY * 1.2,
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem:
                            (group, groupIndex, rod, rodIndex) =>
                                BarTooltipItem(
                          '${rod.toY.round()} jobs',
                          const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(),
                      topTitles: const AxisTitles(),
                      rightTitles: const AxisTitles(),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= months.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(months[index].label,
                                  style: textTheme.bodySmall),
                            );
                          },
                        ),
                      ),
                    ),
                    barGroups: [
                      for (final (index, month) in months.indexed)
                        BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: month.total.toDouble(),
                              width: 18,
                              color: const Color(0xFFFCE8C6),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            BarChartRodData(
                              toY: month.completed.toDouble(),
                              width: 18,
                              color: AppColors.amber,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label, TextTheme textTheme) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: textTheme.bodySmall),
      ],
    );
  }
}

// --------------------------------------------------------------- revenue

class _RevenueCard extends ConsumerWidget {
  const _RevenueCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final revenue = ref.watch(estimatedRevenueProvider);
    final volume = ref.watch(monthlyJobVolumeProvider);
    final textTheme = Theme.of(context).textTheme;
    final currency = NumberFormat.currency(symbol: 'R', decimalDigits: 0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Revenue (Estimated)',
              style: textTheme.titleMedium?.copyWith(color: Colors.white)),
          const SizedBox(height: 16),
          Text(
            currency.format(revenue),
            style: textTheme.displaySmall
                ?.copyWith(color: Colors.white, fontSize: 36),
          ),
          Text('From completed jobs at the standard tariff',
              style: textTheme.bodySmall?.copyWith(color: Colors.white54)),
          const SizedBox(height: 24),
          SizedBox(height: 90, child: _miniBars(volume)),
        ],
      ),
    );
  }

  /// Sparkline-style bars of completed jobs per month; latest bar
  /// highlighted, heights normalised against the busiest month.
  Widget _miniBars(List<MonthVolume> volume) {
    if (volume.isEmpty) return const SizedBox.shrink();
    final peak = volume
        .map((month) => month.completed)
        .fold<int>(1, (max, value) => value > max ? value : max);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final (index, month) in volume.indexed) ...[
          if (index > 0) const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 12 + 78.0 * (month.completed / peak),
              decoration: BoxDecoration(
                color: index == volume.length - 1
                    ? const Color(0xFFAEB9E1)
                    : Colors.white24,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ------------------------------------------------------- fleet efficiency

class _FleetEfficiencyCard extends ConsumerWidget {
  const _FleetEfficiencyCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fleet = ref.watch(fleetUtilisationProvider);
    final textTheme = Theme.of(context).textTheme;
    final utilisation = fleet.total == 0
        ? 0.0
        : fleet.onJob / fleet.total;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [AppTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Fleet Efficiency', style: textTheme.titleMedium),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: utilisation,
                    strokeWidth: 14,
                    backgroundColor: AppColors.surfaceContainer,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.amber),
                    strokeCap: StrokeCap.round,
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${(utilisation * 100).round()}%',
                            style: textTheme.displaySmall),
                        Text('Utilization', style: textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Drivers On Job', style: textTheme.bodySmall),
                    Text(
                      '${fleet.onJob}/${fleet.total}',
                      style: textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Available', style: textTheme.bodySmall),
                    Text(
                      '${fleet.total - fleet.onJob}',
                      style: textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------ top clients

class _TopClientsCard extends ConsumerWidget {
  const _TopClientsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = ref.watch(topClientsByVolumeProvider);
    final textTheme = Theme.of(context).textTheme;
    final currency = NumberFormat.currency(symbol: 'R', decimalDigits: 0);

    Widget headerCell(String label, {required int flex}) => Expanded(
          flex: flex,
          child: Text(label,
              style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [AppTheme.cardShadow],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                    child: Text('Top Clients by Volume',
                        style: textTheme.titleMedium)),
              ],
            ),
          ),
          AsyncData(rows).when(
            loading: () => const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Text('Could not load clients: $error',
                  style: textTheme.bodyMedium
                      ?.copyWith(color: AppColors.statusError)),
            ),
            data: (list) => list.isEmpty
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Text('No client volume yet.',
                        style: textTheme.bodyMedium
                            ?.copyWith(color: AppColors.textSecondary)),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 560),
                      child: Column(
                        children: [
                          Container(
                            color: AppColors.surfaceContainer,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            child: Row(
                              children: [
                                headerCell('CLIENT NAME', flex: 4),
                                headerCell('BOXES STORED', flex: 2),
                                headerCell('JOBS (MTD)', flex: 2),
                                headerCell('EST. REVENUE', flex: 2),
                              ],
                            ),
                          ),
                          for (final row in list)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Row(
                                      children: [
                                        InitialsAvatar(
                                            name: row.client.displayName,
                                            size: 32),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(row.client.displayName,
                                              style: textTheme.bodyMedium
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w600),
                                              maxLines: 1,
                                              overflow:
                                                  TextOverflow.ellipsis),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text('${row.client.storageUnitCount}',
                                        style: textTheme.bodyMedium),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text('${row.jobsMtd}',
                                        style: textTheme.bodyMedium),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                        currency.format(row.estRevenue),
                                        style: textTheme.bodyMedium
                                            ?.copyWith(
                                                fontWeight:
                                                    FontWeight.w600)),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
