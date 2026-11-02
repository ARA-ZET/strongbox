import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strong_box/core/models/job.dart';
import 'package:strong_box/features/admin/providers/jobs_providers.dart';
import 'package:strong_box/features/auth/providers/auth_provider.dart';
import 'package:strong_box/repositories/job_repository.dart';
import 'package:strong_box/repositories/repository_providers.dart';

/// Firestore stand-in: the assign write takes a network-ish pause.
class _SlowJobs implements JobRepository {
  final assigned = <String, String>{};

  @override
  Future<void> assignDriver(Job job, String driverId,
      {required String actorId, String? driverName, String? fleetVehicleId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    assigned[job.id] = driverId;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  // Screens only call `.notifier.assignDriver(...)` — nothing listens to
  // the provider while the write runs.
  test('assigning a driver completes though nothing listens while it runs',
      () async {
    final jobs = _SlowJobs();
    final container = ProviderContainer(overrides: [
      jobRepositoryProvider.overrideWithValue(jobs),
      authStateProvider.overrideWith((ref) => Stream<User?>.value(null)),
    ]);
    addTearDown(container.dispose);

    await container.read(jobMutationsProvider.notifier).assignDriver(
        const Job(id: 'job-1', tenantId: 'strongbox-default', clientId: 'c1'),
        'driver-1');

    expect(jobs.assigned, {'job-1': 'driver-1'});
  });
}
