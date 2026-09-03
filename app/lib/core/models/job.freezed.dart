// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'job.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Job _$JobFromJson(Map<String, dynamic> json) {
  return _Job.fromJson(json);
}

/// @nodoc
mixin _$Job {
  String get id => throw _privateConstructorUsedError;
  String get tenantId => throw _privateConstructorUsedError;
  JobType get type => throw _privateConstructorUsedError;
  String get clientId => throw _privateConstructorUsedError;
  String? get driverId => throw _privateConstructorUsedError;
  JobStatus get status => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get scheduledDate => throw _privateConstructorUsedError;
  TimeWindow get timeWindow => throw _privateConstructorUsedError;
  Address get address => throw _privateConstructorUsedError;
  List<String> get storageUnitIds => throw _privateConstructorUsedError;
  List<String> get scannedUnitIds => throw _privateConstructorUsedError;
  List<String> get itemIds => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get driverNotes => throw _privateConstructorUsedError;
  List<String> get photoIds => throw _privateConstructorUsedError;
  String? get clientSignatureUrl => throw _privateConstructorUsedError;
  String? get clientConfirmMethod => throw _privateConstructorUsedError;
  double? get estimatedFee => throw _privateConstructorUsedError;
  bool get isRushJob => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get completedAt => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get cancelledAt => throw _privateConstructorUsedError;
  String? get cancelReason => throw _privateConstructorUsedError;
  bool get isDeleted => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $JobCopyWith<Job> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JobCopyWith<$Res> {
  factory $JobCopyWith(Job value, $Res Function(Job) then) =
      _$JobCopyWithImpl<$Res, Job>;
  @useResult
  $Res call(
      {String id,
      String tenantId,
      JobType type,
      String clientId,
      String? driverId,
      JobStatus status,
      @NullableTimestampConverter() DateTime? scheduledDate,
      TimeWindow timeWindow,
      Address address,
      List<String> storageUnitIds,
      List<String> scannedUnitIds,
      List<String> itemIds,
      String? notes,
      String? driverNotes,
      List<String> photoIds,
      String? clientSignatureUrl,
      String? clientConfirmMethod,
      double? estimatedFee,
      bool isRushJob,
      @NullableTimestampConverter() DateTime? completedAt,
      @NullableTimestampConverter() DateTime? cancelledAt,
      String? cancelReason,
      bool isDeleted,
      @NullableTimestampConverter() DateTime? createdAt,
      @NullableTimestampConverter() DateTime? updatedAt});

  $AddressCopyWith<$Res> get address;
}

/// @nodoc
class _$JobCopyWithImpl<$Res, $Val extends Job> implements $JobCopyWith<$Res> {
  _$JobCopyWithImpl(this._value, this._then);

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
    Object? clientId = null,
    Object? driverId = freezed,
    Object? status = null,
    Object? scheduledDate = freezed,
    Object? timeWindow = null,
    Object? address = null,
    Object? storageUnitIds = null,
    Object? scannedUnitIds = null,
    Object? itemIds = null,
    Object? notes = freezed,
    Object? driverNotes = freezed,
    Object? photoIds = null,
    Object? clientSignatureUrl = freezed,
    Object? clientConfirmMethod = freezed,
    Object? estimatedFee = freezed,
    Object? isRushJob = null,
    Object? completedAt = freezed,
    Object? cancelledAt = freezed,
    Object? cancelReason = freezed,
    Object? isDeleted = null,
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
              as JobType,
      clientId: null == clientId
          ? _value.clientId
          : clientId // ignore: cast_nullable_to_non_nullable
              as String,
      driverId: freezed == driverId
          ? _value.driverId
          : driverId // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as JobStatus,
      scheduledDate: freezed == scheduledDate
          ? _value.scheduledDate
          : scheduledDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      timeWindow: null == timeWindow
          ? _value.timeWindow
          : timeWindow // ignore: cast_nullable_to_non_nullable
              as TimeWindow,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as Address,
      storageUnitIds: null == storageUnitIds
          ? _value.storageUnitIds
          : storageUnitIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      scannedUnitIds: null == scannedUnitIds
          ? _value.scannedUnitIds
          : scannedUnitIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      itemIds: null == itemIds
          ? _value.itemIds
          : itemIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      driverNotes: freezed == driverNotes
          ? _value.driverNotes
          : driverNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      photoIds: null == photoIds
          ? _value.photoIds
          : photoIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      clientSignatureUrl: freezed == clientSignatureUrl
          ? _value.clientSignatureUrl
          : clientSignatureUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      clientConfirmMethod: freezed == clientConfirmMethod
          ? _value.clientConfirmMethod
          : clientConfirmMethod // ignore: cast_nullable_to_non_nullable
              as String?,
      estimatedFee: freezed == estimatedFee
          ? _value.estimatedFee
          : estimatedFee // ignore: cast_nullable_to_non_nullable
              as double?,
      isRushJob: null == isRushJob
          ? _value.isRushJob
          : isRushJob // ignore: cast_nullable_to_non_nullable
              as bool,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      cancelledAt: freezed == cancelledAt
          ? _value.cancelledAt
          : cancelledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      cancelReason: freezed == cancelReason
          ? _value.cancelReason
          : cancelReason // ignore: cast_nullable_to_non_nullable
              as String?,
      isDeleted: null == isDeleted
          ? _value.isDeleted
          : isDeleted // ignore: cast_nullable_to_non_nullable
              as bool,
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

  @override
  @pragma('vm:prefer-inline')
  $AddressCopyWith<$Res> get address {
    return $AddressCopyWith<$Res>(_value.address, (value) {
      return _then(_value.copyWith(address: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$JobImplCopyWith<$Res> implements $JobCopyWith<$Res> {
  factory _$$JobImplCopyWith(_$JobImpl value, $Res Function(_$JobImpl) then) =
      __$$JobImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String tenantId,
      JobType type,
      String clientId,
      String? driverId,
      JobStatus status,
      @NullableTimestampConverter() DateTime? scheduledDate,
      TimeWindow timeWindow,
      Address address,
      List<String> storageUnitIds,
      List<String> scannedUnitIds,
      List<String> itemIds,
      String? notes,
      String? driverNotes,
      List<String> photoIds,
      String? clientSignatureUrl,
      String? clientConfirmMethod,
      double? estimatedFee,
      bool isRushJob,
      @NullableTimestampConverter() DateTime? completedAt,
      @NullableTimestampConverter() DateTime? cancelledAt,
      String? cancelReason,
      bool isDeleted,
      @NullableTimestampConverter() DateTime? createdAt,
      @NullableTimestampConverter() DateTime? updatedAt});

  @override
  $AddressCopyWith<$Res> get address;
}

/// @nodoc
class __$$JobImplCopyWithImpl<$Res> extends _$JobCopyWithImpl<$Res, _$JobImpl>
    implements _$$JobImplCopyWith<$Res> {
  __$$JobImplCopyWithImpl(_$JobImpl _value, $Res Function(_$JobImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? type = null,
    Object? clientId = null,
    Object? driverId = freezed,
    Object? status = null,
    Object? scheduledDate = freezed,
    Object? timeWindow = null,
    Object? address = null,
    Object? storageUnitIds = null,
    Object? scannedUnitIds = null,
    Object? itemIds = null,
    Object? notes = freezed,
    Object? driverNotes = freezed,
    Object? photoIds = null,
    Object? clientSignatureUrl = freezed,
    Object? clientConfirmMethod = freezed,
    Object? estimatedFee = freezed,
    Object? isRushJob = null,
    Object? completedAt = freezed,
    Object? cancelledAt = freezed,
    Object? cancelReason = freezed,
    Object? isDeleted = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$JobImpl(
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
              as JobType,
      clientId: null == clientId
          ? _value.clientId
          : clientId // ignore: cast_nullable_to_non_nullable
              as String,
      driverId: freezed == driverId
          ? _value.driverId
          : driverId // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as JobStatus,
      scheduledDate: freezed == scheduledDate
          ? _value.scheduledDate
          : scheduledDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      timeWindow: null == timeWindow
          ? _value.timeWindow
          : timeWindow // ignore: cast_nullable_to_non_nullable
              as TimeWindow,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as Address,
      storageUnitIds: null == storageUnitIds
          ? _value._storageUnitIds
          : storageUnitIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      scannedUnitIds: null == scannedUnitIds
          ? _value._scannedUnitIds
          : scannedUnitIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      itemIds: null == itemIds
          ? _value._itemIds
          : itemIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      driverNotes: freezed == driverNotes
          ? _value.driverNotes
          : driverNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      photoIds: null == photoIds
          ? _value._photoIds
          : photoIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      clientSignatureUrl: freezed == clientSignatureUrl
          ? _value.clientSignatureUrl
          : clientSignatureUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      clientConfirmMethod: freezed == clientConfirmMethod
          ? _value.clientConfirmMethod
          : clientConfirmMethod // ignore: cast_nullable_to_non_nullable
              as String?,
      estimatedFee: freezed == estimatedFee
          ? _value.estimatedFee
          : estimatedFee // ignore: cast_nullable_to_non_nullable
              as double?,
      isRushJob: null == isRushJob
          ? _value.isRushJob
          : isRushJob // ignore: cast_nullable_to_non_nullable
              as bool,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      cancelledAt: freezed == cancelledAt
          ? _value.cancelledAt
          : cancelledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      cancelReason: freezed == cancelReason
          ? _value.cancelReason
          : cancelReason // ignore: cast_nullable_to_non_nullable
              as String?,
      isDeleted: null == isDeleted
          ? _value.isDeleted
          : isDeleted // ignore: cast_nullable_to_non_nullable
              as bool,
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
class _$JobImpl extends _Job {
  const _$JobImpl(
      {required this.id,
      required this.tenantId,
      this.type = JobType.pickup,
      required this.clientId,
      this.driverId,
      this.status = JobStatus.scheduled,
      @NullableTimestampConverter() this.scheduledDate,
      this.timeWindow = TimeWindow.morning,
      this.address = const Address(),
      final List<String> storageUnitIds = const [],
      final List<String> scannedUnitIds = const [],
      final List<String> itemIds = const [],
      this.notes,
      this.driverNotes,
      final List<String> photoIds = const [],
      this.clientSignatureUrl,
      this.clientConfirmMethod,
      this.estimatedFee,
      this.isRushJob = false,
      @NullableTimestampConverter() this.completedAt,
      @NullableTimestampConverter() this.cancelledAt,
      this.cancelReason,
      this.isDeleted = false,
      @NullableTimestampConverter() this.createdAt,
      @NullableTimestampConverter() this.updatedAt})
      : _storageUnitIds = storageUnitIds,
        _scannedUnitIds = scannedUnitIds,
        _itemIds = itemIds,
        _photoIds = photoIds,
        super._();

  factory _$JobImpl.fromJson(Map<String, dynamic> json) =>
      _$$JobImplFromJson(json);

  @override
  final String id;
  @override
  final String tenantId;
  @override
  @JsonKey()
  final JobType type;
  @override
  final String clientId;
  @override
  final String? driverId;
  @override
  @JsonKey()
  final JobStatus status;
  @override
  @NullableTimestampConverter()
  final DateTime? scheduledDate;
  @override
  @JsonKey()
  final TimeWindow timeWindow;
  @override
  @JsonKey()
  final Address address;
  final List<String> _storageUnitIds;
  @override
  @JsonKey()
  List<String> get storageUnitIds {
    if (_storageUnitIds is EqualUnmodifiableListView) return _storageUnitIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_storageUnitIds);
  }

  final List<String> _scannedUnitIds;
  @override
  @JsonKey()
  List<String> get scannedUnitIds {
    if (_scannedUnitIds is EqualUnmodifiableListView) return _scannedUnitIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_scannedUnitIds);
  }

  final List<String> _itemIds;
  @override
  @JsonKey()
  List<String> get itemIds {
    if (_itemIds is EqualUnmodifiableListView) return _itemIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_itemIds);
  }

  @override
  final String? notes;
  @override
  final String? driverNotes;
  final List<String> _photoIds;
  @override
  @JsonKey()
  List<String> get photoIds {
    if (_photoIds is EqualUnmodifiableListView) return _photoIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_photoIds);
  }

  @override
  final String? clientSignatureUrl;
  @override
  final String? clientConfirmMethod;
  @override
  final double? estimatedFee;
  @override
  @JsonKey()
  final bool isRushJob;
  @override
  @NullableTimestampConverter()
  final DateTime? completedAt;
  @override
  @NullableTimestampConverter()
  final DateTime? cancelledAt;
  @override
  final String? cancelReason;
  @override
  @JsonKey()
  final bool isDeleted;
  @override
  @NullableTimestampConverter()
  final DateTime? createdAt;
  @override
  @NullableTimestampConverter()
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Job(id: $id, tenantId: $tenantId, type: $type, clientId: $clientId, driverId: $driverId, status: $status, scheduledDate: $scheduledDate, timeWindow: $timeWindow, address: $address, storageUnitIds: $storageUnitIds, scannedUnitIds: $scannedUnitIds, itemIds: $itemIds, notes: $notes, driverNotes: $driverNotes, photoIds: $photoIds, clientSignatureUrl: $clientSignatureUrl, clientConfirmMethod: $clientConfirmMethod, estimatedFee: $estimatedFee, isRushJob: $isRushJob, completedAt: $completedAt, cancelledAt: $cancelledAt, cancelReason: $cancelReason, isDeleted: $isDeleted, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JobImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.clientId, clientId) ||
                other.clientId == clientId) &&
            (identical(other.driverId, driverId) ||
                other.driverId == driverId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.scheduledDate, scheduledDate) ||
                other.scheduledDate == scheduledDate) &&
            (identical(other.timeWindow, timeWindow) ||
                other.timeWindow == timeWindow) &&
            (identical(other.address, address) || other.address == address) &&
            const DeepCollectionEquality()
                .equals(other._storageUnitIds, _storageUnitIds) &&
            const DeepCollectionEquality()
                .equals(other._scannedUnitIds, _scannedUnitIds) &&
            const DeepCollectionEquality().equals(other._itemIds, _itemIds) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.driverNotes, driverNotes) ||
                other.driverNotes == driverNotes) &&
            const DeepCollectionEquality().equals(other._photoIds, _photoIds) &&
            (identical(other.clientSignatureUrl, clientSignatureUrl) ||
                other.clientSignatureUrl == clientSignatureUrl) &&
            (identical(other.clientConfirmMethod, clientConfirmMethod) ||
                other.clientConfirmMethod == clientConfirmMethod) &&
            (identical(other.estimatedFee, estimatedFee) ||
                other.estimatedFee == estimatedFee) &&
            (identical(other.isRushJob, isRushJob) ||
                other.isRushJob == isRushJob) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.cancelledAt, cancelledAt) ||
                other.cancelledAt == cancelledAt) &&
            (identical(other.cancelReason, cancelReason) ||
                other.cancelReason == cancelReason) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted) &&
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
        type,
        clientId,
        driverId,
        status,
        scheduledDate,
        timeWindow,
        address,
        const DeepCollectionEquality().hash(_storageUnitIds),
        const DeepCollectionEquality().hash(_scannedUnitIds),
        const DeepCollectionEquality().hash(_itemIds),
        notes,
        driverNotes,
        const DeepCollectionEquality().hash(_photoIds),
        clientSignatureUrl,
        clientConfirmMethod,
        estimatedFee,
        isRushJob,
        completedAt,
        cancelledAt,
        cancelReason,
        isDeleted,
        createdAt,
        updatedAt
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$JobImplCopyWith<_$JobImpl> get copyWith =>
      __$$JobImplCopyWithImpl<_$JobImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$JobImplToJson(
      this,
    );
  }
}

abstract class _Job extends Job {
  const factory _Job(
      {required final String id,
      required final String tenantId,
      final JobType type,
      required final String clientId,
      final String? driverId,
      final JobStatus status,
      @NullableTimestampConverter() final DateTime? scheduledDate,
      final TimeWindow timeWindow,
      final Address address,
      final List<String> storageUnitIds,
      final List<String> scannedUnitIds,
      final List<String> itemIds,
      final String? notes,
      final String? driverNotes,
      final List<String> photoIds,
      final String? clientSignatureUrl,
      final String? clientConfirmMethod,
      final double? estimatedFee,
      final bool isRushJob,
      @NullableTimestampConverter() final DateTime? completedAt,
      @NullableTimestampConverter() final DateTime? cancelledAt,
      final String? cancelReason,
      final bool isDeleted,
      @NullableTimestampConverter() final DateTime? createdAt,
      @NullableTimestampConverter() final DateTime? updatedAt}) = _$JobImpl;
  const _Job._() : super._();

  factory _Job.fromJson(Map<String, dynamic> json) = _$JobImpl.fromJson;

  @override
  String get id;
  @override
  String get tenantId;
  @override
  JobType get type;
  @override
  String get clientId;
  @override
  String? get driverId;
  @override
  JobStatus get status;
  @override
  @NullableTimestampConverter()
  DateTime? get scheduledDate;
  @override
  TimeWindow get timeWindow;
  @override
  Address get address;
  @override
  List<String> get storageUnitIds;
  @override
  List<String> get scannedUnitIds;
  @override
  List<String> get itemIds;
  @override
  String? get notes;
  @override
  String? get driverNotes;
  @override
  List<String> get photoIds;
  @override
  String? get clientSignatureUrl;
  @override
  String? get clientConfirmMethod;
  @override
  double? get estimatedFee;
  @override
  bool get isRushJob;
  @override
  @NullableTimestampConverter()
  DateTime? get completedAt;
  @override
  @NullableTimestampConverter()
  DateTime? get cancelledAt;
  @override
  String? get cancelReason;
  @override
  bool get isDeleted;
  @override
  @NullableTimestampConverter()
  DateTime? get createdAt;
  @override
  @NullableTimestampConverter()
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$JobImplCopyWith<_$JobImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

JobEvent _$JobEventFromJson(Map<String, dynamic> json) {
  return _JobEvent.fromJson(json);
}

/// @nodoc
mixin _$JobEvent {
  String get id => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get actorId => throw _privateConstructorUsedError;
  String get actorName => throw _privateConstructorUsedError;
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get timestamp => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $JobEventCopyWith<JobEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JobEventCopyWith<$Res> {
  factory $JobEventCopyWith(JobEvent value, $Res Function(JobEvent) then) =
      _$JobEventCopyWithImpl<$Res, JobEvent>;
  @useResult
  $Res call(
      {String id,
      String type,
      String description,
      String actorId,
      String actorName,
      Map<String, dynamic> metadata,
      @NullableTimestampConverter() DateTime? timestamp});
}

/// @nodoc
class _$JobEventCopyWithImpl<$Res, $Val extends JobEvent>
    implements $JobEventCopyWith<$Res> {
  _$JobEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? description = null,
    Object? actorId = null,
    Object? actorName = null,
    Object? metadata = null,
    Object? timestamp = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      actorId: null == actorId
          ? _value.actorId
          : actorId // ignore: cast_nullable_to_non_nullable
              as String,
      actorName: null == actorName
          ? _value.actorName
          : actorName // ignore: cast_nullable_to_non_nullable
              as String,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$JobEventImplCopyWith<$Res>
    implements $JobEventCopyWith<$Res> {
  factory _$$JobEventImplCopyWith(
          _$JobEventImpl value, $Res Function(_$JobEventImpl) then) =
      __$$JobEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String type,
      String description,
      String actorId,
      String actorName,
      Map<String, dynamic> metadata,
      @NullableTimestampConverter() DateTime? timestamp});
}

/// @nodoc
class __$$JobEventImplCopyWithImpl<$Res>
    extends _$JobEventCopyWithImpl<$Res, _$JobEventImpl>
    implements _$$JobEventImplCopyWith<$Res> {
  __$$JobEventImplCopyWithImpl(
      _$JobEventImpl _value, $Res Function(_$JobEventImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? description = null,
    Object? actorId = null,
    Object? actorName = null,
    Object? metadata = null,
    Object? timestamp = freezed,
  }) {
    return _then(_$JobEventImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      actorId: null == actorId
          ? _value.actorId
          : actorId // ignore: cast_nullable_to_non_nullable
              as String,
      actorName: null == actorName
          ? _value.actorName
          : actorName // ignore: cast_nullable_to_non_nullable
              as String,
      metadata: null == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$JobEventImpl implements _JobEvent {
  const _$JobEventImpl(
      {required this.id,
      this.type = '',
      this.description = '',
      this.actorId = '',
      this.actorName = '',
      final Map<String, dynamic> metadata = const {},
      @NullableTimestampConverter() this.timestamp})
      : _metadata = metadata;

  factory _$JobEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$JobEventImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey()
  final String type;
  @override
  @JsonKey()
  final String description;
  @override
  @JsonKey()
  final String actorId;
  @override
  @JsonKey()
  final String actorName;
  final Map<String, dynamic> _metadata;
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  @NullableTimestampConverter()
  final DateTime? timestamp;

  @override
  String toString() {
    return 'JobEvent(id: $id, type: $type, description: $description, actorId: $actorId, actorName: $actorName, metadata: $metadata, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JobEventImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.actorId, actorId) || other.actorId == actorId) &&
            (identical(other.actorName, actorName) ||
                other.actorName == actorName) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, type, description, actorId,
      actorName, const DeepCollectionEquality().hash(_metadata), timestamp);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$JobEventImplCopyWith<_$JobEventImpl> get copyWith =>
      __$$JobEventImplCopyWithImpl<_$JobEventImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$JobEventImplToJson(
      this,
    );
  }
}

abstract class _JobEvent implements JobEvent {
  const factory _JobEvent(
          {required final String id,
          final String type,
          final String description,
          final String actorId,
          final String actorName,
          final Map<String, dynamic> metadata,
          @NullableTimestampConverter() final DateTime? timestamp}) =
      _$JobEventImpl;

  factory _JobEvent.fromJson(Map<String, dynamic> json) =
      _$JobEventImpl.fromJson;

  @override
  String get id;
  @override
  String get type;
  @override
  String get description;
  @override
  String get actorId;
  @override
  String get actorName;
  @override
  Map<String, dynamic> get metadata;
  @override
  @NullableTimestampConverter()
  DateTime? get timestamp;
  @override
  @JsonKey(ignore: true)
  _$$JobEventImplCopyWith<_$JobEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
