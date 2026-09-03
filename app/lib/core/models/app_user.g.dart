// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppUserImpl _$$AppUserImplFromJson(Map<String, dynamic> json) =>
    _$AppUserImpl(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      role: $enumDecodeNullable(_$UserRoleEnumMap, json['role']) ??
          UserRole.client,
      avatarUrl: json['avatarUrl'] as String?,
      clientId: json['clientId'] as String?,
      fcmTokens: (json['fcmTokens'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      notificationPrefs: json['notificationPrefs'] == null
          ? const NotificationPrefs()
          : NotificationPrefs.fromJson(
              json['notificationPrefs'] as Map<String, dynamic>),
      isActive: json['isActive'] as bool? ?? true,
      isDeleted: json['isDeleted'] as bool? ?? false,
      deletedAt: const NullableTimestampConverter().fromJson(json['deletedAt']),
      createdAt: const NullableTimestampConverter().fromJson(json['createdAt']),
      lastLoginAt:
          const NullableTimestampConverter().fromJson(json['lastLoginAt']),
    );

Map<String, dynamic> _$$AppUserImplToJson(_$AppUserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'role': _$UserRoleEnumMap[instance.role]!,
      'avatarUrl': instance.avatarUrl,
      'clientId': instance.clientId,
      'fcmTokens': instance.fcmTokens,
      'notificationPrefs': instance.notificationPrefs.toJson(),
      'isActive': instance.isActive,
      'isDeleted': instance.isDeleted,
      'deletedAt':
          const NullableTimestampConverter().toJson(instance.deletedAt),
      'createdAt':
          const NullableTimestampConverter().toJson(instance.createdAt),
      'lastLoginAt':
          const NullableTimestampConverter().toJson(instance.lastLoginAt),
    };

const _$UserRoleEnumMap = {
  UserRole.admin: 'admin',
  UserRole.driver: 'driver',
  UserRole.client: 'client',
};
