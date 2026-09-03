// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'issue_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$IssueReportImpl _$$IssueReportImplFromJson(Map<String, dynamic> json) =>
    _$IssueReportImpl(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      driverId: json['driverId'] as String,
      jobId: json['jobId'] as String?,
      issueType: $enumDecodeNullable(_$IssueTypeEnumMap, json['issueType']) ??
          IssueType.other,
      description: json['description'] as String? ?? '',
      photoIds: (json['photoIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      relatedQrCode: json['relatedQrCode'] as String?,
      isUrgent: json['isUrgent'] as bool? ?? false,
      status: $enumDecodeNullable(_$IssueStatusEnumMap, json['status']) ??
          IssueStatus.open,
      resolvedBy: json['resolvedBy'] as String?,
      resolvedAt:
          const NullableTimestampConverter().fromJson(json['resolvedAt']),
      createdAt: const NullableTimestampConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$$IssueReportImplToJson(_$IssueReportImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'driverId': instance.driverId,
      'jobId': instance.jobId,
      'issueType': _$IssueTypeEnumMap[instance.issueType]!,
      'description': instance.description,
      'photoIds': instance.photoIds,
      'relatedQrCode': instance.relatedQrCode,
      'isUrgent': instance.isUrgent,
      'status': _$IssueStatusEnumMap[instance.status]!,
      'resolvedBy': instance.resolvedBy,
      'resolvedAt':
          const NullableTimestampConverter().toJson(instance.resolvedAt),
      'createdAt':
          const NullableTimestampConverter().toJson(instance.createdAt),
    };

const _$IssueTypeEnumMap = {
  IssueType.vehicleBreakdown: 'vehicleBreakdown',
  IssueType.cargoDamage: 'cargoDamage',
  IssueType.deliveryFailed: 'deliveryFailed',
  IssueType.safetyConcern: 'safetyConcern',
  IssueType.wrongAddress: 'wrongAddress',
  IssueType.clientUnavailable: 'clientUnavailable',
  IssueType.other: 'other',
};

const _$IssueStatusEnumMap = {
  IssueStatus.open: 'open',
  IssueStatus.inReview: 'inReview',
  IssueStatus.resolved: 'resolved',
};
