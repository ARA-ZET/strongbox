// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Client _$ClientFromJson(Map<String, dynamic> json) {
  return _Client.fromJson(json);
}

/// @nodoc
mixin _$Client {
  String get id => throw _privateConstructorUsedError;
  String get tenantId => throw _privateConstructorUsedError;
  String get primaryUserId => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  Address get address => throw _privateConstructorUsedError;
  ClientType get type => throw _privateConstructorUsedError;
  String? get stripeCustomerId => throw _privateConstructorUsedError;
  String? get subscriptionId => throw _privateConstructorUsedError;
  SubscriptionStatus get subscriptionStatus =>
      throw _privateConstructorUsedError;
  List<String> get memberIds => throw _privateConstructorUsedError;
  int get storageUnitCount => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Set while the account is closing, and kept after it closes. Written
  /// only by the account-closure Cloud Functions.
  AccountClosure? get closure => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  bool get isDeleted => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get deletedAt => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ClientCopyWith<Client> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClientCopyWith<$Res> {
  factory $ClientCopyWith(Client value, $Res Function(Client) then) =
      _$ClientCopyWithImpl<$Res, Client>;
  @useResult
  $Res call(
      {String id,
      String tenantId,
      String primaryUserId,
      String displayName,
      String email,
      String phone,
      Address address,
      ClientType type,
      String? stripeCustomerId,
      String? subscriptionId,
      SubscriptionStatus subscriptionStatus,
      List<String> memberIds,
      int storageUnitCount,
      String? notes,
      AccountClosure? closure,
      bool isActive,
      bool isDeleted,
      @NullableTimestampConverter() DateTime? deletedAt,
      @NullableTimestampConverter() DateTime? createdAt});

  $AddressCopyWith<$Res> get address;
  $AccountClosureCopyWith<$Res>? get closure;
}

/// @nodoc
class _$ClientCopyWithImpl<$Res, $Val extends Client>
    implements $ClientCopyWith<$Res> {
  _$ClientCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? primaryUserId = null,
    Object? displayName = null,
    Object? email = null,
    Object? phone = null,
    Object? address = null,
    Object? type = null,
    Object? stripeCustomerId = freezed,
    Object? subscriptionId = freezed,
    Object? subscriptionStatus = null,
    Object? memberIds = null,
    Object? storageUnitCount = null,
    Object? notes = freezed,
    Object? closure = freezed,
    Object? isActive = null,
    Object? isDeleted = null,
    Object? deletedAt = freezed,
    Object? createdAt = freezed,
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
      primaryUserId: null == primaryUserId
          ? _value.primaryUserId
          : primaryUserId // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as Address,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ClientType,
      stripeCustomerId: freezed == stripeCustomerId
          ? _value.stripeCustomerId
          : stripeCustomerId // ignore: cast_nullable_to_non_nullable
              as String?,
      subscriptionId: freezed == subscriptionId
          ? _value.subscriptionId
          : subscriptionId // ignore: cast_nullable_to_non_nullable
              as String?,
      subscriptionStatus: null == subscriptionStatus
          ? _value.subscriptionStatus
          : subscriptionStatus // ignore: cast_nullable_to_non_nullable
              as SubscriptionStatus,
      memberIds: null == memberIds
          ? _value.memberIds
          : memberIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      storageUnitCount: null == storageUnitCount
          ? _value.storageUnitCount
          : storageUnitCount // ignore: cast_nullable_to_non_nullable
              as int,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      closure: freezed == closure
          ? _value.closure
          : closure // ignore: cast_nullable_to_non_nullable
              as AccountClosure?,
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
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $AddressCopyWith<$Res> get address {
    return $AddressCopyWith<$Res>(_value.address, (value) {
      return _then(_value.copyWith(address: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $AccountClosureCopyWith<$Res>? get closure {
    if (_value.closure == null) {
      return null;
    }

    return $AccountClosureCopyWith<$Res>(_value.closure!, (value) {
      return _then(_value.copyWith(closure: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ClientImplCopyWith<$Res> implements $ClientCopyWith<$Res> {
  factory _$$ClientImplCopyWith(
          _$ClientImpl value, $Res Function(_$ClientImpl) then) =
      __$$ClientImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String tenantId,
      String primaryUserId,
      String displayName,
      String email,
      String phone,
      Address address,
      ClientType type,
      String? stripeCustomerId,
      String? subscriptionId,
      SubscriptionStatus subscriptionStatus,
      List<String> memberIds,
      int storageUnitCount,
      String? notes,
      AccountClosure? closure,
      bool isActive,
      bool isDeleted,
      @NullableTimestampConverter() DateTime? deletedAt,
      @NullableTimestampConverter() DateTime? createdAt});

  @override
  $AddressCopyWith<$Res> get address;
  @override
  $AccountClosureCopyWith<$Res>? get closure;
}

/// @nodoc
class __$$ClientImplCopyWithImpl<$Res>
    extends _$ClientCopyWithImpl<$Res, _$ClientImpl>
    implements _$$ClientImplCopyWith<$Res> {
  __$$ClientImplCopyWithImpl(
      _$ClientImpl _value, $Res Function(_$ClientImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? primaryUserId = null,
    Object? displayName = null,
    Object? email = null,
    Object? phone = null,
    Object? address = null,
    Object? type = null,
    Object? stripeCustomerId = freezed,
    Object? subscriptionId = freezed,
    Object? subscriptionStatus = null,
    Object? memberIds = null,
    Object? storageUnitCount = null,
    Object? notes = freezed,
    Object? closure = freezed,
    Object? isActive = null,
    Object? isDeleted = null,
    Object? deletedAt = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$ClientImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tenantId: null == tenantId
          ? _value.tenantId
          : tenantId // ignore: cast_nullable_to_non_nullable
              as String,
      primaryUserId: null == primaryUserId
          ? _value.primaryUserId
          : primaryUserId // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as Address,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ClientType,
      stripeCustomerId: freezed == stripeCustomerId
          ? _value.stripeCustomerId
          : stripeCustomerId // ignore: cast_nullable_to_non_nullable
              as String?,
      subscriptionId: freezed == subscriptionId
          ? _value.subscriptionId
          : subscriptionId // ignore: cast_nullable_to_non_nullable
              as String?,
      subscriptionStatus: null == subscriptionStatus
          ? _value.subscriptionStatus
          : subscriptionStatus // ignore: cast_nullable_to_non_nullable
              as SubscriptionStatus,
      memberIds: null == memberIds
          ? _value._memberIds
          : memberIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      storageUnitCount: null == storageUnitCount
          ? _value.storageUnitCount
          : storageUnitCount // ignore: cast_nullable_to_non_nullable
              as int,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      closure: freezed == closure
          ? _value.closure
          : closure // ignore: cast_nullable_to_non_nullable
              as AccountClosure?,
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
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ClientImpl implements _Client {
  const _$ClientImpl(
      {required this.id,
      required this.tenantId,
      this.primaryUserId = '',
      this.displayName = '',
      this.email = '',
      this.phone = '',
      this.address = const Address(),
      this.type = ClientType.personal,
      this.stripeCustomerId,
      this.subscriptionId,
      this.subscriptionStatus = SubscriptionStatus.incomplete,
      final List<String> memberIds = const [],
      this.storageUnitCount = 0,
      this.notes,
      this.closure,
      this.isActive = true,
      this.isDeleted = false,
      @NullableTimestampConverter() this.deletedAt,
      @NullableTimestampConverter() this.createdAt})
      : _memberIds = memberIds;

  factory _$ClientImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClientImplFromJson(json);

  @override
  final String id;
  @override
  final String tenantId;
  @override
  @JsonKey()
  final String primaryUserId;
  @override
  @JsonKey()
  final String displayName;
  @override
  @JsonKey()
  final String email;
  @override
  @JsonKey()
  final String phone;
  @override
  @JsonKey()
  final Address address;
  @override
  @JsonKey()
  final ClientType type;
  @override
  final String? stripeCustomerId;
  @override
  final String? subscriptionId;
  @override
  @JsonKey()
  final SubscriptionStatus subscriptionStatus;
  final List<String> _memberIds;
  @override
  @JsonKey()
  List<String> get memberIds {
    if (_memberIds is EqualUnmodifiableListView) return _memberIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_memberIds);
  }

  @override
  @JsonKey()
  final int storageUnitCount;
  @override
  final String? notes;

  /// Set while the account is closing, and kept after it closes. Written
  /// only by the account-closure Cloud Functions.
  @override
  final AccountClosure? closure;
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
  String toString() {
    return 'Client(id: $id, tenantId: $tenantId, primaryUserId: $primaryUserId, displayName: $displayName, email: $email, phone: $phone, address: $address, type: $type, stripeCustomerId: $stripeCustomerId, subscriptionId: $subscriptionId, subscriptionStatus: $subscriptionStatus, memberIds: $memberIds, storageUnitCount: $storageUnitCount, notes: $notes, closure: $closure, isActive: $isActive, isDeleted: $isDeleted, deletedAt: $deletedAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClientImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.primaryUserId, primaryUserId) ||
                other.primaryUserId == primaryUserId) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.stripeCustomerId, stripeCustomerId) ||
                other.stripeCustomerId == stripeCustomerId) &&
            (identical(other.subscriptionId, subscriptionId) ||
                other.subscriptionId == subscriptionId) &&
            (identical(other.subscriptionStatus, subscriptionStatus) ||
                other.subscriptionStatus == subscriptionStatus) &&
            const DeepCollectionEquality()
                .equals(other._memberIds, _memberIds) &&
            (identical(other.storageUnitCount, storageUnitCount) ||
                other.storageUnitCount == storageUnitCount) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.closure, closure) || other.closure == closure) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        tenantId,
        primaryUserId,
        displayName,
        email,
        phone,
        address,
        type,
        stripeCustomerId,
        subscriptionId,
        subscriptionStatus,
        const DeepCollectionEquality().hash(_memberIds),
        storageUnitCount,
        notes,
        closure,
        isActive,
        isDeleted,
        deletedAt,
        createdAt
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ClientImplCopyWith<_$ClientImpl> get copyWith =>
      __$$ClientImplCopyWithImpl<_$ClientImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClientImplToJson(
      this,
    );
  }
}

abstract class _Client implements Client {
  const factory _Client(
      {required final String id,
      required final String tenantId,
      final String primaryUserId,
      final String displayName,
      final String email,
      final String phone,
      final Address address,
      final ClientType type,
      final String? stripeCustomerId,
      final String? subscriptionId,
      final SubscriptionStatus subscriptionStatus,
      final List<String> memberIds,
      final int storageUnitCount,
      final String? notes,
      final AccountClosure? closure,
      final bool isActive,
      final bool isDeleted,
      @NullableTimestampConverter() final DateTime? deletedAt,
      @NullableTimestampConverter() final DateTime? createdAt}) = _$ClientImpl;

  factory _Client.fromJson(Map<String, dynamic> json) = _$ClientImpl.fromJson;

  @override
  String get id;
  @override
  String get tenantId;
  @override
  String get primaryUserId;
  @override
  String get displayName;
  @override
  String get email;
  @override
  String get phone;
  @override
  Address get address;
  @override
  ClientType get type;
  @override
  String? get stripeCustomerId;
  @override
  String? get subscriptionId;
  @override
  SubscriptionStatus get subscriptionStatus;
  @override
  List<String> get memberIds;
  @override
  int get storageUnitCount;
  @override
  String? get notes;
  @override

  /// Set while the account is closing, and kept after it closes. Written
  /// only by the account-closure Cloud Functions.
  AccountClosure? get closure;
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
  @JsonKey(ignore: true)
  _$$ClientImplCopyWith<_$ClientImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AccountClosure _$AccountClosureFromJson(Map<String, dynamic> json) {
  return _AccountClosure.fromJson(json);
}

/// @nodoc
mixin _$AccountClosure {
  ClosureStatus get status => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get requestedAt => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get scheduledFor => throw _privateConstructorUsedError;

  /// uid of whoever asked — the client, or an admin on their behalf.
  String get requestedBy => throw _privateConstructorUsedError;
  UserRole get requestedByRole => throw _privateConstructorUsedError;

  /// Why, or how they asked (admin-entered), e.g. "Emailed 12 Nov".
  String? get reason => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get closedAt => throw _privateConstructorUsedError;

  /// uid of the admin who closed it early, or `system` for the sweep.
  String? get closedBy => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get retainUntil => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get purgedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AccountClosureCopyWith<AccountClosure> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AccountClosureCopyWith<$Res> {
  factory $AccountClosureCopyWith(
          AccountClosure value, $Res Function(AccountClosure) then) =
      _$AccountClosureCopyWithImpl<$Res, AccountClosure>;
  @useResult
  $Res call(
      {ClosureStatus status,
      @NullableTimestampConverter() DateTime? requestedAt,
      @NullableTimestampConverter() DateTime? scheduledFor,
      String requestedBy,
      UserRole requestedByRole,
      String? reason,
      @NullableTimestampConverter() DateTime? closedAt,
      String? closedBy,
      @NullableTimestampConverter() DateTime? retainUntil,
      @NullableTimestampConverter() DateTime? purgedAt});
}

/// @nodoc
class _$AccountClosureCopyWithImpl<$Res, $Val extends AccountClosure>
    implements $AccountClosureCopyWith<$Res> {
  _$AccountClosureCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? requestedAt = freezed,
    Object? scheduledFor = freezed,
    Object? requestedBy = null,
    Object? requestedByRole = null,
    Object? reason = freezed,
    Object? closedAt = freezed,
    Object? closedBy = freezed,
    Object? retainUntil = freezed,
    Object? purgedAt = freezed,
  }) {
    return _then(_value.copyWith(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ClosureStatus,
      requestedAt: freezed == requestedAt
          ? _value.requestedAt
          : requestedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      scheduledFor: freezed == scheduledFor
          ? _value.scheduledFor
          : scheduledFor // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      requestedBy: null == requestedBy
          ? _value.requestedBy
          : requestedBy // ignore: cast_nullable_to_non_nullable
              as String,
      requestedByRole: null == requestedByRole
          ? _value.requestedByRole
          : requestedByRole // ignore: cast_nullable_to_non_nullable
              as UserRole,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
      closedAt: freezed == closedAt
          ? _value.closedAt
          : closedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      closedBy: freezed == closedBy
          ? _value.closedBy
          : closedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      retainUntil: freezed == retainUntil
          ? _value.retainUntil
          : retainUntil // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      purgedAt: freezed == purgedAt
          ? _value.purgedAt
          : purgedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AccountClosureImplCopyWith<$Res>
    implements $AccountClosureCopyWith<$Res> {
  factory _$$AccountClosureImplCopyWith(_$AccountClosureImpl value,
          $Res Function(_$AccountClosureImpl) then) =
      __$$AccountClosureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {ClosureStatus status,
      @NullableTimestampConverter() DateTime? requestedAt,
      @NullableTimestampConverter() DateTime? scheduledFor,
      String requestedBy,
      UserRole requestedByRole,
      String? reason,
      @NullableTimestampConverter() DateTime? closedAt,
      String? closedBy,
      @NullableTimestampConverter() DateTime? retainUntil,
      @NullableTimestampConverter() DateTime? purgedAt});
}

/// @nodoc
class __$$AccountClosureImplCopyWithImpl<$Res>
    extends _$AccountClosureCopyWithImpl<$Res, _$AccountClosureImpl>
    implements _$$AccountClosureImplCopyWith<$Res> {
  __$$AccountClosureImplCopyWithImpl(
      _$AccountClosureImpl _value, $Res Function(_$AccountClosureImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? requestedAt = freezed,
    Object? scheduledFor = freezed,
    Object? requestedBy = null,
    Object? requestedByRole = null,
    Object? reason = freezed,
    Object? closedAt = freezed,
    Object? closedBy = freezed,
    Object? retainUntil = freezed,
    Object? purgedAt = freezed,
  }) {
    return _then(_$AccountClosureImpl(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ClosureStatus,
      requestedAt: freezed == requestedAt
          ? _value.requestedAt
          : requestedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      scheduledFor: freezed == scheduledFor
          ? _value.scheduledFor
          : scheduledFor // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      requestedBy: null == requestedBy
          ? _value.requestedBy
          : requestedBy // ignore: cast_nullable_to_non_nullable
              as String,
      requestedByRole: null == requestedByRole
          ? _value.requestedByRole
          : requestedByRole // ignore: cast_nullable_to_non_nullable
              as UserRole,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
      closedAt: freezed == closedAt
          ? _value.closedAt
          : closedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      closedBy: freezed == closedBy
          ? _value.closedBy
          : closedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      retainUntil: freezed == retainUntil
          ? _value.retainUntil
          : retainUntil // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      purgedAt: freezed == purgedAt
          ? _value.purgedAt
          : purgedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AccountClosureImpl extends _AccountClosure {
  const _$AccountClosureImpl(
      {this.status = ClosureStatus.requested,
      @NullableTimestampConverter() this.requestedAt,
      @NullableTimestampConverter() this.scheduledFor,
      this.requestedBy = '',
      this.requestedByRole = UserRole.client,
      this.reason,
      @NullableTimestampConverter() this.closedAt,
      this.closedBy,
      @NullableTimestampConverter() this.retainUntil,
      @NullableTimestampConverter() this.purgedAt})
      : super._();

  factory _$AccountClosureImpl.fromJson(Map<String, dynamic> json) =>
      _$$AccountClosureImplFromJson(json);

  @override
  @JsonKey()
  final ClosureStatus status;
  @override
  @NullableTimestampConverter()
  final DateTime? requestedAt;
  @override
  @NullableTimestampConverter()
  final DateTime? scheduledFor;

  /// uid of whoever asked — the client, or an admin on their behalf.
  @override
  @JsonKey()
  final String requestedBy;
  @override
  @JsonKey()
  final UserRole requestedByRole;

  /// Why, or how they asked (admin-entered), e.g. "Emailed 12 Nov".
  @override
  final String? reason;
  @override
  @NullableTimestampConverter()
  final DateTime? closedAt;

  /// uid of the admin who closed it early, or `system` for the sweep.
  @override
  final String? closedBy;
  @override
  @NullableTimestampConverter()
  final DateTime? retainUntil;
  @override
  @NullableTimestampConverter()
  final DateTime? purgedAt;

  @override
  String toString() {
    return 'AccountClosure(status: $status, requestedAt: $requestedAt, scheduledFor: $scheduledFor, requestedBy: $requestedBy, requestedByRole: $requestedByRole, reason: $reason, closedAt: $closedAt, closedBy: $closedBy, retainUntil: $retainUntil, purgedAt: $purgedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AccountClosureImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.requestedAt, requestedAt) ||
                other.requestedAt == requestedAt) &&
            (identical(other.scheduledFor, scheduledFor) ||
                other.scheduledFor == scheduledFor) &&
            (identical(other.requestedBy, requestedBy) ||
                other.requestedBy == requestedBy) &&
            (identical(other.requestedByRole, requestedByRole) ||
                other.requestedByRole == requestedByRole) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.closedAt, closedAt) ||
                other.closedAt == closedAt) &&
            (identical(other.closedBy, closedBy) ||
                other.closedBy == closedBy) &&
            (identical(other.retainUntil, retainUntil) ||
                other.retainUntil == retainUntil) &&
            (identical(other.purgedAt, purgedAt) ||
                other.purgedAt == purgedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      status,
      requestedAt,
      scheduledFor,
      requestedBy,
      requestedByRole,
      reason,
      closedAt,
      closedBy,
      retainUntil,
      purgedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AccountClosureImplCopyWith<_$AccountClosureImpl> get copyWith =>
      __$$AccountClosureImplCopyWithImpl<_$AccountClosureImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AccountClosureImplToJson(
      this,
    );
  }
}

abstract class _AccountClosure extends AccountClosure {
  const factory _AccountClosure(
          {final ClosureStatus status,
          @NullableTimestampConverter() final DateTime? requestedAt,
          @NullableTimestampConverter() final DateTime? scheduledFor,
          final String requestedBy,
          final UserRole requestedByRole,
          final String? reason,
          @NullableTimestampConverter() final DateTime? closedAt,
          final String? closedBy,
          @NullableTimestampConverter() final DateTime? retainUntil,
          @NullableTimestampConverter() final DateTime? purgedAt}) =
      _$AccountClosureImpl;
  const _AccountClosure._() : super._();

  factory _AccountClosure.fromJson(Map<String, dynamic> json) =
      _$AccountClosureImpl.fromJson;

  @override
  ClosureStatus get status;
  @override
  @NullableTimestampConverter()
  DateTime? get requestedAt;
  @override
  @NullableTimestampConverter()
  DateTime? get scheduledFor;
  @override

  /// uid of whoever asked — the client, or an admin on their behalf.
  String get requestedBy;
  @override
  UserRole get requestedByRole;
  @override

  /// Why, or how they asked (admin-entered), e.g. "Emailed 12 Nov".
  String? get reason;
  @override
  @NullableTimestampConverter()
  DateTime? get closedAt;
  @override

  /// uid of the admin who closed it early, or `system` for the sweep.
  String? get closedBy;
  @override
  @NullableTimestampConverter()
  DateTime? get retainUntil;
  @override
  @NullableTimestampConverter()
  DateTime? get purgedAt;
  @override
  @JsonKey(ignore: true)
  _$$AccountClosureImplCopyWith<_$AccountClosureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
