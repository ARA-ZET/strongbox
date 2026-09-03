import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/app_enums.dart';
import '../utils/timestamp_converter.dart';

part 'audit_event.freezed.dart';
part 'audit_event.g.dart';

/// An immutable log entry for a significant system action (doc 03).
/// Append-only — never updated or deleted (rule #23).
@freezed
class AuditEvent with _$AuditEvent {
  const factory AuditEvent({
    required String id,
    required String tenantId,
    @Default('') String actorId,
    @Default(UserRole.admin) UserRole actorRole,
    required AuditAction action,
    @Default('') String entityType,
    @Default('') String entityId,
    @Default({}) Map<String, dynamic> metadata,
    @NullableTimestampConverter() DateTime? timestamp,
  }) = _AuditEvent;

  factory AuditEvent.fromJson(Map<String, dynamic> json) =>
      _$AuditEventFromJson(json);

  factory AuditEvent.fromFirestore(DocumentSnapshot doc) =>
      AuditEvent.fromJson(
          {...doc.data()! as Map<String, dynamic>, 'id': doc.id});
}
