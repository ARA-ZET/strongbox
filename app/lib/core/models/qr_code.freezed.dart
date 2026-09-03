// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'qr_code.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

QRCode _$QRCodeFromJson(Map<String, dynamic> json) {
  return _QRCode.fromJson(json);
}

/// @nodoc
mixin _$QRCode {
  String get id => throw _privateConstructorUsedError;
  String get tenantId => throw _privateConstructorUsedError;
  String get batchId => throw _privateConstructorUsedError;
  String? get storageUnitId => throw _privateConstructorUsedError;
  bool get isLinked => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get linkedAt => throw _privateConstructorUsedError;
  String? get linkedBy => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $QRCodeCopyWith<QRCode> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QRCodeCopyWith<$Res> {
  factory $QRCodeCopyWith(QRCode value, $Res Function(QRCode) then) =
      _$QRCodeCopyWithImpl<$Res, QRCode>;
  @useResult
  $Res call(
      {String id,
      String tenantId,
      String batchId,
      String? storageUnitId,
      bool isLinked,
      @NullableTimestampConverter() DateTime? linkedAt,
      String? linkedBy,
      @NullableTimestampConverter() DateTime? createdAt});
}

/// @nodoc
class _$QRCodeCopyWithImpl<$Res, $Val extends QRCode>
    implements $QRCodeCopyWith<$Res> {
  _$QRCodeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? batchId = null,
    Object? storageUnitId = freezed,
    Object? isLinked = null,
    Object? linkedAt = freezed,
    Object? linkedBy = freezed,
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
      batchId: null == batchId
          ? _value.batchId
          : batchId // ignore: cast_nullable_to_non_nullable
              as String,
      storageUnitId: freezed == storageUnitId
          ? _value.storageUnitId
          : storageUnitId // ignore: cast_nullable_to_non_nullable
              as String?,
      isLinked: null == isLinked
          ? _value.isLinked
          : isLinked // ignore: cast_nullable_to_non_nullable
              as bool,
      linkedAt: freezed == linkedAt
          ? _value.linkedAt
          : linkedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      linkedBy: freezed == linkedBy
          ? _value.linkedBy
          : linkedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QRCodeImplCopyWith<$Res> implements $QRCodeCopyWith<$Res> {
  factory _$$QRCodeImplCopyWith(
          _$QRCodeImpl value, $Res Function(_$QRCodeImpl) then) =
      __$$QRCodeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String tenantId,
      String batchId,
      String? storageUnitId,
      bool isLinked,
      @NullableTimestampConverter() DateTime? linkedAt,
      String? linkedBy,
      @NullableTimestampConverter() DateTime? createdAt});
}

/// @nodoc
class __$$QRCodeImplCopyWithImpl<$Res>
    extends _$QRCodeCopyWithImpl<$Res, _$QRCodeImpl>
    implements _$$QRCodeImplCopyWith<$Res> {
  __$$QRCodeImplCopyWithImpl(
      _$QRCodeImpl _value, $Res Function(_$QRCodeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? batchId = null,
    Object? storageUnitId = freezed,
    Object? isLinked = null,
    Object? linkedAt = freezed,
    Object? linkedBy = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$QRCodeImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tenantId: null == tenantId
          ? _value.tenantId
          : tenantId // ignore: cast_nullable_to_non_nullable
              as String,
      batchId: null == batchId
          ? _value.batchId
          : batchId // ignore: cast_nullable_to_non_nullable
              as String,
      storageUnitId: freezed == storageUnitId
          ? _value.storageUnitId
          : storageUnitId // ignore: cast_nullable_to_non_nullable
              as String?,
      isLinked: null == isLinked
          ? _value.isLinked
          : isLinked // ignore: cast_nullable_to_non_nullable
              as bool,
      linkedAt: freezed == linkedAt
          ? _value.linkedAt
          : linkedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      linkedBy: freezed == linkedBy
          ? _value.linkedBy
          : linkedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$QRCodeImpl implements _QRCode {
  const _$QRCodeImpl(
      {required this.id,
      required this.tenantId,
      this.batchId = '',
      this.storageUnitId,
      this.isLinked = false,
      @NullableTimestampConverter() this.linkedAt,
      this.linkedBy,
      @NullableTimestampConverter() this.createdAt});

  factory _$QRCodeImpl.fromJson(Map<String, dynamic> json) =>
      _$$QRCodeImplFromJson(json);

  @override
  final String id;
  @override
  final String tenantId;
  @override
  @JsonKey()
  final String batchId;
  @override
  final String? storageUnitId;
  @override
  @JsonKey()
  final bool isLinked;
  @override
  @NullableTimestampConverter()
  final DateTime? linkedAt;
  @override
  final String? linkedBy;
  @override
  @NullableTimestampConverter()
  final DateTime? createdAt;

  @override
  String toString() {
    return 'QRCode(id: $id, tenantId: $tenantId, batchId: $batchId, storageUnitId: $storageUnitId, isLinked: $isLinked, linkedAt: $linkedAt, linkedBy: $linkedBy, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QRCodeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.batchId, batchId) || other.batchId == batchId) &&
            (identical(other.storageUnitId, storageUnitId) ||
                other.storageUnitId == storageUnitId) &&
            (identical(other.isLinked, isLinked) ||
                other.isLinked == isLinked) &&
            (identical(other.linkedAt, linkedAt) ||
                other.linkedAt == linkedAt) &&
            (identical(other.linkedBy, linkedBy) ||
                other.linkedBy == linkedBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, tenantId, batchId,
      storageUnitId, isLinked, linkedAt, linkedBy, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$QRCodeImplCopyWith<_$QRCodeImpl> get copyWith =>
      __$$QRCodeImplCopyWithImpl<_$QRCodeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QRCodeImplToJson(
      this,
    );
  }
}

abstract class _QRCode implements QRCode {
  const factory _QRCode(
      {required final String id,
      required final String tenantId,
      final String batchId,
      final String? storageUnitId,
      final bool isLinked,
      @NullableTimestampConverter() final DateTime? linkedAt,
      final String? linkedBy,
      @NullableTimestampConverter() final DateTime? createdAt}) = _$QRCodeImpl;

  factory _QRCode.fromJson(Map<String, dynamic> json) = _$QRCodeImpl.fromJson;

  @override
  String get id;
  @override
  String get tenantId;
  @override
  String get batchId;
  @override
  String? get storageUnitId;
  @override
  bool get isLinked;
  @override
  @NullableTimestampConverter()
  DateTime? get linkedAt;
  @override
  String? get linkedBy;
  @override
  @NullableTimestampConverter()
  DateTime? get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$QRCodeImplCopyWith<_$QRCodeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

QRBatch _$QRBatchFromJson(Map<String, dynamic> json) {
  return _QRBatch.fromJson(json);
}

/// @nodoc
mixin _$QRBatch {
  String get id => throw _privateConstructorUsedError;
  String get tenantId => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;
  List<String> get codeIds => throw _privateConstructorUsedError;
  int get linkedCount => throw _privateConstructorUsedError;
  String get printResolution => throw _privateConstructorUsedError;
  String get createdBy => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $QRBatchCopyWith<QRBatch> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QRBatchCopyWith<$Res> {
  factory $QRBatchCopyWith(QRBatch value, $Res Function(QRBatch) then) =
      _$QRBatchCopyWithImpl<$Res, QRBatch>;
  @useResult
  $Res call(
      {String id,
      String tenantId,
      int count,
      List<String> codeIds,
      int linkedCount,
      String printResolution,
      String createdBy,
      @NullableTimestampConverter() DateTime? createdAt});
}

/// @nodoc
class _$QRBatchCopyWithImpl<$Res, $Val extends QRBatch>
    implements $QRBatchCopyWith<$Res> {
  _$QRBatchCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? count = null,
    Object? codeIds = null,
    Object? linkedCount = null,
    Object? printResolution = null,
    Object? createdBy = null,
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
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      codeIds: null == codeIds
          ? _value.codeIds
          : codeIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      linkedCount: null == linkedCount
          ? _value.linkedCount
          : linkedCount // ignore: cast_nullable_to_non_nullable
              as int,
      printResolution: null == printResolution
          ? _value.printResolution
          : printResolution // ignore: cast_nullable_to_non_nullable
              as String,
      createdBy: null == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QRBatchImplCopyWith<$Res> implements $QRBatchCopyWith<$Res> {
  factory _$$QRBatchImplCopyWith(
          _$QRBatchImpl value, $Res Function(_$QRBatchImpl) then) =
      __$$QRBatchImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String tenantId,
      int count,
      List<String> codeIds,
      int linkedCount,
      String printResolution,
      String createdBy,
      @NullableTimestampConverter() DateTime? createdAt});
}

/// @nodoc
class __$$QRBatchImplCopyWithImpl<$Res>
    extends _$QRBatchCopyWithImpl<$Res, _$QRBatchImpl>
    implements _$$QRBatchImplCopyWith<$Res> {
  __$$QRBatchImplCopyWithImpl(
      _$QRBatchImpl _value, $Res Function(_$QRBatchImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? count = null,
    Object? codeIds = null,
    Object? linkedCount = null,
    Object? printResolution = null,
    Object? createdBy = null,
    Object? createdAt = freezed,
  }) {
    return _then(_$QRBatchImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tenantId: null == tenantId
          ? _value.tenantId
          : tenantId // ignore: cast_nullable_to_non_nullable
              as String,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      codeIds: null == codeIds
          ? _value._codeIds
          : codeIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      linkedCount: null == linkedCount
          ? _value.linkedCount
          : linkedCount // ignore: cast_nullable_to_non_nullable
              as int,
      printResolution: null == printResolution
          ? _value.printResolution
          : printResolution // ignore: cast_nullable_to_non_nullable
              as String,
      createdBy: null == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$QRBatchImpl implements _QRBatch {
  const _$QRBatchImpl(
      {required this.id,
      required this.tenantId,
      this.count = 0,
      final List<String> codeIds = const [],
      this.linkedCount = 0,
      this.printResolution = '300dpi',
      this.createdBy = '',
      @NullableTimestampConverter() this.createdAt})
      : _codeIds = codeIds;

  factory _$QRBatchImpl.fromJson(Map<String, dynamic> json) =>
      _$$QRBatchImplFromJson(json);

  @override
  final String id;
  @override
  final String tenantId;
  @override
  @JsonKey()
  final int count;
  final List<String> _codeIds;
  @override
  @JsonKey()
  List<String> get codeIds {
    if (_codeIds is EqualUnmodifiableListView) return _codeIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_codeIds);
  }

  @override
  @JsonKey()
  final int linkedCount;
  @override
  @JsonKey()
  final String printResolution;
  @override
  @JsonKey()
  final String createdBy;
  @override
  @NullableTimestampConverter()
  final DateTime? createdAt;

  @override
  String toString() {
    return 'QRBatch(id: $id, tenantId: $tenantId, count: $count, codeIds: $codeIds, linkedCount: $linkedCount, printResolution: $printResolution, createdBy: $createdBy, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QRBatchImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.count, count) || other.count == count) &&
            const DeepCollectionEquality().equals(other._codeIds, _codeIds) &&
            (identical(other.linkedCount, linkedCount) ||
                other.linkedCount == linkedCount) &&
            (identical(other.printResolution, printResolution) ||
                other.printResolution == printResolution) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      tenantId,
      count,
      const DeepCollectionEquality().hash(_codeIds),
      linkedCount,
      printResolution,
      createdBy,
      createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$QRBatchImplCopyWith<_$QRBatchImpl> get copyWith =>
      __$$QRBatchImplCopyWithImpl<_$QRBatchImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QRBatchImplToJson(
      this,
    );
  }
}

abstract class _QRBatch implements QRBatch {
  const factory _QRBatch(
      {required final String id,
      required final String tenantId,
      final int count,
      final List<String> codeIds,
      final int linkedCount,
      final String printResolution,
      final String createdBy,
      @NullableTimestampConverter() final DateTime? createdAt}) = _$QRBatchImpl;

  factory _QRBatch.fromJson(Map<String, dynamic> json) = _$QRBatchImpl.fromJson;

  @override
  String get id;
  @override
  String get tenantId;
  @override
  int get count;
  @override
  List<String> get codeIds;
  @override
  int get linkedCount;
  @override
  String get printResolution;
  @override
  String get createdBy;
  @override
  @NullableTimestampConverter()
  DateTime? get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$QRBatchImplCopyWith<_$QRBatchImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
