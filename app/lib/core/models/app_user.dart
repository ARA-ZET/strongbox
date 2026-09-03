import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/app_enums.dart';
import '../utils/timestamp_converter.dart';
import 'value_objects.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

/// A person who authenticates with the system (doc 03).
@freezed
class AppUser with _$AppUser {
  const AppUser._();

  const factory AppUser({
    required String id,
    required String tenantId,
    @Default('') String name,
    @Default('') String email,
    String? phone,
    @Default(UserRole.client) UserRole role,
    String? avatarUrl,
    String? clientId,
    @Default([]) List<String> fcmTokens,
    @Default(NotificationPrefs()) NotificationPrefs notificationPrefs,
    @Default(true) bool isActive,
    @Default(false) bool isDeleted,
    @NullableTimestampConverter() DateTime? deletedAt,
    @NullableTimestampConverter() DateTime? createdAt,
    @NullableTimestampConverter() DateTime? lastLoginAt,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);

  factory AppUser.fromFirestore(DocumentSnapshot doc) => AppUser.fromJson(
      {...doc.data()! as Map<String, dynamic>, 'id': doc.id});

  bool get isAdmin => role == UserRole.admin;
  bool get isDriver => role == UserRole.driver;
  bool get isClient => role == UserRole.client;
}
