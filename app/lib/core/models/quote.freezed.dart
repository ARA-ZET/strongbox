// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quote.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

QuoteBoxLine _$QuoteBoxLineFromJson(Map<String, dynamic> json) {
  return _QuoteBoxLine.fromJson(json);
}

/// @nodoc
mixin _$QuoteBoxLine {
  BoxSize get size => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $QuoteBoxLineCopyWith<QuoteBoxLine> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuoteBoxLineCopyWith<$Res> {
  factory $QuoteBoxLineCopyWith(
          QuoteBoxLine value, $Res Function(QuoteBoxLine) then) =
      _$QuoteBoxLineCopyWithImpl<$Res, QuoteBoxLine>;
  @useResult
  $Res call({BoxSize size, int quantity});
}

/// @nodoc
class _$QuoteBoxLineCopyWithImpl<$Res, $Val extends QuoteBoxLine>
    implements $QuoteBoxLineCopyWith<$Res> {
  _$QuoteBoxLineCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? size = null,
    Object? quantity = null,
  }) {
    return _then(_value.copyWith(
      size: null == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as BoxSize,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QuoteBoxLineImplCopyWith<$Res>
    implements $QuoteBoxLineCopyWith<$Res> {
  factory _$$QuoteBoxLineImplCopyWith(
          _$QuoteBoxLineImpl value, $Res Function(_$QuoteBoxLineImpl) then) =
      __$$QuoteBoxLineImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({BoxSize size, int quantity});
}

/// @nodoc
class __$$QuoteBoxLineImplCopyWithImpl<$Res>
    extends _$QuoteBoxLineCopyWithImpl<$Res, _$QuoteBoxLineImpl>
    implements _$$QuoteBoxLineImplCopyWith<$Res> {
  __$$QuoteBoxLineImplCopyWithImpl(
      _$QuoteBoxLineImpl _value, $Res Function(_$QuoteBoxLineImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? size = null,
    Object? quantity = null,
  }) {
    return _then(_$QuoteBoxLineImpl(
      size: null == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as BoxSize,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$QuoteBoxLineImpl extends _QuoteBoxLine {
  const _$QuoteBoxLineImpl({required this.size, this.quantity = 0}) : super._();

  factory _$QuoteBoxLineImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuoteBoxLineImplFromJson(json);

  @override
  final BoxSize size;
  @override
  @JsonKey()
  final int quantity;

  @override
  String toString() {
    return 'QuoteBoxLine(size: $size, quantity: $quantity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuoteBoxLineImpl &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, size, quantity);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$QuoteBoxLineImplCopyWith<_$QuoteBoxLineImpl> get copyWith =>
      __$$QuoteBoxLineImplCopyWithImpl<_$QuoteBoxLineImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QuoteBoxLineImplToJson(
      this,
    );
  }
}

abstract class _QuoteBoxLine extends QuoteBoxLine {
  const factory _QuoteBoxLine(
      {required final BoxSize size, final int quantity}) = _$QuoteBoxLineImpl;
  const _QuoteBoxLine._() : super._();

  factory _QuoteBoxLine.fromJson(Map<String, dynamic> json) =
      _$QuoteBoxLineImpl.fromJson;

  @override
  BoxSize get size;
  @override
  int get quantity;
  @override
  @JsonKey(ignore: true)
  _$$QuoteBoxLineImplCopyWith<_$QuoteBoxLineImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

QuoteLooseItem _$QuoteLooseItemFromJson(Map<String, dynamic> json) {
  return _QuoteLooseItem.fromJson(json);
}

/// @nodoc
mixin _$QuoteLooseItem {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get presetKey => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  double get lengthM => throw _privateConstructorUsedError;
  double get widthM => throw _privateConstructorUsedError;
  double get heightM => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  int get monthlyZar => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $QuoteLooseItemCopyWith<QuoteLooseItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuoteLooseItemCopyWith<$Res> {
  factory $QuoteLooseItemCopyWith(
          QuoteLooseItem value, $Res Function(QuoteLooseItem) then) =
      _$QuoteLooseItemCopyWithImpl<$Res, QuoteLooseItem>;
  @useResult
  $Res call(
      {String id,
      String name,
      String presetKey,
      String description,
      double lengthM,
      double widthM,
      double heightM,
      int quantity,
      int monthlyZar});
}

/// @nodoc
class _$QuoteLooseItemCopyWithImpl<$Res, $Val extends QuoteLooseItem>
    implements $QuoteLooseItemCopyWith<$Res> {
  _$QuoteLooseItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? presetKey = null,
    Object? description = null,
    Object? lengthM = null,
    Object? widthM = null,
    Object? heightM = null,
    Object? quantity = null,
    Object? monthlyZar = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      presetKey: null == presetKey
          ? _value.presetKey
          : presetKey // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      lengthM: null == lengthM
          ? _value.lengthM
          : lengthM // ignore: cast_nullable_to_non_nullable
              as double,
      widthM: null == widthM
          ? _value.widthM
          : widthM // ignore: cast_nullable_to_non_nullable
              as double,
      heightM: null == heightM
          ? _value.heightM
          : heightM // ignore: cast_nullable_to_non_nullable
              as double,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      monthlyZar: null == monthlyZar
          ? _value.monthlyZar
          : monthlyZar // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QuoteLooseItemImplCopyWith<$Res>
    implements $QuoteLooseItemCopyWith<$Res> {
  factory _$$QuoteLooseItemImplCopyWith(_$QuoteLooseItemImpl value,
          $Res Function(_$QuoteLooseItemImpl) then) =
      __$$QuoteLooseItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String presetKey,
      String description,
      double lengthM,
      double widthM,
      double heightM,
      int quantity,
      int monthlyZar});
}

/// @nodoc
class __$$QuoteLooseItemImplCopyWithImpl<$Res>
    extends _$QuoteLooseItemCopyWithImpl<$Res, _$QuoteLooseItemImpl>
    implements _$$QuoteLooseItemImplCopyWith<$Res> {
  __$$QuoteLooseItemImplCopyWithImpl(
      _$QuoteLooseItemImpl _value, $Res Function(_$QuoteLooseItemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? presetKey = null,
    Object? description = null,
    Object? lengthM = null,
    Object? widthM = null,
    Object? heightM = null,
    Object? quantity = null,
    Object? monthlyZar = null,
  }) {
    return _then(_$QuoteLooseItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      presetKey: null == presetKey
          ? _value.presetKey
          : presetKey // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      lengthM: null == lengthM
          ? _value.lengthM
          : lengthM // ignore: cast_nullable_to_non_nullable
              as double,
      widthM: null == widthM
          ? _value.widthM
          : widthM // ignore: cast_nullable_to_non_nullable
              as double,
      heightM: null == heightM
          ? _value.heightM
          : heightM // ignore: cast_nullable_to_non_nullable
              as double,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      monthlyZar: null == monthlyZar
          ? _value.monthlyZar
          : monthlyZar // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$QuoteLooseItemImpl extends _QuoteLooseItem {
  const _$QuoteLooseItemImpl(
      {required this.id,
      required this.name,
      this.presetKey = '',
      this.description = '',
      this.lengthM = 0,
      this.widthM = 0,
      this.heightM = 0,
      this.quantity = 1,
      this.monthlyZar = 0})
      : super._();

  factory _$QuoteLooseItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuoteLooseItemImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey()
  final String presetKey;
  @override
  @JsonKey()
  final String description;
  @override
  @JsonKey()
  final double lengthM;
  @override
  @JsonKey()
  final double widthM;
  @override
  @JsonKey()
  final double heightM;
  @override
  @JsonKey()
  final int quantity;
  @override
  @JsonKey()
  final int monthlyZar;

  @override
  String toString() {
    return 'QuoteLooseItem(id: $id, name: $name, presetKey: $presetKey, description: $description, lengthM: $lengthM, widthM: $widthM, heightM: $heightM, quantity: $quantity, monthlyZar: $monthlyZar)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuoteLooseItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.presetKey, presetKey) ||
                other.presetKey == presetKey) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.lengthM, lengthM) || other.lengthM == lengthM) &&
            (identical(other.widthM, widthM) || other.widthM == widthM) &&
            (identical(other.heightM, heightM) || other.heightM == heightM) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.monthlyZar, monthlyZar) ||
                other.monthlyZar == monthlyZar));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, presetKey, description,
      lengthM, widthM, heightM, quantity, monthlyZar);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$QuoteLooseItemImplCopyWith<_$QuoteLooseItemImpl> get copyWith =>
      __$$QuoteLooseItemImplCopyWithImpl<_$QuoteLooseItemImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QuoteLooseItemImplToJson(
      this,
    );
  }
}

abstract class _QuoteLooseItem extends QuoteLooseItem {
  const factory _QuoteLooseItem(
      {required final String id,
      required final String name,
      final String presetKey,
      final String description,
      final double lengthM,
      final double widthM,
      final double heightM,
      final int quantity,
      final int monthlyZar}) = _$QuoteLooseItemImpl;
  const _QuoteLooseItem._() : super._();

  factory _QuoteLooseItem.fromJson(Map<String, dynamic> json) =
      _$QuoteLooseItemImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get presetKey;
  @override
  String get description;
  @override
  double get lengthM;
  @override
  double get widthM;
  @override
  double get heightM;
  @override
  int get quantity;
  @override
  int get monthlyZar;
  @override
  @JsonKey(ignore: true)
  _$$QuoteLooseItemImplCopyWith<_$QuoteLooseItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Quote _$QuoteFromJson(Map<String, dynamic> json) {
  return _Quote.fromJson(json);
}

/// @nodoc
mixin _$Quote {
  String get id => throw _privateConstructorUsedError;
  String get tenantId => throw _privateConstructorUsedError;
  String get reference => throw _privateConstructorUsedError;
  String? get clientId => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;
  QuoteStatus get status => throw _privateConstructorUsedError;
  List<QuoteBoxLine> get boxes => throw _privateConstructorUsedError;
  List<QuoteLooseItem> get looseItems => throw _privateConstructorUsedError;
  bool get packingRequired => throw _privateConstructorUsedError;
  int get packers => throw _privateConstructorUsedError;
  int get packingHours => throw _privateConstructorUsedError;
  VehicleSize get vehicle => throw _privateConstructorUsedError;
  String get contactName => throw _privateConstructorUsedError;
  String get contactEmail => throw _privateConstructorUsedError;
  String get contactPhone => throw _privateConstructorUsedError;
  String get collectionAddress => throw _privateConstructorUsedError;
  String get notes => throw _privateConstructorUsedError;

  /// Totals snapshotted at acceptance, so the stored quote never drifts
  /// from the figures the client agreed to.
  int get monthlyStorageZar => throw _privateConstructorUsedError;
  int get collectionZar => throw _privateConstructorUsedError;
  int get packingZar => throw _privateConstructorUsedError;
  int get dueTodayZar => throw _privateConstructorUsedError;
  double get estimatedVolumeM3 => throw _privateConstructorUsedError;

  /// Pickup job created when the quote was accepted.
  String? get jobId => throw _privateConstructorUsedError;
  bool get isDeleted => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get deletedAt => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get acceptedAt => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $QuoteCopyWith<Quote> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuoteCopyWith<$Res> {
  factory $QuoteCopyWith(Quote value, $Res Function(Quote) then) =
      _$QuoteCopyWithImpl<$Res, Quote>;
  @useResult
  $Res call(
      {String id,
      String tenantId,
      String reference,
      String? clientId,
      String? userId,
      QuoteStatus status,
      List<QuoteBoxLine> boxes,
      List<QuoteLooseItem> looseItems,
      bool packingRequired,
      int packers,
      int packingHours,
      VehicleSize vehicle,
      String contactName,
      String contactEmail,
      String contactPhone,
      String collectionAddress,
      String notes,
      int monthlyStorageZar,
      int collectionZar,
      int packingZar,
      int dueTodayZar,
      double estimatedVolumeM3,
      String? jobId,
      bool isDeleted,
      @NullableTimestampConverter() DateTime? deletedAt,
      @NullableTimestampConverter() DateTime? acceptedAt,
      @NullableTimestampConverter() DateTime? createdAt,
      @NullableTimestampConverter() DateTime? updatedAt});
}

/// @nodoc
class _$QuoteCopyWithImpl<$Res, $Val extends Quote>
    implements $QuoteCopyWith<$Res> {
  _$QuoteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? reference = null,
    Object? clientId = freezed,
    Object? userId = freezed,
    Object? status = null,
    Object? boxes = null,
    Object? looseItems = null,
    Object? packingRequired = null,
    Object? packers = null,
    Object? packingHours = null,
    Object? vehicle = null,
    Object? contactName = null,
    Object? contactEmail = null,
    Object? contactPhone = null,
    Object? collectionAddress = null,
    Object? notes = null,
    Object? monthlyStorageZar = null,
    Object? collectionZar = null,
    Object? packingZar = null,
    Object? dueTodayZar = null,
    Object? estimatedVolumeM3 = null,
    Object? jobId = freezed,
    Object? isDeleted = null,
    Object? deletedAt = freezed,
    Object? acceptedAt = freezed,
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
      reference: null == reference
          ? _value.reference
          : reference // ignore: cast_nullable_to_non_nullable
              as String,
      clientId: freezed == clientId
          ? _value.clientId
          : clientId // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as QuoteStatus,
      boxes: null == boxes
          ? _value.boxes
          : boxes // ignore: cast_nullable_to_non_nullable
              as List<QuoteBoxLine>,
      looseItems: null == looseItems
          ? _value.looseItems
          : looseItems // ignore: cast_nullable_to_non_nullable
              as List<QuoteLooseItem>,
      packingRequired: null == packingRequired
          ? _value.packingRequired
          : packingRequired // ignore: cast_nullable_to_non_nullable
              as bool,
      packers: null == packers
          ? _value.packers
          : packers // ignore: cast_nullable_to_non_nullable
              as int,
      packingHours: null == packingHours
          ? _value.packingHours
          : packingHours // ignore: cast_nullable_to_non_nullable
              as int,
      vehicle: null == vehicle
          ? _value.vehicle
          : vehicle // ignore: cast_nullable_to_non_nullable
              as VehicleSize,
      contactName: null == contactName
          ? _value.contactName
          : contactName // ignore: cast_nullable_to_non_nullable
              as String,
      contactEmail: null == contactEmail
          ? _value.contactEmail
          : contactEmail // ignore: cast_nullable_to_non_nullable
              as String,
      contactPhone: null == contactPhone
          ? _value.contactPhone
          : contactPhone // ignore: cast_nullable_to_non_nullable
              as String,
      collectionAddress: null == collectionAddress
          ? _value.collectionAddress
          : collectionAddress // ignore: cast_nullable_to_non_nullable
              as String,
      notes: null == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
      monthlyStorageZar: null == monthlyStorageZar
          ? _value.monthlyStorageZar
          : monthlyStorageZar // ignore: cast_nullable_to_non_nullable
              as int,
      collectionZar: null == collectionZar
          ? _value.collectionZar
          : collectionZar // ignore: cast_nullable_to_non_nullable
              as int,
      packingZar: null == packingZar
          ? _value.packingZar
          : packingZar // ignore: cast_nullable_to_non_nullable
              as int,
      dueTodayZar: null == dueTodayZar
          ? _value.dueTodayZar
          : dueTodayZar // ignore: cast_nullable_to_non_nullable
              as int,
      estimatedVolumeM3: null == estimatedVolumeM3
          ? _value.estimatedVolumeM3
          : estimatedVolumeM3 // ignore: cast_nullable_to_non_nullable
              as double,
      jobId: freezed == jobId
          ? _value.jobId
          : jobId // ignore: cast_nullable_to_non_nullable
              as String?,
      isDeleted: null == isDeleted
          ? _value.isDeleted
          : isDeleted // ignore: cast_nullable_to_non_nullable
              as bool,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      acceptedAt: freezed == acceptedAt
          ? _value.acceptedAt
          : acceptedAt // ignore: cast_nullable_to_non_nullable
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
abstract class _$$QuoteImplCopyWith<$Res> implements $QuoteCopyWith<$Res> {
  factory _$$QuoteImplCopyWith(
          _$QuoteImpl value, $Res Function(_$QuoteImpl) then) =
      __$$QuoteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String tenantId,
      String reference,
      String? clientId,
      String? userId,
      QuoteStatus status,
      List<QuoteBoxLine> boxes,
      List<QuoteLooseItem> looseItems,
      bool packingRequired,
      int packers,
      int packingHours,
      VehicleSize vehicle,
      String contactName,
      String contactEmail,
      String contactPhone,
      String collectionAddress,
      String notes,
      int monthlyStorageZar,
      int collectionZar,
      int packingZar,
      int dueTodayZar,
      double estimatedVolumeM3,
      String? jobId,
      bool isDeleted,
      @NullableTimestampConverter() DateTime? deletedAt,
      @NullableTimestampConverter() DateTime? acceptedAt,
      @NullableTimestampConverter() DateTime? createdAt,
      @NullableTimestampConverter() DateTime? updatedAt});
}

/// @nodoc
class __$$QuoteImplCopyWithImpl<$Res>
    extends _$QuoteCopyWithImpl<$Res, _$QuoteImpl>
    implements _$$QuoteImplCopyWith<$Res> {
  __$$QuoteImplCopyWithImpl(
      _$QuoteImpl _value, $Res Function(_$QuoteImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? reference = null,
    Object? clientId = freezed,
    Object? userId = freezed,
    Object? status = null,
    Object? boxes = null,
    Object? looseItems = null,
    Object? packingRequired = null,
    Object? packers = null,
    Object? packingHours = null,
    Object? vehicle = null,
    Object? contactName = null,
    Object? contactEmail = null,
    Object? contactPhone = null,
    Object? collectionAddress = null,
    Object? notes = null,
    Object? monthlyStorageZar = null,
    Object? collectionZar = null,
    Object? packingZar = null,
    Object? dueTodayZar = null,
    Object? estimatedVolumeM3 = null,
    Object? jobId = freezed,
    Object? isDeleted = null,
    Object? deletedAt = freezed,
    Object? acceptedAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$QuoteImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tenantId: null == tenantId
          ? _value.tenantId
          : tenantId // ignore: cast_nullable_to_non_nullable
              as String,
      reference: null == reference
          ? _value.reference
          : reference // ignore: cast_nullable_to_non_nullable
              as String,
      clientId: freezed == clientId
          ? _value.clientId
          : clientId // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as QuoteStatus,
      boxes: null == boxes
          ? _value._boxes
          : boxes // ignore: cast_nullable_to_non_nullable
              as List<QuoteBoxLine>,
      looseItems: null == looseItems
          ? _value._looseItems
          : looseItems // ignore: cast_nullable_to_non_nullable
              as List<QuoteLooseItem>,
      packingRequired: null == packingRequired
          ? _value.packingRequired
          : packingRequired // ignore: cast_nullable_to_non_nullable
              as bool,
      packers: null == packers
          ? _value.packers
          : packers // ignore: cast_nullable_to_non_nullable
              as int,
      packingHours: null == packingHours
          ? _value.packingHours
          : packingHours // ignore: cast_nullable_to_non_nullable
              as int,
      vehicle: null == vehicle
          ? _value.vehicle
          : vehicle // ignore: cast_nullable_to_non_nullable
              as VehicleSize,
      contactName: null == contactName
          ? _value.contactName
          : contactName // ignore: cast_nullable_to_non_nullable
              as String,
      contactEmail: null == contactEmail
          ? _value.contactEmail
          : contactEmail // ignore: cast_nullable_to_non_nullable
              as String,
      contactPhone: null == contactPhone
          ? _value.contactPhone
          : contactPhone // ignore: cast_nullable_to_non_nullable
              as String,
      collectionAddress: null == collectionAddress
          ? _value.collectionAddress
          : collectionAddress // ignore: cast_nullable_to_non_nullable
              as String,
      notes: null == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
      monthlyStorageZar: null == monthlyStorageZar
          ? _value.monthlyStorageZar
          : monthlyStorageZar // ignore: cast_nullable_to_non_nullable
              as int,
      collectionZar: null == collectionZar
          ? _value.collectionZar
          : collectionZar // ignore: cast_nullable_to_non_nullable
              as int,
      packingZar: null == packingZar
          ? _value.packingZar
          : packingZar // ignore: cast_nullable_to_non_nullable
              as int,
      dueTodayZar: null == dueTodayZar
          ? _value.dueTodayZar
          : dueTodayZar // ignore: cast_nullable_to_non_nullable
              as int,
      estimatedVolumeM3: null == estimatedVolumeM3
          ? _value.estimatedVolumeM3
          : estimatedVolumeM3 // ignore: cast_nullable_to_non_nullable
              as double,
      jobId: freezed == jobId
          ? _value.jobId
          : jobId // ignore: cast_nullable_to_non_nullable
              as String?,
      isDeleted: null == isDeleted
          ? _value.isDeleted
          : isDeleted // ignore: cast_nullable_to_non_nullable
              as bool,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      acceptedAt: freezed == acceptedAt
          ? _value.acceptedAt
          : acceptedAt // ignore: cast_nullable_to_non_nullable
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
class _$QuoteImpl extends _Quote {
  const _$QuoteImpl(
      {this.id = '',
      required this.tenantId,
      this.reference = '',
      this.clientId,
      this.userId,
      this.status = QuoteStatus.draft,
      final List<QuoteBoxLine> boxes = const [],
      final List<QuoteLooseItem> looseItems = const [],
      this.packingRequired = false,
      this.packers = QuotePricing.defaultPackers,
      this.packingHours = QuotePricing.minPackingHours,
      this.vehicle = VehicleSize.mediumVan,
      this.contactName = '',
      this.contactEmail = '',
      this.contactPhone = '',
      this.collectionAddress = '',
      this.notes = '',
      this.monthlyStorageZar = 0,
      this.collectionZar = 0,
      this.packingZar = 0,
      this.dueTodayZar = 0,
      this.estimatedVolumeM3 = 0,
      this.jobId,
      this.isDeleted = false,
      @NullableTimestampConverter() this.deletedAt,
      @NullableTimestampConverter() this.acceptedAt,
      @NullableTimestampConverter() this.createdAt,
      @NullableTimestampConverter() this.updatedAt})
      : _boxes = boxes,
        _looseItems = looseItems,
        super._();

  factory _$QuoteImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuoteImplFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  final String tenantId;
  @override
  @JsonKey()
  final String reference;
  @override
  final String? clientId;
  @override
  final String? userId;
  @override
  @JsonKey()
  final QuoteStatus status;
  final List<QuoteBoxLine> _boxes;
  @override
  @JsonKey()
  List<QuoteBoxLine> get boxes {
    if (_boxes is EqualUnmodifiableListView) return _boxes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_boxes);
  }

  final List<QuoteLooseItem> _looseItems;
  @override
  @JsonKey()
  List<QuoteLooseItem> get looseItems {
    if (_looseItems is EqualUnmodifiableListView) return _looseItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_looseItems);
  }

  @override
  @JsonKey()
  final bool packingRequired;
  @override
  @JsonKey()
  final int packers;
  @override
  @JsonKey()
  final int packingHours;
  @override
  @JsonKey()
  final VehicleSize vehicle;
  @override
  @JsonKey()
  final String contactName;
  @override
  @JsonKey()
  final String contactEmail;
  @override
  @JsonKey()
  final String contactPhone;
  @override
  @JsonKey()
  final String collectionAddress;
  @override
  @JsonKey()
  final String notes;

  /// Totals snapshotted at acceptance, so the stored quote never drifts
  /// from the figures the client agreed to.
  @override
  @JsonKey()
  final int monthlyStorageZar;
  @override
  @JsonKey()
  final int collectionZar;
  @override
  @JsonKey()
  final int packingZar;
  @override
  @JsonKey()
  final int dueTodayZar;
  @override
  @JsonKey()
  final double estimatedVolumeM3;

  /// Pickup job created when the quote was accepted.
  @override
  final String? jobId;
  @override
  @JsonKey()
  final bool isDeleted;
  @override
  @NullableTimestampConverter()
  final DateTime? deletedAt;
  @override
  @NullableTimestampConverter()
  final DateTime? acceptedAt;
  @override
  @NullableTimestampConverter()
  final DateTime? createdAt;
  @override
  @NullableTimestampConverter()
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Quote(id: $id, tenantId: $tenantId, reference: $reference, clientId: $clientId, userId: $userId, status: $status, boxes: $boxes, looseItems: $looseItems, packingRequired: $packingRequired, packers: $packers, packingHours: $packingHours, vehicle: $vehicle, contactName: $contactName, contactEmail: $contactEmail, contactPhone: $contactPhone, collectionAddress: $collectionAddress, notes: $notes, monthlyStorageZar: $monthlyStorageZar, collectionZar: $collectionZar, packingZar: $packingZar, dueTodayZar: $dueTodayZar, estimatedVolumeM3: $estimatedVolumeM3, jobId: $jobId, isDeleted: $isDeleted, deletedAt: $deletedAt, acceptedAt: $acceptedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuoteImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.reference, reference) ||
                other.reference == reference) &&
            (identical(other.clientId, clientId) ||
                other.clientId == clientId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._boxes, _boxes) &&
            const DeepCollectionEquality()
                .equals(other._looseItems, _looseItems) &&
            (identical(other.packingRequired, packingRequired) ||
                other.packingRequired == packingRequired) &&
            (identical(other.packers, packers) || other.packers == packers) &&
            (identical(other.packingHours, packingHours) ||
                other.packingHours == packingHours) &&
            (identical(other.vehicle, vehicle) || other.vehicle == vehicle) &&
            (identical(other.contactName, contactName) ||
                other.contactName == contactName) &&
            (identical(other.contactEmail, contactEmail) ||
                other.contactEmail == contactEmail) &&
            (identical(other.contactPhone, contactPhone) ||
                other.contactPhone == contactPhone) &&
            (identical(other.collectionAddress, collectionAddress) ||
                other.collectionAddress == collectionAddress) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.monthlyStorageZar, monthlyStorageZar) ||
                other.monthlyStorageZar == monthlyStorageZar) &&
            (identical(other.collectionZar, collectionZar) ||
                other.collectionZar == collectionZar) &&
            (identical(other.packingZar, packingZar) ||
                other.packingZar == packingZar) &&
            (identical(other.dueTodayZar, dueTodayZar) ||
                other.dueTodayZar == dueTodayZar) &&
            (identical(other.estimatedVolumeM3, estimatedVolumeM3) ||
                other.estimatedVolumeM3 == estimatedVolumeM3) &&
            (identical(other.jobId, jobId) || other.jobId == jobId) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.acceptedAt, acceptedAt) ||
                other.acceptedAt == acceptedAt) &&
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
        reference,
        clientId,
        userId,
        status,
        const DeepCollectionEquality().hash(_boxes),
        const DeepCollectionEquality().hash(_looseItems),
        packingRequired,
        packers,
        packingHours,
        vehicle,
        contactName,
        contactEmail,
        contactPhone,
        collectionAddress,
        notes,
        monthlyStorageZar,
        collectionZar,
        packingZar,
        dueTodayZar,
        estimatedVolumeM3,
        jobId,
        isDeleted,
        deletedAt,
        acceptedAt,
        createdAt,
        updatedAt
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$QuoteImplCopyWith<_$QuoteImpl> get copyWith =>
      __$$QuoteImplCopyWithImpl<_$QuoteImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QuoteImplToJson(
      this,
    );
  }
}

abstract class _Quote extends Quote {
  const factory _Quote(
      {final String id,
      required final String tenantId,
      final String reference,
      final String? clientId,
      final String? userId,
      final QuoteStatus status,
      final List<QuoteBoxLine> boxes,
      final List<QuoteLooseItem> looseItems,
      final bool packingRequired,
      final int packers,
      final int packingHours,
      final VehicleSize vehicle,
      final String contactName,
      final String contactEmail,
      final String contactPhone,
      final String collectionAddress,
      final String notes,
      final int monthlyStorageZar,
      final int collectionZar,
      final int packingZar,
      final int dueTodayZar,
      final double estimatedVolumeM3,
      final String? jobId,
      final bool isDeleted,
      @NullableTimestampConverter() final DateTime? deletedAt,
      @NullableTimestampConverter() final DateTime? acceptedAt,
      @NullableTimestampConverter() final DateTime? createdAt,
      @NullableTimestampConverter() final DateTime? updatedAt}) = _$QuoteImpl;
  const _Quote._() : super._();

  factory _Quote.fromJson(Map<String, dynamic> json) = _$QuoteImpl.fromJson;

  @override
  String get id;
  @override
  String get tenantId;
  @override
  String get reference;
  @override
  String? get clientId;
  @override
  String? get userId;
  @override
  QuoteStatus get status;
  @override
  List<QuoteBoxLine> get boxes;
  @override
  List<QuoteLooseItem> get looseItems;
  @override
  bool get packingRequired;
  @override
  int get packers;
  @override
  int get packingHours;
  @override
  VehicleSize get vehicle;
  @override
  String get contactName;
  @override
  String get contactEmail;
  @override
  String get contactPhone;
  @override
  String get collectionAddress;
  @override
  String get notes;
  @override

  /// Totals snapshotted at acceptance, so the stored quote never drifts
  /// from the figures the client agreed to.
  int get monthlyStorageZar;
  @override
  int get collectionZar;
  @override
  int get packingZar;
  @override
  int get dueTodayZar;
  @override
  double get estimatedVolumeM3;
  @override

  /// Pickup job created when the quote was accepted.
  String? get jobId;
  @override
  bool get isDeleted;
  @override
  @NullableTimestampConverter()
  DateTime? get deletedAt;
  @override
  @NullableTimestampConverter()
  DateTime? get acceptedAt;
  @override
  @NullableTimestampConverter()
  DateTime? get createdAt;
  @override
  @NullableTimestampConverter()
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$QuoteImplCopyWith<_$QuoteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
