import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/storage_paths.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/providers/tenant_provider.dart';
import '../../../repositories/repository_providers.dart';
import '../../auth/providers/auth_provider.dart';

part 'issue_report_providers.g.dart';

/// Submits maintenance/support reports from the driver.
@riverpod
class IssueReportActions extends _$IssueReportActions {
  @override
  FutureOr<void> build() {}

  Future<void> submit({
    required IssueType issueType,
    required String description,
    required bool isUrgent,
    List<Uint8List> photos = const [],
  }) async {
    final tenantId = ref.read(currentTenantIdProvider);
    final driverId = ref.read(currentActorIdProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final issueRepo = ref.read(issueRepositoryProvider);
      final photoRepo = ref.read(photoRepositoryProvider);

      // Reserve the report id via an empty create so photos can attach to it,
      // then create with the resolved photo ids.
      final photoIds = <String>[];
      // Upload photos under a timestamped path; entityId set to driver until
      // the report id exists (metadata only — display uses the report doc).
      for (final bytes in photos) {
        final name = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        photoIds.add(await photoRepo.upload(
          tenantId: tenantId,
          bytes: bytes,
          type: PhotoType.driverCapture,
          entityType: 'issueReport',
          entityId: driverId,
          storagePath: StoragePaths.issuePhoto(tenantId, driverId, name),
          uploadedBy: driverId,
        ));
      }

      await issueRepo.create(
        tenantId: tenantId,
        driverId: driverId,
        issueType: issueType,
        description: description,
        photoIds: photoIds,
        isUrgent: isUrgent,
      );
    });
  }
}
