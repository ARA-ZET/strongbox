// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vehicle.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Vehicle _$VehicleFromJson(Map<String, dynamic> json) {
  return _Vehicle.fromJson(json);
}

/// @nodoc
mixin _$Vehicle {
  String get id => throw _privateConstructorUsedError;
  String get tenantId => throw _privateConstructorUsedError;
  VehicleType get type => throw _privateConstructorUsedError;

  /// What the team calls it, e.g. "Bakkie 2".
  String get name => throw _privateConstructorUsedError;

  /// Number plate, stored upper-case without extra spaces.
  String get registration => throw _privateConstructorUsedError;
  String? get make => throw _privateConstructorUsedError;
  String? get model => throw _privateConstructorUsedError;
  int? get year => throw _privateConstructorUsedError;

  /// Load volume, for matching jobs to vehicles.
  double? get capacityM3 => throw _privateConstructorUsedError;
  int? get payloadKg => throw _privateConstructorUsedError;
  VehicleStatus get status => throw _privateConstructorUsedError;

  /// The driver who usually drives it (not for trailers).
  String? get assignedDriverId => throw _privateConstructorUsedError;

  /// Licence disc expiry — renewed every year.
  @NullableTimestampConverter()
  DateTime? get licenceExpiresAt => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  bool get isDeleted => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get deletedAt => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $VehicleCopyWith<Vehicle> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VehicleCopyWith<$Res> {
  factory $VehicleCopyWith(Vehicle value, $Res Function(Vehicle) then) =
      _$VehicleCopyWithImpl<$Res, Vehicle>;
  @useResult
  $Res call(
      {String id,
      String tenantId,
      VehicleType type,
      String name,
      String registration,
      String? make,
      String? model,
      int? year,
      double? capacityM3,
      int? payloadKg,
      VehicleStatus status,
      String? assignedDriverId,
      @NullableTimestampConverter() DateTime? licenceExpiresAt,
      String? notes,
      bool isDeleted,
      @NullableTimestampConverter() DateTime? deletedAt,
      @NullableTimestampConverter() DateTime? createdAt,
      @NullableTimestampConverter() DateTime? updatedAt});
}

/// @nodoc
class _$VehicleCopyWithImpl<$Res, $Val extends Vehicle>
    implements $VehicleCopyWith<$Res> {
  _$VehicleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? type = null,
    Object? name = null,
    Object? registration = null,
    Object? make = freezed,
    Object? model = freezed,
    Object? year = freezed,
    Object? capacityM3 = freezed,
    Object? payloadKg = freezed,
    Object? status = null,
    Object? assignedDriverId = freezed,
    Object? licenceExpiresAt = freezed,
    Object? notes = freezed,
    Object? isDeleted = null,
    Object? deletedAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
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
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as VehicleType,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      registration: null == registration
          ? _value.registration
          : registration // ignore: cast_nullable_to_non_nullable
              as String,
      make: freezed == make
          ? _value.make
          : make // ignore: cast_nullable_to_non_nullable
              as String?,
      model: freezed == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as String?,
      year: freezed == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int?,
      capacityM3: freezed == capacityM3
          ? _value.capacityM3
          : capacityM3 // ignore: cast_nullable_to_non_nullable
              as double?,
      payloadKg: freezed == payloadKg
          ? _value.payloadKg
          : payloadKg // ignore: cast_nullable_to_non_nullable
              as int?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as VehicleStatus,
      assignedDriverId: freezed == assignedDriverId
          ? _value.assignedDriverId
          : assignedDriverId // ignore: cast_nullable_to_non_nullable
              as String?,
      licenceExpiresAt: freezed == licenceExpiresAt
          ? _value.licenceExpiresAt
          : licenceExpiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
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
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VehicleImplCopyWith<$Res> implements $VehicleCopyWith<$Res> {
  factory _$$VehicleImplCopyWith(
          _$VehicleImpl value, $Res Function(_$VehicleImpl) then) =
      __$$VehicleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String tenantId,
      VehicleType type,
      String name,
      String registration,
      String? make,
      String? model,
      int? year,
      double? capacityM3,
      int? payloadKg,
      VehicleStatus status,
      String? assignedDriverId,
      @NullableTimestampConverter() DateTime? licenceExpiresAt,
      String? notes,
      bool isDeleted,
      @NullableTimestampConverter() DateTime? deletedAt,
      @NullableTimestampConverter() DateTime? createdAt,
      @NullableTimestampConverter() DateTime? updatedAt});
}

/// @nodoc
class __$$VehicleImplCopyWithImpl<$Res>
    extends _$VehicleCopyWithImpl<$Res, _$VehicleImpl>
    implements _$$VehicleImplCopyWith<$Res> {
  __$$VehicleImplCopyWithImpl(
      _$VehicleImpl _value, $Res Function(_$VehicleImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? type = null,
    Object? name = null,
    Object? registration = null,
    Object? make = freezed,
    Object? model = freezed,
    Object? year = freezed,
    Object? capacityM3 = freezed,
    Object? payloadKg = freezed,
    Object? status = null,
    Object? assignedDriverId = freezed,
    Object? licenceExpiresAt = freezed,
    Object? notes = freezed,
    Object? isDeleted = null,
    Object? deletedAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$VehicleImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tenantId: null == tenantId
          ? _value.tenantId
          : tenantId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as VehicleType,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      registration: null == registration
          ? _value.registration
          : registration // ignore: cast_nullable_to_non_nullable
              as String,
      make: freezed == make
          ? _value.make
          : make // ignore: cast_nullable_to_non_nullable
              as String?,
      model: freezed == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as String?,
      year: freezed == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int?,
      capacityM3: freezed == capacityM3
          ? _value.capacityM3
          : capacityM3 // ignore: cast_nullable_to_non_nullable
              as double?,
      payloadKg: freezed == payloadKg
          ? _value.payloadKg
          : payloadKg // ignore: cast_nullable_to_non_nullable
              as int?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as VehicleStatus,
      assignedDriverId: freezed == assignedDriverId
          ? _value.assignedDriverId
          : assignedDriverId // ignore: cast_nullable_to_non_nullable
              as String?,
      licenceExpiresAt: freezed == licenceExpiresAt
          ? _value.licenceExpiresAt
          : licenceExpiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
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
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VehicleImpl extends _Vehicle {
  const _$VehicleImpl(
      {required this.id,
      required this.tenantId,
      this.type = VehicleType.bakkie,
      this.name = '',
      this.registration = '',
      this.make,
      this.model,
      this.year,
      this.capacityM3,
      this.payloadKg,
      this.status = VehicleStatus.available,
      this.assignedDriverId,
      @NullableTimestampConverter() this.licenceExpiresAt,
      this.notes,
      this.isDeleted = false,
      @NullableTimestampConverter() this.deletedAt,
      @NullableTimestampConverter() this.createdAt,
      @NullableTimestampConverter() this.updatedAt})
      : super._();

  factory _$VehicleImpl.fromJson(Map<String, dynamic> json) =>
      _$$VehicleImplFromJson(json);

  @override
  final String id;
  @override
  final String tenantId;
  @override
  @JsonKey()
  final VehicleType type;

  /// What the team calls it, e.g. "Bakkie 2".
  @override
  @JsonKey()
  final String name;

  /// Number plate, stored upper-case without extra spaces.
  @override
  @JsonKey()
  final String registration;
  @override
  final String? make;
  @override
  final String? model;
  @override
  final int? year;

  /// Load volume, for matching jobs to vehicles.
  @override
  final double? capacityM3;
  @override
  final int? payloadKg;
  @override
  @JsonKey()
  final VehicleStatus status;

  /// The driver who usually drives it (not for trailers).
  @override
  final String? assignedDriverId;

  /// Licence disc expiry — renewed every year.
  @override
  @NullableTimestampConverter()
  final DateTime? licenceExpiresAt;
  @override
  final String? notes;
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
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Vehicle(id: $id, tenantId: $tenantId, type: $type, name: $name, registration: $registration, make: $make, model: $model, year: $year, capacityM3: $capacityM3, payloadKg: $payloadKg, status: $status, assignedDriverId: $assignedDriverId, licenceExpiresAt: $licenceExpiresAt, notes: $notes, isDeleted: $isDeleted, deletedAt: $deletedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VehicleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.registration, registration) ||
                other.registration == registration) &&
            (identical(other.make, make) || other.make == make) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.capacityM3, capacityM3) ||
                other.capacityM3 == capacityM3) &&
            (identical(other.payloadKg, payloadKg) ||
                other.payloadKg == payloadKg) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.assignedDriverId, assignedDriverId) ||
                other.assignedDriverId == assignedDriverId) &&
            (identical(other.licenceExpiresAt, licenceExpiresAt) ||
                other.licenceExpiresAt == licenceExpiresAt) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      tenantId,
      type,
      name,
      registration,
      make,
      model,
      year,
      capacityM3,
      payloadKg,
      status,
      assignedDriverId,
      licenceExpiresAt,
      notes,
      isDeleted,
      deletedAt,
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$VehicleImplCopyWith<_$VehicleImpl> get copyWith =>
      __$$VehicleImplCopyWithImpl<_$VehicleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VehicleImplToJson(
      this,
    );
  }
}

abstract class _Vehicle extends Vehicle {
  const factory _Vehicle(
      {required final String id,
      required final String tenantId,
      final VehicleType type,
      final String name,
      final String registration,
      final String? make,
      final String? model,
      final int? year,
      final double? capacityM3,
      final int? payloadKg,
      final VehicleStatus status,
      final String? assignedDriverId,
      @NullableTimestampConverter() final DateTime? licenceExpiresAt,
      final String? notes,
      final bool isDeleted,
      @NullableTimestampConverter() final DateTime? deletedAt,
      @NullableTimestampConverter() final DateTime? createdAt,
      @NullableTimestampConverter() final DateTime? updatedAt}) = _$VehicleImpl;
  const _Vehicle._() : super._();

  factory _Vehicle.fromJson(Map<String, dynamic> json) = _$VehicleImpl.fromJson;

  @override
  String get id;
  @override
  String get tenantId;
  @override
  VehicleType get type;
  @override

  /// What the team calls it, e.g. "Bakkie 2".
  String get name;
  @override

  /// Number plate, stored upper-case without extra spaces.
  String get registration;
  @override
  String? get make;
  @override
  String? get model;
  @override
  int? get year;
  @override

  /// Load volume, for matching jobs to vehicles.
  double? get capacityM3;
  @override
  int? get payloadKg;
  @override
  VehicleStatus get status;
  @override

  /// The driver who usually drives it (not for trailers).
  String? get assignedDriverId;
  @override

  /// Licence disc expiry — renewed every year.
  @NullableTimestampConverter()
  DateTime? get licenceExpiresAt;
  @override
  String? get notes;
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
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$VehicleImplCopyWith<_$VehicleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
