import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/enums/app_enums.dart';
import '../../admin/providers/inventory_providers.dart';
import '../../auth/providers/auth_provider.dart';
import '../../client/providers/client_providers.dart';
import '../../driver/providers/driver_jobs_providers.dart';

part 'scan_link_providers.g.dart';

/// Where a label link (`/s/:code`, opened by a phone's own camera) takes
/// the signed-in user — [route] — or why it can't, [message].
typedef ScanLinkTarget = ({String? route, String message});

/// Admins go to the unit; clients to the unit only when it's theirs;
/// drivers to the active job carrying it, only when the job is theirs.
@riverpod
Future<ScanLinkTarget> scanLinkTarget(Ref ref, String code) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) {
    return (route: null, message: 'Sign in to open this label.');
  }
  const notLinked = 'This label isn\'t linked to a box or item yet.';

  switch (user.role) {
    case UserRole.client:
      final units = await ref.watch(myUnitsProvider.future);
      final unit = units.where((u) => u.qrCodeId == code).firstOrNull;
      return unit == null
          ? (route: null, message: 'This label isn\'t on your account.')
          : (route: '/client/storage/${unit.id}', message: '');

    case UserRole.admin:
      final unit = await ref.watch(unitByQrCodeProvider(code).future);
      return unit == null
          ? (
              route: null,
              message: '$notLinked Link it in QR Management.',
            )
          : (route: '/admin/inventory/${unit.id}', message: '');

    case UserRole.driver:
      final unit = await ref.watch(unitByScanProvider(code).future);
      if (unit == null) return (route: null, message: notLinked);
      final jobId = unit.jobId;
      if (jobId != null) {
        final job = await ref.watch(driverJobProvider(jobId).future);
        final active = job != null &&
            job.status != JobStatus.completed &&
            job.status != JobStatus.cancelled;
        if (active && job.driverId == user.id) {
          return (route: '/driver/jobs/$jobId', message: '');
        }
      }
      return (
        route: null,
        message: 'This label isn\'t on any of your current jobs.',
      );
  }
}
