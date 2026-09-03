import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/app_enums.dart';
import '../utils/timestamp_converter.dart';

part 'storage_unit.freezed.dart';
part 'storage_unit.g.dart';

/// A physical container in the storage system (doc 03) — was `BoxModel`.
@freezed
class StorageUnit with _$StorageUnit {
  const factory StorageUnit({
    required String id,
    required String tenantId,
    required String clientId,
    @Default('') String qrCodeId,
    String? parentId,
    @Default(UnitType.closed) UnitType type,
    @Default('') String label,
    String? description,
    @Default(StorageStatus.pendingPickup) StorageStatus status,
    @Default([]) List<String> photoIds,
    @Default([]) List<String> tags,
    String? category,
    double? weight,
    String? jobId,
    String? warehouseLocationId,
    @Default(false) bool isDeleted,
    @NullableTimestampConverter() DateTime? deletedAt,
    @NullableTimestampConverter() DateTime? createdAt,
    @NullableTimestampConverter() DateTime? updatedAt,
  }) = _StorageUnit;

  factory StorageUnit.fromJson(Map<String, dynamic> json) =>
      _$StorageUnitFromJson(json);

  factory StorageUnit.fromFirestore(DocumentSnapshot doc) =>
      StorageUnit.fromJson(
          {...doc.data()! as Map<String, dynamic>, 'id': doc.id});
}
