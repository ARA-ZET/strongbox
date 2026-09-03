import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/app_enums.dart';
import '../utils/timestamp_converter.dart';

part 'photo.freezed.dart';
part 'photo.g.dart';

/// A photo associated with a unit, job, or driver capture (doc 03).
/// Only the URL/path live in Firestore; the file lives in Storage (rule #24).
@freezed
class Photo with _$Photo {
  const factory Photo({
    required String id,
    required String tenantId,
    @Default('') String storageUrl,
    @Default('') String storagePath,
    @Default(PhotoType.exterior) PhotoType type,
    @Default('') String entityType,
    @Default('') String entityId,
    String? jobId,
    @Default('') String uploadedBy,
    @Default(false) bool isDeleted,
    @NullableTimestampConverter() DateTime? deletedAt,
    @NullableTimestampConverter() DateTime? createdAt,
  }) = _Photo;

  factory Photo.fromJson(Map<String, dynamic> json) => _$PhotoFromJson(json);

  factory Photo.fromFirestore(DocumentSnapshot doc) =>
      Photo.fromJson({...doc.data()! as Map<String, dynamic>, 'id': doc.id});
}
