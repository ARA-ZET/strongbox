import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/enums/app_enums.dart';
import '../../../core/models/client.dart';
import '../../../core/models/job.dart';
import 'clients_providers.dart';
import 'fleet_providers.dart';
import 'jobs_providers.dart';

part 'reports_providers.g.dart';

/// Flat demo tariff (Rand) used for estimated revenue until Stripe lands.
const double estimatedFeePerJob = 550.0;

/// One bar on the Monthly Job Volume chart.
class MonthVolume {
  const MonthVolume({
    required this.label,
    required this.completed,
    required this.total,
  });
  final String label;
  final int completed;
  final int total;
}

const _monthNames = [
  'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
  'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC', //
];

/// Jobs per month for the last six months.
@riverpod
List<MonthVolume> monthlyJobVolume(Ref ref) {
  final jobs = ref.watch(allJobsProvider).valueOrNull ?? const <Job>[];
  final now = DateTime.now();
  final months = List.generate(6, (i) {
    final m = DateTime(now.year, now.month - 5 + i);
    return (m.year, m.month);
  });

  return months.map((key) {
    final inMonth = jobs.where((j) =>
        j.scheduledDate != null &&
        j.scheduledDate!.year == key.$1 &&
        j.scheduledDate!.month == key.$2);
    return MonthVolume(
      label: _monthNames[key.$2 - 1],
      completed:
          inMonth.where((j) => j.status == JobStatus.completed).length,
      total: inMonth.length,
    );
  }).toList();
}

/// Estimated revenue from completed jobs.
@riverpod
double estimatedRevenue(Ref ref) {
  final jobs = ref.watch(allJobsProvider).valueOrNull ?? const <Job>[];
  return jobs.where((j) => j.status == JobStatus.completed).length *
      estimatedFeePerJob;
}

/// Fleet utilisation: drivers on a job / total drivers.
@riverpod
({int total, int onJob}) fleetUtilisation(Ref ref) {
  final drivers = ref.watch(driverUsersProvider).valueOrNull ?? const [];
  final active = ref.watch(activeJobsByDriverProvider);
  final onJob = drivers.where((d) => active.containsKey(d.id)).length;
  return (total: drivers.length, onJob: onJob);
}

/// A Top Clients table row.
class ClientVolumeRow {
  const ClientVolumeRow({
    required this.client,
    required this.jobsMtd,
    required this.estRevenue,
  });
  final Client client;
  final int jobsMtd;
  final double estRevenue;
}

/// Clients ranked by units stored, with month-to-date job counts.
@riverpod
List<ClientVolumeRow> topClientsByVolume(Ref ref) {
  final clients = ref.watch(clientsProvider).valueOrNull ?? const [];
  final jobs = ref.watch(allJobsProvider).valueOrNull ?? const <Job>[];
  final now = DateTime.now();

  final sorted = [...clients]
    ..sort((a, b) => b.storageUnitCount.compareTo(a.storageUnitCount));
  return sorted.take(5).map((client) {
    final clientJobs = jobs.where((j) => j.clientId == client.id).toList();
    final mtd = clientJobs
        .where((j) =>
            j.scheduledDate != null &&
            j.scheduledDate!.year == now.year &&
            j.scheduledDate!.month == now.month)
        .length;
    final completed =
        clientJobs.where((j) => j.status == JobStatus.completed).length;
    return ClientVolumeRow(
      client: client,
      jobsMtd: mtd,
      estRevenue: completed * estimatedFeePerJob,
    );
  }).toList();
}
