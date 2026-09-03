import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/app_enums.dart';
import '../utils/timestamp_converter.dart';

part 'issue_report.freezed.dart';
part 'issue_report.g.dart';

/// A problem report submitted by a driver (doc 03).
@freezed
class IssueReport with _$IssueReport {
  const factory IssueReport({
    required String id,
    required String tenantId,
    required String driverId,
    String? jobId,
    @Default(IssueType.other) IssueType issueType,
    @Default('') String description,
    @Default([]) List<String> photoIds,
    String? relatedQrCode,
    @Default(false) bool isUrgent,
    @Default(IssueStatus.open) IssueStatus status,
    String? resolvedBy,
    @NullableTimestampConverter() DateTime? resolvedAt,
    @NullableTimestampConverter() DateTime? createdAt,
  }) = _IssueReport;

  factory IssueReport.fromJson(Map<String, dynamic> json) =>
      _$IssueReportFromJson(json);

  factory IssueReport.fromFirestore(DocumentSnapshot doc) =>
      IssueReport.fromJson(
          {...doc.data()! as Map<String, dynamic>, 'id': doc.id});
}
