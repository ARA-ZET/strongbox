import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../utils/timestamp_converter.dart';

part 'qr_code.freezed.dart';
part 'qr_code.g.dart';

/// A unique scannable identifier physically attached to a unit (doc 03).
@freezed
class QRCode with _$QRCode {
  const factory QRCode({
    required String id,
    required String tenantId,
    @Default('') String batchId,
    String? storageUnitId,
    @Default(false) bool isLinked,
    @NullableTimestampConverter() DateTime? linkedAt,
    String? linkedBy,
    @NullableTimestampConverter() DateTime? createdAt,
  }) = _QRCode;

  factory QRCode.fromJson(Map<String, dynamic> json) => _$QRCodeFromJson(json);

  factory QRCode.fromFirestore(DocumentSnapshot doc) =>
      QRCode.fromJson({...doc.data()! as Map<String, dynamic>, 'id': doc.id});
}

/// A set of QR codes generated together for printing (doc 03).
@freezed
class QRBatch with _$QRBatch {
  const factory QRBatch({
    required String id,
    required String tenantId,
    @Default(0) int count,
    @Default([]) List<String> codeIds,
    @Default(0) int linkedCount,
    @Default('300dpi') String printResolution,
    @Default('') String createdBy,
    @NullableTimestampConverter() DateTime? createdAt,
  }) = _QRBatch;

  factory QRBatch.fromJson(Map<String, dynamic> json) =>
      _$QRBatchFromJson(json);

  factory QRBatch.fromFirestore(DocumentSnapshot doc) =>
      QRBatch.fromJson({...doc.data()! as Map<String, dynamic>, 'id': doc.id});
}

/// Codes in a batch not yet linked to a unit.
int unlinkedCountOf(QRBatch batch) =>
    (batch.count - batch.linkedCount).clamp(0, batch.count);
