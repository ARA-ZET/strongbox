// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AppUser _$AppUserFromJson(Map<String, dynamic> json) {
  return _AppUser.fromJson(json);
}

/// @nodoc
mixin _$AppUser {
  String get id => throw _privateConstructorUsedError;
  String get tenantId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  UserRole get role => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  String? get clientId => throw _privateConstructorUsedError;
  List<String> get fcmTokens => throw _privateConstructorUsedError;
  NotificationPrefs get notificationPrefs => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  bool get isDeleted => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get deletedAt => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get lastLoginAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AppUserCopyWith<AppUser> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppUserCopyWith<$Res> {
  factory $AppUserCopyWith(AppUser value, $Res Function(AppUser) then) =
      _$AppUserCopyWithImpl<$Res, AppUser>;
  @useResult
  $Res call(
      {String id,
      String tenantId,
      String name,
      String email,
      String? phone,
      UserRole role,
      String? avatarUrl,
      String? clientId,
      List<String> fcmTokens,
      NotificationPrefs notificationPrefs,
      bool isActive,
      bool isDeleted,
      @NullableTimestampConverter() DateTime? deletedAt,
      @NullableTimestampConverter() DateTime? createdAt,
      @NullableTimestampConverter() DateTime? lastLoginAt});

  $NotificationPrefsCopyWith<$Res> get notificationPrefs;
}

/// @nodoc
class _$AppUserCopyWithImpl<$Res, $Val extends AppUser>
    implements $AppUserCopyWith<$Res> {
  _$AppUserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? name = null,
    Object? email = null,
    Object? phone = freezed,
    Object? role = null,
    Object? avatarUrl = freezed,
    Object? clientId = freezed,
    Object? fcmTokens = null,
    Object? notificationPrefs = null,
    Object? isActive = null,
    Object? isDeleted = null,
    Object? deletedAt = freezed,
    Object? createdAt = freezed,
    Object? lastLoginAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tenantId: null == tenantId
          ? _value.tenantId
          : tenantId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as UserRole,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      clientId: freezed == clientId
          ? _value.clientId
          : clientId // ignore: cast_nullable_to_non_nullable
              as String?,
      fcmTokens: null == fcmTokens
          ? _value.fcmTokens
          : fcmTokens // ignore: cast_nullable_to_non_nullable
              as List<String>,
      notificationPrefs: null == notificationPrefs
          ? _value.notificationPrefs
          : notificationPrefs // ignore: cast_nullable_to_non_nullable
              as NotificationPrefs,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      isDeleted: null == isDeleted
          ? _value.isDeleted
          : isDeleted // ignore: cast_nullable_to_non_nullable
              as bool,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastLoginAt: freezed == lastLoginAt
          ? _value.lastLoginAt
          : lastLoginAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $NotificationPrefsCopyWith<$Res> get notificationPrefs {
    return $NotificationPrefsCopyWith<$Res>(_value.notificationPrefs, (value) {
      return _then(_value.copyWith(notificationPrefs: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AppUserImplCopyWith<$Res> implements $AppUserCopyWith<$Res> {
  factory _$$AppUserImplCopyWith(
          _$AppUserImpl value, $Res Function(_$AppUserImpl) then) =
      __$$AppUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String tenantId,
      String name,
      String email,
      String? phone,
      UserRole role,
      String? avatarUrl,
      String? clientId,
      List<String> fcmTokens,
      NotificationPrefs notificationPrefs,
      bool isActive,
      bool isDeleted,
      @NullableTimestampConverter() DateTime? deletedAt,
      @NullableTimestampConverter() DateTime? createdAt,
      @NullableTimestampConverter() DateTime? lastLoginAt});

  @override
  $NotificationPrefsCopyWith<$Res> get notificationPrefs;
}

/// @nodoc
class __$$AppUserImplCopyWithImpl<$Res>
    extends _$AppUserCopyWithImpl<$Res, _$AppUserImpl>
    implements _$$AppUserImplCopyWith<$Res> {
  __$$AppUserImplCopyWithImpl(
      _$AppUserImpl _value, $Res Function(_$AppUserImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? name = null,
    Object? email = null,
    Object? phone = freezed,
    Object? role = null,
    Object? avatarUrl = freezed,
    Object? clientId = freezed,
    Object? fcmTokens = null,
    Object? notificationPrefs = null,
    Object? isActive = null,
    Object? isDeleted = null,
    Object? deletedAt = freezed,
    Object? createdAt = freezed,
    Object? lastLoginAt = freezed,
  }) {
    return _then(_$AppUserImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tenantId: null == tenantId
          ? _value.tenantId
          : tenantId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as UserRole,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      clientId: freezed == clientId
          ? _value.clientId
          : clientId // ignore: cast_nullable_to_non_nullable
              as String?,
      fcmTokens: null == fcmTokens
          ? _value._fcmTokens
          : fcmTokens // ignore: cast_nullable_to_non_nullable
              as List<String>,
      notificationPrefs: null == notificationPrefs
          ? _value.notificationPrefs
          : notificationPrefs // ignore: cast_nullable_to_non_nullable
              as NotificationPrefs,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      isDeleted: null == isDeleted
          ? _value.isDeleted
          : isDeleted // ignore: cast_nullable_to_non_nullable
              as bool,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastLoginAt: freezed == lastLoginAt
          ? _value.lastLoginAt
          : lastLoginAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AppUserImpl extends _AppUser {
  const _$AppUserImpl(
      {required this.id,
      required this.tenantId,
      this.name = '',
      this.email = '',
      this.phone,
      this.role = UserRole.client,
      this.avatarUrl,
      this.clientId,
      final List<String> fcmTokens = const [],
      this.notificationPrefs = const NotificationPrefs(),
      this.isActive = true,
      this.isDeleted = false,
      @NullableTimestampConverter() this.deletedAt,
      @NullableTimestampConverter() this.createdAt,
      @NullableTimestampConverter() this.lastLoginAt})
      : _fcmTokens = fcmTokens,
        super._();

  factory _$AppUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppUserImplFromJson(json);

  @override
  final String id;
  @override
  final String tenantId;
  @override
  @JsonKey()
  final String name;
  @override
  @JsonKey()
  final String email;
  @override
  final String? phone;
  @override
  @JsonKey()
  final UserRole role;
  @override
  final String? avatarUrl;
  @override
  final String? clientId;
  final List<String> _fcmTokens;
  @override
  @JsonKey()
  List<String> get fcmTokens {
    if (_fcmTokens is EqualUnmodifiableListView) return _fcmTokens;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_fcmTokens);
  }

  @override
  @JsonKey()
  final NotificationPrefs notificationPrefs;
  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey()
  final bool isDeleted;
  @override
  @NullableTimestampConverter()
  final DateTime? deletedAt;
  @override
  @NullableTimestampConverter()
  final DateTime? createdAt;
  @override
  @NullableTimestampConverter()
  final DateTime? lastLoginAt;

  @override
  String toString() {
    return 'AppUser(id: $id, tenantId: $tenantId, name: $name, email: $email, phone: $phone, role: $role, avatarUrl: $avatarUrl, clientId: $clientId, fcmTokens: $fcmTokens, notificationPrefs: $notificationPrefs, isActive: $isActive, isDeleted: $isDeleted, deletedAt: $deletedAt, createdAt: $createdAt, lastLoginAt: $lastLoginAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppUserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.clientId, clientId) ||
                other.clientId == clientId) &&
            const DeepCollectionEquality()
                .equals(other._fcmTokens, _fcmTokens) &&
            (identical(other.notificationPrefs, notificationPrefs) ||
                other.notificationPrefs == notificationPrefs) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.lastLoginAt, lastLoginAt) ||
                other.lastLoginAt == lastLoginAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      tenantId,
      name,
      email,
      phone,
      role,
      avatarUrl,
      clientId,
      const DeepCollectionEquality().hash(_fcmTokens),
      notificationPrefs,
      isActive,
      isDeleted,
      deletedAt,
      createdAt,
      lastLoginAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AppUserImplCopyWith<_$AppUserImpl> get copyWith =>
      __$$AppUserImplCopyWithImpl<_$AppUserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppUserImplToJson(
      this,
    );
  }
}

abstract class _AppUser extends AppUser {
  const factory _AppUser(
          {required final String id,
          required final String tenantId,
          final String name,
          final String email,
          final String? phone,
          final UserRole role,
          final String? avatarUrl,
          final String? clientId,
          final List<String> fcmTokens,
          final NotificationPrefs notificationPrefs,
          final bool isActive,
          final bool isDeleted,
          @NullableTimestampConverter() final DateTime? deletedAt,
          @NullableTimestampConverter() final DateTime? createdAt,
          @NullableTimestampConverter() final DateTime? lastLoginAt}) =
      _$AppUserImpl;
  const _AppUser._() : super._();

  factory _AppUser.fromJson(Map<String, dynamic> json) = _$AppUserImpl.fromJson;

  @override
  String get id;
  @override
  String get tenantId;
  @override
  String get name;
  @override
  String get email;
  @override
  String? get phone;
  @override
  UserRole get role;
  @override
  String? get avatarUrl;
  @override
  String? get clientId;
  @override
  List<String> get fcmTokens;
  @override
  NotificationPrefs get notificationPrefs;
  @override
  bool get isActive;
  @override
  bool get isDeleted;
  @override
  @NullableTimestampConverter()
  DateTime? get deletedAt;
  @override
  @NullableTimestampConverter()
  DateTime? get createdAt;
  @override
  @NullableTimestampConverter()
  DateTime? get lastLoginAt;
  @override
  @JsonKey(ignore: true)
  _$$AppUserImplCopyWith<_$AppUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
