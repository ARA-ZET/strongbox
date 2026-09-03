// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'driver_shift.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DriverShift _$DriverShiftFromJson(Map<String, dynamic> json) {
  return _DriverShift.fromJson(json);
}

/// @nodoc
mixin _$DriverShift {
  String get id => throw _privateConstructorUsedError;
  String get tenantId => throw _privateConstructorUsedError;
  String get driverId => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get startedAt => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get endedAt => throw _privateConstructorUsedError;
  List<BreakPeriod> get breakPeriods => throw _privateConstructorUsedError;
  String? get vehicleId => throw _privateConstructorUsedError;
  String get eIdQrCode => throw _privateConstructorUsedError;
  List<String> get jobIds => throw _privateConstructorUsedError;
  ShiftStatus get status => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DriverShiftCopyWith<DriverShift> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DriverShiftCopyWith<$Res> {
  factory $DriverShiftCopyWith(
          DriverShift value, $Res Function(DriverShift) then) =
      _$DriverShiftCopyWithImpl<$Res, DriverShift>;
  @useResult
  $Res call(
      {String id,
      String tenantId,
      String driverId,
      @NullableTimestampConverter() DateTime? startedAt,
      @NullableTimestampConverter() DateTime? endedAt,
      List<BreakPeriod> breakPeriods,
      String? vehicleId,
      String eIdQrCode,
      List<String> jobIds,
      ShiftStatus status});
}

/// @nodoc
class _$DriverShiftCopyWithImpl<$Res, $Val extends DriverShift>
    implements $DriverShiftCopyWith<$Res> {
  _$DriverShiftCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? driverId = null,
    Object? startedAt = freezed,
    Object? endedAt = freezed,
    Object? breakPeriods = null,
    Object? vehicleId = freezed,
    Object? eIdQrCode = null,
    Object? jobIds = null,
    Object? status = null,
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
      driverId: null == driverId
          ? _value.driverId
          : driverId // ignore: cast_nullable_to_non_nullable
              as String,
      startedAt: freezed == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endedAt: freezed == endedAt
          ? _value.endedAt
          : endedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      breakPeriods: null == breakPeriods
          ? _value.breakPeriods
          : breakPeriods // ignore: cast_nullable_to_non_nullable
              as List<BreakPeriod>,
      vehicleId: freezed == vehicleId
          ? _value.vehicleId
          : vehicleId // ignore: cast_nullable_to_non_nullable
              as String?,
      eIdQrCode: null == eIdQrCode
          ? _value.eIdQrCode
          : eIdQrCode // ignore: cast_nullable_to_non_nullable
              as String,
      jobIds: null == jobIds
          ? _value.jobIds
          : jobIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ShiftStatus,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DriverShiftImplCopyWith<$Res>
    implements $DriverShiftCopyWith<$Res> {
  factory _$$DriverShiftImplCopyWith(
          _$DriverShiftImpl value, $Res Function(_$DriverShiftImpl) then) =
      __$$DriverShiftImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String tenantId,
      String driverId,
      @NullableTimestampConverter() DateTime? startedAt,
      @NullableTimestampConverter() DateTime? endedAt,
      List<BreakPeriod> breakPeriods,
      String? vehicleId,
      String eIdQrCode,
      List<String> jobIds,
      ShiftStatus status});
}

/// @nodoc
class __$$DriverShiftImplCopyWithImpl<$Res>
    extends _$DriverShiftCopyWithImpl<$Res, _$DriverShiftImpl>
    implements _$$DriverShiftImplCopyWith<$Res> {
  __$$DriverShiftImplCopyWithImpl(
      _$DriverShiftImpl _value, $Res Function(_$DriverShiftImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? driverId = null,
    Object? startedAt = freezed,
    Object? endedAt = freezed,
    Object? breakPeriods = null,
    Object? vehicleId = freezed,
    Object? eIdQrCode = null,
    Object? jobIds = null,
    Object? status = null,
  }) {
    return _then(_$DriverShiftImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tenantId: null == tenantId
          ? _value.tenantId
          : tenantId // ignore: cast_nullable_to_non_nullable
              as String,
      driverId: null == driverId
          ? _value.driverId
          : driverId // ignore: cast_nullable_to_non_nullable
              as String,
      startedAt: freezed == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endedAt: freezed == endedAt
          ? _value.endedAt
          : endedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      breakPeriods: null == breakPeriods
          ? _value._breakPeriods
          : breakPeriods // ignore: cast_nullable_to_non_nullable
              as List<BreakPeriod>,
      vehicleId: freezed == vehicleId
          ? _value.vehicleId
          : vehicleId // ignore: cast_nullable_to_non_nullable
              as String?,
      eIdQrCode: null == eIdQrCode
          ? _value.eIdQrCode
          : eIdQrCode // ignore: cast_nullable_to_non_nullable
              as String,
      jobIds: null == jobIds
          ? _value._jobIds
          : jobIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ShiftStatus,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DriverShiftImpl extends _DriverShift {
  const _$DriverShiftImpl(
      {required this.id,
      required this.tenantId,
      required this.driverId,
      @NullableTimestampConverter() this.startedAt,
      @NullableTimestampConverter() this.endedAt,
      final List<BreakPeriod> breakPeriods = const [],
      this.vehicleId,
      this.eIdQrCode = '',
      final List<String> jobIds = const [],
      this.status = ShiftStatus.active})
      : _breakPeriods = breakPeriods,
        _jobIds = jobIds,
        super._();

  factory _$DriverShiftImpl.fromJson(Map<String, dynamic> json) =>
      _$$DriverShiftImplFromJson(json);

  @override
  final String id;
  @override
  final String tenantId;
  @override
  final String driverId;
  @override
  @NullableTimestampConverter()
  final DateTime? startedAt;
  @override
  @NullableTimestampConverter()
  final DateTime? endedAt;
  final List<BreakPeriod> _breakPeriods;
  @override
  @JsonKey()
  List<BreakPeriod> get breakPeriods {
    if (_breakPeriods is EqualUnmodifiableListView) return _breakPeriods;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_breakPeriods);
  }

  @override
  final String? vehicleId;
  @override
  @JsonKey()
  final String eIdQrCode;
  final List<String> _jobIds;
  @override
  @JsonKey()
  List<String> get jobIds {
    if (_jobIds is EqualUnmodifiableListView) return _jobIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_jobIds);
  }

  @override
  @JsonKey()
  final ShiftStatus status;

  @override
  String toString() {
    return 'DriverShift(id: $id, tenantId: $tenantId, driverId: $driverId, startedAt: $startedAt, endedAt: $endedAt, breakPeriods: $breakPeriods, vehicleId: $vehicleId, eIdQrCode: $eIdQrCode, jobIds: $jobIds, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DriverShiftImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.driverId, driverId) ||
                other.driverId == driverId) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.endedAt, endedAt) || other.endedAt == endedAt) &&
            const DeepCollectionEquality()
                .equals(other._breakPeriods, _breakPeriods) &&
            (identical(other.vehicleId, vehicleId) ||
                other.vehicleId == vehicleId) &&
            (identical(other.eIdQrCode, eIdQrCode) ||
                other.eIdQrCode == eIdQrCode) &&
            const DeepCollectionEquality().equals(other._jobIds, _jobIds) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      tenantId,
      driverId,
      startedAt,
      endedAt,
      const DeepCollectionEquality().hash(_breakPeriods),
      vehicleId,
      eIdQrCode,
      const DeepCollectionEquality().hash(_jobIds),
      status);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DriverShiftImplCopyWith<_$DriverShiftImpl> get copyWith =>
      __$$DriverShiftImplCopyWithImpl<_$DriverShiftImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DriverShiftImplToJson(
      this,
    );
  }
}

abstract class _DriverShift extends DriverShift {
  const factory _DriverShift(
      {required final String id,
      required final String tenantId,
      required final String driverId,
      @NullableTimestampConverter() final DateTime? startedAt,
      @NullableTimestampConverter() final DateTime? endedAt,
      final List<BreakPeriod> breakPeriods,
      final String? vehicleId,
      final String eIdQrCode,
      final List<String> jobIds,
      final ShiftStatus status}) = _$DriverShiftImpl;
  const _DriverShift._() : super._();

  factory _DriverShift.fromJson(Map<String, dynamic> json) =
      _$DriverShiftImpl.fromJson;

  @override
  String get id;
  @override
  String get tenantId;
  @override
  String get driverId;
  @override
  @NullableTimestampConverter()
  DateTime? get startedAt;
  @override
  @NullableTimestampConverter()
  DateTime? get endedAt;
  @override
  List<BreakPeriod> get breakPeriods;
  @override
  String? get vehicleId;
  @override
  String get eIdQrCode;
  @override
  List<String> get jobIds;
  @override
  ShiftStatus get status;
  @override
  @JsonKey(ignore: true)
  _$$DriverShiftImplCopyWith<_$DriverShiftImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
