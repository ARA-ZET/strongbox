// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ClientImpl _$$ClientImplFromJson(Map<String, dynamic> json) => _$ClientImpl(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      primaryUserId: json['primaryUserId'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      address: json['address'] == null
          ? const Address()
          : Address.fromJson(json['address'] as Map<String, dynamic>),
      type: $enumDecodeNullable(_$ClientTypeEnumMap, json['type']) ??
          ClientType.personal,
      stripeCustomerId: json['stripeCustomerId'] as String?,
      subscriptionId: json['subscriptionId'] as String?,
      subscriptionStatus: $enumDecodeNullable(
              _$SubscriptionStatusEnumMap, json['subscriptionStatus']) ??
          SubscriptionStatus.incomplete,
      memberIds: (json['memberIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      storageUnitCount: (json['storageUnitCount'] as num?)?.toInt() ?? 0,
      notes: json['notes'] as String?,
      closure: json['closure'] == null
          ? null
          : AccountClosure.fromJson(json['closure'] as Map<String, dynamic>),
      isActive: json['isActive'] as bool? ?? true,
      isDeleted: json['isDeleted'] as bool? ?? false,
      deletedAt: const NullableTimestampConverter().fromJson(json['deletedAt']),
      createdAt: const NullableTimestampConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$$ClientImplToJson(_$ClientImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'primaryUserId': instance.primaryUserId,
      'displayName': instance.displayName,
      'email': instance.email,
      'phone': instance.phone,
      'address': instance.address.toJson(),
      'type': _$ClientTypeEnumMap[instance.type]!,
      'stripeCustomerId': instance.stripeCustomerId,
      'subscriptionId': instance.subscriptionId,
      'subscriptionStatus':
          _$SubscriptionStatusEnumMap[instance.subscriptionStatus]!,
      'memberIds': instance.memberIds,
      'storageUnitCount': instance.storageUnitCount,
      'notes': instance.notes,
      'closure': instance.closure?.toJson(),
      'isActive': instance.isActive,
      'isDeleted': instance.isDeleted,
      'deletedAt':
          const NullableTimestampConverter().toJson(instance.deletedAt),
      'createdAt':
          const NullableTimestampConverter().toJson(instance.createdAt),
    };

const _$ClientTypeEnumMap = {
  ClientType.personal: 'personal',
  ClientType.business: 'business',
};

const _$SubscriptionStatusEnumMap = {
  SubscriptionStatus.active: 'active',
  SubscriptionStatus.trialing: 'trialing',
  SubscriptionStatus.pastDue: 'pastDue',
  SubscriptionStatus.cancelled: 'cancelled',
  SubscriptionStatus.incomplete: 'incomplete',
  SubscriptionStatus.unpaid: 'unpaid',
};

_$AccountClosureImpl _$$AccountClosureImplFromJson(Map<String, dynamic> json) =>
    _$AccountClosureImpl(
      status: $enumDecodeNullable(_$ClosureStatusEnumMap, json['status']) ??
          ClosureStatus.requested,
      requestedAt:
          const NullableTimestampConverter().fromJson(json['requestedAt']),
      scheduledFor:
          const NullableTimestampConverter().fromJson(json['scheduledFor']),
      requestedBy: json['requestedBy'] as String? ?? '',
      requestedByRole:
          $enumDecodeNullable(_$UserRoleEnumMap, json['requestedByRole']) ??
              UserRole.client,
      reason: json['reason'] as String?,
      closedAt: const NullableTimestampConverter().fromJson(json['closedAt']),
      closedBy: json['closedBy'] as String?,
      retainUntil:
          const NullableTimestampConverter().fromJson(json['retainUntil']),
      purgedAt: const NullableTimestampConverter().fromJson(json['purgedAt']),
    );

Map<String, dynamic> _$$AccountClosureImplToJson(
        _$AccountClosureImpl instance) =>
    <String, dynamic>{
      'status': _$ClosureStatusEnumMap[instance.status]!,
      'requestedAt':
          const NullableTimestampConverter().toJson(instance.requestedAt),
      'scheduledFor':
          const NullableTimestampConverter().toJson(instance.scheduledFor),
      'requestedBy': instance.requestedBy,
      'requestedByRole': _$UserRoleEnumMap[instance.requestedByRole]!,
      'reason': instance.reason,
      'closedAt': const NullableTimestampConverter().toJson(instance.closedAt),
      'closedBy': instance.closedBy,
      'retainUntil':
          const NullableTimestampConverter().toJson(instance.retainUntil),
      'purgedAt': const NullableTimestampConverter().toJson(instance.purgedAt),
    };

const _$ClosureStatusEnumMap = {
  ClosureStatus.requested: 'requested',
  ClosureStatus.closed: 'closed',
  ClosureStatus.purged: 'purged',
};

const _$UserRoleEnumMap = {
  UserRole.admin: 'admin',
  UserRole.driver: 'driver',
  UserRole.client: 'client',
};
