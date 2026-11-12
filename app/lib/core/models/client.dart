import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/app_enums.dart';
import '../utils/timestamp_converter.dart';
import 'value_objects.dart';

part 'client.freezed.dart';
part 'client.g.dart';

/// A paying customer of the storage business (doc 03).
@freezed
class Client with _$Client {
  const factory Client({
    required String id,
    required String tenantId,
    @Default('') String primaryUserId,
    @Default('') String displayName,
    @Default('') String email,
    @Default('') String phone,
    @Default(Address()) Address address,
    @Default(ClientType.personal) ClientType type,
    String? stripeCustomerId,
    String? subscriptionId,
    @Default(SubscriptionStatus.incomplete) SubscriptionStatus subscriptionStatus,
    @Default([]) List<String> memberIds,
    @Default(0) int storageUnitCount,
    String? notes,
    /// Set while the account is closing, and kept after it closes. Written
    /// only by the account-closure Cloud Functions.
    AccountClosure? closure,
    @Default(true) bool isActive,
    @Default(false) bool isDeleted,
    @NullableTimestampConverter() DateTime? deletedAt,
    @NullableTimestampConverter() DateTime? createdAt,
  }) = _Client;

  factory Client.fromJson(Map<String, dynamic> json) => _$ClientFromJson(json);

  factory Client.fromFirestore(DocumentSnapshot doc) => Client.fromJson(
      {...doc.data()! as Map<String, dynamic>, 'id': doc.id});
}

/// A client's account closure — their request to have their personal
/// information deleted (functions/src/closure.js).
///
/// [ClosureStatus.requested]: closes on [scheduledFor] once nothing blocks
/// it; the client can still sign in and cancel. [ClosureStatus.closed]:
/// login and contact details removed; records kept, admin-only, until
/// [retainUntil]. [ClosureStatus.purged]: those records removed too.
@freezed
class AccountClosure with _$AccountClosure {
  const AccountClosure._();

  const factory AccountClosure({
    @Default(ClosureStatus.requested) ClosureStatus status,
    @NullableTimestampConverter() DateTime? requestedAt,
    @NullableTimestampConverter() DateTime? scheduledFor,
    /// uid of whoever asked — the client, or an admin on their behalf.
    @Default('') String requestedBy,
    @Default(UserRole.client) UserRole requestedByRole,
    /// Why, or how they asked (admin-entered), e.g. "Emailed 12 Nov".
    String? reason,
    @NullableTimestampConverter() DateTime? closedAt,
    /// uid of the admin who closed it early, or `system` for the sweep.
    String? closedBy,
    @NullableTimestampConverter() DateTime? retainUntil,
    @NullableTimestampConverter() DateTime? purgedAt,
  }) = _AccountClosure;

  factory AccountClosure.fromJson(Map<String, dynamic> json) =>
      _$AccountClosureFromJson(json);

  bool get isPending => status == ClosureStatus.requested;
}

/// Closure state of a [Client].
extension ClientClosureX on Client {
  /// Asked to close and not closed yet.
  bool get isClosing => closure?.isPending ?? false;

  /// Closed (or closed and purged) — an archived record.
  bool get isClosed =>
      closure?.status == ClosureStatus.closed ||
      closure?.status == ClosureStatus.purged;
}
