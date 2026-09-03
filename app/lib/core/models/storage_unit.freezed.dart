// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'storage_unit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

StorageUnit _$StorageUnitFromJson(Map<String, dynamic> json) {
  return _StorageUnit.fromJson(json);
}

/// @nodoc
mixin _$StorageUnit {
  String get id => throw _privateConstructorUsedError;
  String get tenantId => throw _privateConstructorUsedError;
  String get clientId => throw _privateConstructorUsedError;
  String get qrCodeId => throw _privateConstructorUsedError;
  String? get parentId => throw _privateConstructorUsedError;
  UnitType get type => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  StorageStatus get status => throw _privateConstructorUsedError;
  List<String> get photoIds => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  double? get weight => throw _privateConstructorUsedError;
  String? get jobId => throw _privateConstructorUsedError;
  String? get warehouseLocationId => throw _privateConstructorUsedError;
  bool get isDeleted => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get deletedAt => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $StorageUnitCopyWith<StorageUnit> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StorageUnitCopyWith<$Res> {
  factory $StorageUnitCopyWith(
          StorageUnit value, $Res Function(StorageUnit) then) =
      _$StorageUnitCopyWithImpl<$Res, StorageUnit>;
  @useResult
  $Res call(
      {String id,
      String tenantId,
      String clientId,
      String qrCodeId,
      String? parentId,
      UnitType type,
      String label,
      String? description,
      StorageStatus status,
      List<String> photoIds,
      List<String> tags,
      String? category,
      double? weight,
      String? jobId,
      String? warehouseLocationId,
      bool isDeleted,
      @NullableTimestampConverter() DateTime? deletedAt,
      @NullableTimestampConverter() DateTime? createdAt,
      @NullableTimestampConverter() DateTime? updatedAt});
}

/// @nodoc
class _$StorageUnitCopyWithImpl<$Res, $Val extends StorageUnit>
    implements $StorageUnitCopyWith<$Res> {
  _$StorageUnitCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? clientId = null,
    Object? qrCodeId = null,
    Object? parentId = freezed,
    Object? type = null,
    Object? label = null,
    Object? description = freezed,
    Object? status = null,
    Object? photoIds = null,
    Object? tags = null,
    Object? category = freezed,
    Object? weight = freezed,
    Object? jobId = freezed,
    Object? warehouseLocationId = freezed,
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
      clientId: null == clientId
          ? _value.clientId
          : clientId // ignore: cast_nullable_to_non_nullable
              as String,
      qrCodeId: null == qrCodeId
          ? _value.qrCodeId
          : qrCodeId // ignore: cast_nullable_to_non_nullable
              as String,
      parentId: freezed == parentId
          ? _value.parentId
          : parentId // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as UnitType,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as StorageStatus,
      photoIds: null == photoIds
          ? _value.photoIds
          : photoIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double?,
      jobId: freezed == jobId
          ? _value.jobId
          : jobId // ignore: cast_nullable_to_non_nullable
              as String?,
      warehouseLocationId: freezed == warehouseLocationId
          ? _value.warehouseLocationId
          : warehouseLocationId // ignore: cast_nullable_to_non_nullable
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
abstract class _$$StorageUnitImplCopyWith<$Res>
    implements $StorageUnitCopyWith<$Res> {
  factory _$$StorageUnitImplCopyWith(
          _$StorageUnitImpl value, $Res Function(_$StorageUnitImpl) then) =
      __$$StorageUnitImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String tenantId,
      String clientId,
      String qrCodeId,
      String? parentId,
      UnitType type,
      String label,
      String? description,
      StorageStatus status,
      List<String> photoIds,
      List<String> tags,
      String? category,
      double? weight,
      String? jobId,
      String? warehouseLocationId,
      bool isDeleted,
      @NullableTimestampConverter() DateTime? deletedAt,
      @NullableTimestampConverter() DateTime? createdAt,
      @NullableTimestampConverter() DateTime? updatedAt});
}

/// @nodoc
class __$$StorageUnitImplCopyWithImpl<$Res>
    extends _$StorageUnitCopyWithImpl<$Res, _$StorageUnitImpl>
    implements _$$StorageUnitImplCopyWith<$Res> {
  __$$StorageUnitImplCopyWithImpl(
      _$StorageUnitImpl _value, $Res Function(_$StorageUnitImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? clientId = null,
    Object? qrCodeId = null,
    Object? parentId = freezed,
    Object? type = null,
    Object? label = null,
    Object? description = freezed,
    Object? status = null,
    Object? photoIds = null,
    Object? tags = null,
    Object? category = freezed,
    Object? weight = freezed,
    Object? jobId = freezed,
    Object? warehouseLocationId = freezed,
    Object? isDeleted = null,
    Object? deletedAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$StorageUnitImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tenantId: null == tenantId
          ? _value.tenantId
          : tenantId // ignore: cast_nullable_to_non_nullable
              as String,
      clientId: null == clientId
          ? _value.clientId
          : clientId // ignore: cast_nullable_to_non_nullable
              as String,
      qrCodeId: null == qrCodeId
          ? _value.qrCodeId
          : qrCodeId // ignore: cast_nullable_to_non_nullable
              as String,
      parentId: freezed == parentId
          ? _value.parentId
          : parentId // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as UnitType,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as StorageStatus,
      photoIds: null == photoIds
          ? _value._photoIds
          : photoIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double?,
      jobId: freezed == jobId
          ? _value.jobId
          : jobId // ignore: cast_nullable_to_non_nullable
              as String?,
      warehouseLocationId: freezed == warehouseLocationId
          ? _value.warehouseLocationId
          : warehouseLocationId // ignore: cast_nullable_to_non_nullable
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
class _$StorageUnitImpl implements _StorageUnit {
  const _$StorageUnitImpl(
      {required this.id,
      required this.tenantId,
      required this.clientId,
      this.qrCodeId = '',
      this.parentId,
      this.type = UnitType.closed,
      this.label = '',
      this.description,
      this.status = StorageStatus.pendingPickup,
      final List<String> photoIds = const [],
      final List<String> tags = const [],
      this.category,
      this.weight,
      this.jobId,
      this.warehouseLocationId,
      this.isDeleted = false,
      @NullableTimestampConverter() this.deletedAt,
      @NullableTimestampConverter() this.createdAt,
      @NullableTimestampConverter() this.updatedAt})
      : _photoIds = photoIds,
        _tags = tags;

  factory _$StorageUnitImpl.fromJson(Map<String, dynamic> json) =>
      _$$StorageUnitImplFromJson(json);

  @override
  final String id;
  @override
  final String tenantId;
  @override
  final String clientId;
  @override
  @JsonKey()
  final String qrCodeId;
  @override
  final String? parentId;
  @override
  @JsonKey()
  final UnitType type;
  @override
  @JsonKey()
  final String label;
  @override
  final String? description;
  @override
  @JsonKey()
  final StorageStatus status;
  final List<String> _photoIds;
  @override
  @JsonKey()
  List<String> get photoIds {
    if (_photoIds is EqualUnmodifiableListView) return _photoIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_photoIds);
  }

  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  final String? category;
  @override
  final double? weight;
  @override
  final String? jobId;
  @override
  final String? warehouseLocationId;
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
    return 'StorageUnit(id: $id, tenantId: $tenantId, clientId: $clientId, qrCodeId: $qrCodeId, parentId: $parentId, type: $type, label: $label, description: $description, status: $status, photoIds: $photoIds, tags: $tags, category: $category, weight: $weight, jobId: $jobId, warehouseLocationId: $warehouseLocationId, isDeleted: $isDeleted, deletedAt: $deletedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StorageUnitImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.clientId, clientId) ||
                other.clientId == clientId) &&
            (identical(other.qrCodeId, qrCodeId) ||
                other.qrCodeId == qrCodeId) &&
            (identical(other.parentId, parentId) ||
                other.parentId == parentId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._photoIds, _photoIds) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.jobId, jobId) || other.jobId == jobId) &&
            (identical(other.warehouseLocationId, warehouseLocationId) ||
                other.warehouseLocationId == warehouseLocationId) &&
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
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        tenantId,
        clientId,
        qrCodeId,
        parentId,
        type,
        label,
        description,
        status,
        const DeepCollectionEquality().hash(_photoIds),
        const DeepCollectionEquality().hash(_tags),
        category,
        weight,
        jobId,
        warehouseLocationId,
        isDeleted,
        deletedAt,
        createdAt,
        updatedAt
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$StorageUnitImplCopyWith<_$StorageUnitImpl> get copyWith =>
      __$$StorageUnitImplCopyWithImpl<_$StorageUnitImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StorageUnitImplToJson(
      this,
    );
  }
}

abstract class _StorageUnit implements StorageUnit {
  const factory _StorageUnit(
          {required final String id,
          required final String tenantId,
          required final String clientId,
          final String qrCodeId,
          final String? parentId,
          final UnitType type,
          final String label,
          final String? description,
          final StorageStatus status,
          final List<String> photoIds,
          final List<String> tags,
          final String? category,
          final double? weight,
          final String? jobId,
          final String? warehouseLocationId,
          final bool isDeleted,
          @NullableTimestampConverter() final DateTime? deletedAt,
          @NullableTimestampConverter() final DateTime? createdAt,
          @NullableTimestampConverter() final DateTime? updatedAt}) =
      _$StorageUnitImpl;

  factory _StorageUnit.fromJson(Map<String, dynamic> json) =
      _$StorageUnitImpl.fromJson;

  @override
  String get id;
  @override
  String get tenantId;
  @override
  String get clientId;
  @override
  String get qrCodeId;
  @override
  String? get parentId;
  @override
  UnitType get type;
  @override
  String get label;
  @override
  String? get description;
  @override
  StorageStatus get status;
  @override
  List<String> get photoIds;
  @override
  List<String> get tags;
  @override
  String? get category;
  @override
  double? get weight;
  @override
  String? get jobId;
  @override
  String? get warehouseLocationId;
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
  _$$StorageUnitImplCopyWith<_$StorageUnitImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
