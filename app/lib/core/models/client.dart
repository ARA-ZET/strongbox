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
    @Default(SubscriptionPlan.starter) SubscriptionPlan subscriptionPlan,
    @Default([]) List<String> memberIds,
    @Default(0) int storageUnitCount,
    String? notes,
    @Default(true) bool isActive,
    @Default(false) bool isDeleted,
    @NullableTimestampConverter() DateTime? deletedAt,
    @NullableTimestampConverter() DateTime? createdAt,
  }) = _Client;

  factory Client.fromJson(Map<String, dynamic> json) => _$ClientFromJson(json);

  factory Client.fromFirestore(DocumentSnapshot doc) => Client.fromJson(
      {...doc.data()! as Map<String, dynamic>, 'id': doc.id});
}
