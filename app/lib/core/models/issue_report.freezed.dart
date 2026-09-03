// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'issue_report.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

IssueReport _$IssueReportFromJson(Map<String, dynamic> json) {
  return _IssueReport.fromJson(json);
}

/// @nodoc
mixin _$IssueReport {
  String get id => throw _privateConstructorUsedError;
  String get tenantId => throw _privateConstructorUsedError;
  String get driverId => throw _privateConstructorUsedError;
  String? get jobId => throw _privateConstructorUsedError;
  IssueType get issueType => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  List<String> get photoIds => throw _privateConstructorUsedError;
  String? get relatedQrCode => throw _privateConstructorUsedError;
  bool get isUrgent => throw _privateConstructorUsedError;
  IssueStatus get status => throw _privateConstructorUsedError;
  String? get resolvedBy => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get resolvedAt => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $IssueReportCopyWith<IssueReport> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IssueReportCopyWith<$Res> {
  factory $IssueReportCopyWith(
          IssueReport value, $Res Function(IssueReport) then) =
      _$IssueReportCopyWithImpl<$Res, IssueReport>;
  @useResult
  $Res call(
      {String id,
      String tenantId,
      String driverId,
      String? jobId,
      IssueType issueType,
      String description,
      List<String> photoIds,
      String? relatedQrCode,
      bool isUrgent,
      IssueStatus status,
      String? resolvedBy,
      @NullableTimestampConverter() DateTime? resolvedAt,
      @NullableTimestampConverter() DateTime? createdAt});
}

/// @nodoc
class _$IssueReportCopyWithImpl<$Res, $Val extends IssueReport>
    implements $IssueReportCopyWith<$Res> {
  _$IssueReportCopyWithImpl(this._value, this._then);

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
    Object? jobId = freezed,
    Object? issueType = null,
    Object? description = null,
    Object? photoIds = null,
    Object? relatedQrCode = freezed,
    Object? isUrgent = null,
    Object? status = null,
    Object? resolvedBy = freezed,
    Object? resolvedAt = freezed,
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
      driverId: null == driverId
          ? _value.driverId
          : driverId // ignore: cast_nullable_to_non_nullable
              as String,
      jobId: freezed == jobId
          ? _value.jobId
          : jobId // ignore: cast_nullable_to_non_nullable
              as String?,
      issueType: null == issueType
          ? _value.issueType
          : issueType // ignore: cast_nullable_to_non_nullable
              as IssueType,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      photoIds: null == photoIds
          ? _value.photoIds
          : photoIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      relatedQrCode: freezed == relatedQrCode
          ? _value.relatedQrCode
          : relatedQrCode // ignore: cast_nullable_to_non_nullable
              as String?,
      isUrgent: null == isUrgent
          ? _value.isUrgent
          : isUrgent // ignore: cast_nullable_to_non_nullable
              as bool,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as IssueStatus,
      resolvedBy: freezed == resolvedBy
          ? _value.resolvedBy
          : resolvedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      resolvedAt: freezed == resolvedAt
          ? _value.resolvedAt
          : resolvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$IssueReportImplCopyWith<$Res>
    implements $IssueReportCopyWith<$Res> {
  factory _$$IssueReportImplCopyWith(
          _$IssueReportImpl value, $Res Function(_$IssueReportImpl) then) =
      __$$IssueReportImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String tenantId,
      String driverId,
      String? jobId,
      IssueType issueType,
      String description,
      List<String> photoIds,
      String? relatedQrCode,
      bool isUrgent,
      IssueStatus status,
      String? resolvedBy,
      @NullableTimestampConverter() DateTime? resolvedAt,
      @NullableTimestampConverter() DateTime? createdAt});
}

/// @nodoc
class __$$IssueReportImplCopyWithImpl<$Res>
    extends _$IssueReportCopyWithImpl<$Res, _$IssueReportImpl>
    implements _$$IssueReportImplCopyWith<$Res> {
  __$$IssueReportImplCopyWithImpl(
      _$IssueReportImpl _value, $Res Function(_$IssueReportImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? driverId = null,
    Object? jobId = freezed,
    Object? issueType = null,
    Object? description = null,
    Object? photoIds = null,
    Object? relatedQrCode = freezed,
    Object? isUrgent = null,
    Object? status = null,
    Object? resolvedBy = freezed,
    Object? resolvedAt = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$IssueReportImpl(
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
      jobId: freezed == jobId
          ? _value.jobId
          : jobId // ignore: cast_nullable_to_non_nullable
              as String?,
      issueType: null == issueType
          ? _value.issueType
          : issueType // ignore: cast_nullable_to_non_nullable
              as IssueType,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      photoIds: null == photoIds
          ? _value._photoIds
          : photoIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      relatedQrCode: freezed == relatedQrCode
          ? _value.relatedQrCode
          : relatedQrCode // ignore: cast_nullable_to_non_nullable
              as String?,
      isUrgent: null == isUrgent
          ? _value.isUrgent
          : isUrgent // ignore: cast_nullable_to_non_nullable
              as bool,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as IssueStatus,
      resolvedBy: freezed == resolvedBy
          ? _value.resolvedBy
          : resolvedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      resolvedAt: freezed == resolvedAt
          ? _value.resolvedAt
          : resolvedAt // ignore: cast_nullable_to_non_nullable
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
class _$IssueReportImpl implements _IssueReport {
  const _$IssueReportImpl(
      {required this.id,
      required this.tenantId,
      required this.driverId,
      this.jobId,
      this.issueType = IssueType.other,
      this.description = '',
      final List<String> photoIds = const [],
      this.relatedQrCode,
      this.isUrgent = false,
      this.status = IssueStatus.open,
      this.resolvedBy,
      @NullableTimestampConverter() this.resolvedAt,
      @NullableTimestampConverter() this.createdAt})
      : _photoIds = photoIds;

  factory _$IssueReportImpl.fromJson(Map<String, dynamic> json) =>
      _$$IssueReportImplFromJson(json);

  @override
  final String id;
  @override
  final String tenantId;
  @override
  final String driverId;
  @override
  final String? jobId;
  @override
  @JsonKey()
  final IssueType issueType;
  @override
  @JsonKey()
  final String description;
  final List<String> _photoIds;
  @override
  @JsonKey()
  List<String> get photoIds {
    if (_photoIds is EqualUnmodifiableListView) return _photoIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_photoIds);
  }

  @override
  final String? relatedQrCode;
  @override
  @JsonKey()
  final bool isUrgent;
  @override
  @JsonKey()
  final IssueStatus status;
  @override
  final String? resolvedBy;
  @override
  @NullableTimestampConverter()
  final DateTime? resolvedAt;
  @override
  @NullableTimestampConverter()
  final DateTime? createdAt;

  @override
  String toString() {
    return 'IssueReport(id: $id, tenantId: $tenantId, driverId: $driverId, jobId: $jobId, issueType: $issueType, description: $description, photoIds: $photoIds, relatedQrCode: $relatedQrCode, isUrgent: $isUrgent, status: $status, resolvedBy: $resolvedBy, resolvedAt: $resolvedAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IssueReportImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.driverId, driverId) ||
                other.driverId == driverId) &&
            (identical(other.jobId, jobId) || other.jobId == jobId) &&
            (identical(other.issueType, issueType) ||
                other.issueType == issueType) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._photoIds, _photoIds) &&
            (identical(other.relatedQrCode, relatedQrCode) ||
                other.relatedQrCode == relatedQrCode) &&
            (identical(other.isUrgent, isUrgent) ||
                other.isUrgent == isUrgent) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.resolvedBy, resolvedBy) ||
                other.resolvedBy == resolvedBy) &&
            (identical(other.resolvedAt, resolvedAt) ||
                other.resolvedAt == resolvedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      tenantId,
      driverId,
      jobId,
      issueType,
      description,
      const DeepCollectionEquality().hash(_photoIds),
      relatedQrCode,
      isUrgent,
      status,
      resolvedBy,
      resolvedAt,
      createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$IssueReportImplCopyWith<_$IssueReportImpl> get copyWith =>
      __$$IssueReportImplCopyWithImpl<_$IssueReportImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$IssueReportImplToJson(
      this,
    );
  }
}

abstract class _IssueReport implements IssueReport {
  const factory _IssueReport(
          {required final String id,
          required final String tenantId,
          required final String driverId,
          final String? jobId,
          final IssueType issueType,
          final String description,
          final List<String> photoIds,
          final String? relatedQrCode,
          final bool isUrgent,
          final IssueStatus status,
          final String? resolvedBy,
          @NullableTimestampConverter() final DateTime? resolvedAt,
          @NullableTimestampConverter() final DateTime? createdAt}) =
      _$IssueReportImpl;

  factory _IssueReport.fromJson(Map<String, dynamic> json) =
      _$IssueReportImpl.fromJson;

  @override
  String get id;
  @override
  String get tenantId;
  @override
  String get driverId;
  @override
  String? get jobId;
  @override
  IssueType get issueType;
  @override
  String get description;
  @override
  List<String> get photoIds;
  @override
  String? get relatedQrCode;
  @override
  bool get isUrgent;
  @override
  IssueStatus get status;
  @override
  String? get resolvedBy;
  @override
  @NullableTimestampConverter()
  DateTime? get resolvedAt;
  @override
  @NullableTimestampConverter()
  DateTime? get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$IssueReportImplCopyWith<_$IssueReportImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
