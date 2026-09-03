import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/app_enums.dart';
import '../utils/timestamp_converter.dart';

part 'item.freezed.dart';
part 'item.g.dart';

/// An individual catalogued item inside an open storage unit (doc 03).
@freezed
class Item with _$Item {
  const factory Item({
    required String id,
    required String tenantId,
    required String storageUnitId,
    required String clientId,
    @Default('') String qrCodeId,
    @Default('') String label,
    String? description,
    @Default([]) List<String> photoIds,
    @Default([]) List<String> tags,
    @Default(StorageStatus.inStorage) StorageStatus status,
    @Default(false) bool isDeleted,
    @NullableTimestampConverter() DateTime? deletedAt,
    @NullableTimestampConverter() DateTime? createdAt,
    @NullableTimestampConverter() DateTime? updatedAt,
  }) = _Item;

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);

  factory Item.fromFirestore(DocumentSnapshot doc) =>
      Item.fromJson({...doc.data()! as Map<String, dynamic>, 'id': doc.id});
}
