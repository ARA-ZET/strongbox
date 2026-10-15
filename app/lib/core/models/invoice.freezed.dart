// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invoice.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Invoice _$InvoiceFromJson(Map<String, dynamic> json) {
  return _Invoice.fromJson(json);
}

/// @nodoc
mixin _$Invoice {
  String get id => throw _privateConstructorUsedError;
  String get tenantId => throw _privateConstructorUsedError;
  String get clientId => throw _privateConstructorUsedError;

  /// EFT reference, e.g. `INV-202611-AB12CD`.
  String get reference => throw _privateConstructorUsedError;

  /// Rand, VAT inclusive.
  double get amount => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  PaymentStatus get status => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  List<InvoiceLine> get lines => throw _privateConstructorUsedError;
  int get unitCount => throw _privateConstructorUsedError;

  /// Billable units with no size — not on this invoice.
  int get unpricedUnitCount => throw _privateConstructorUsedError;
  String? get pdfUrl => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get periodStart => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get periodEnd => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get dueAt => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get paidAt => throw _privateConstructorUsedError;
  String? get paidBy => throw _privateConstructorUsedError;

  /// How it was paid, e.g. "EFT 12 Nov, FNB ref 8841".
  String? get paymentNote => throw _privateConstructorUsedError;
  String? get voidReason => throw _privateConstructorUsedError;
  bool get isDeleted => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $InvoiceCopyWith<Invoice> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InvoiceCopyWith<$Res> {
  factory $InvoiceCopyWith(Invoice value, $Res Function(Invoice) then) =
      _$InvoiceCopyWithImpl<$Res, Invoice>;
  @useResult
  $Res call(
      {String id,
      String tenantId,
      String clientId,
      String reference,
      double amount,
      String currency,
      PaymentStatus status,
      String? description,
      List<InvoiceLine> lines,
      int unitCount,
      int unpricedUnitCount,
      String? pdfUrl,
      @NullableTimestampConverter() DateTime? periodStart,
      @NullableTimestampConverter() DateTime? periodEnd,
      @NullableTimestampConverter() DateTime? dueAt,
      @NullableTimestampConverter() DateTime? paidAt,
      String? paidBy,
      String? paymentNote,
      String? voidReason,
      bool isDeleted,
      @NullableTimestampConverter() DateTime? createdAt,
      @NullableTimestampConverter() DateTime? updatedAt});
}

/// @nodoc
class _$InvoiceCopyWithImpl<$Res, $Val extends Invoice>
    implements $InvoiceCopyWith<$Res> {
  _$InvoiceCopyWithImpl(this._value, this._then);

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
    Object? reference = null,
    Object? amount = null,
    Object? currency = null,
    Object? status = null,
    Object? description = freezed,
    Object? lines = null,
    Object? unitCount = null,
    Object? unpricedUnitCount = null,
    Object? pdfUrl = freezed,
    Object? periodStart = freezed,
    Object? periodEnd = freezed,
    Object? dueAt = freezed,
    Object? paidAt = freezed,
    Object? paidBy = freezed,
    Object? paymentNote = freezed,
    Object? voidReason = freezed,
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
      clientId: null == clientId
          ? _value.clientId
          : clientId // ignore: cast_nullable_to_non_nullable
              as String,
      reference: null == reference
          ? _value.reference
          : reference // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as PaymentStatus,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      lines: null == lines
          ? _value.lines
          : lines // ignore: cast_nullable_to_non_nullable
              as List<InvoiceLine>,
      unitCount: null == unitCount
          ? _value.unitCount
          : unitCount // ignore: cast_nullable_to_non_nullable
              as int,
      unpricedUnitCount: null == unpricedUnitCount
          ? _value.unpricedUnitCount
          : unpricedUnitCount // ignore: cast_nullable_to_non_nullable
              as int,
      pdfUrl: freezed == pdfUrl
          ? _value.pdfUrl
          : pdfUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      periodStart: freezed == periodStart
          ? _value.periodStart
          : periodStart // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      periodEnd: freezed == periodEnd
          ? _value.periodEnd
          : periodEnd // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dueAt: freezed == dueAt
          ? _value.dueAt
          : dueAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      paidAt: freezed == paidAt
          ? _value.paidAt
          : paidAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      paidBy: freezed == paidBy
          ? _value.paidBy
          : paidBy // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentNote: freezed == paymentNote
          ? _value.paymentNote
          : paymentNote // ignore: cast_nullable_to_non_nullable
              as String?,
      voidReason: freezed == voidReason
          ? _value.voidReason
          : voidReason // ignore: cast_nullable_to_non_nullable
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
}

/// @nodoc
abstract class _$$InvoiceImplCopyWith<$Res> implements $InvoiceCopyWith<$Res> {
  factory _$$InvoiceImplCopyWith(
          _$InvoiceImpl value, $Res Function(_$InvoiceImpl) then) =
      __$$InvoiceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String tenantId,
      String clientId,
      String reference,
      double amount,
      String currency,
      PaymentStatus status,
      String? description,
      List<InvoiceLine> lines,
      int unitCount,
      int unpricedUnitCount,
      String? pdfUrl,
      @NullableTimestampConverter() DateTime? periodStart,
      @NullableTimestampConverter() DateTime? periodEnd,
      @NullableTimestampConverter() DateTime? dueAt,
      @NullableTimestampConverter() DateTime? paidAt,
      String? paidBy,
      String? paymentNote,
      String? voidReason,
      bool isDeleted,
      @NullableTimestampConverter() DateTime? createdAt,
      @NullableTimestampConverter() DateTime? updatedAt});
}

/// @nodoc
class __$$InvoiceImplCopyWithImpl<$Res>
    extends _$InvoiceCopyWithImpl<$Res, _$InvoiceImpl>
    implements _$$InvoiceImplCopyWith<$Res> {
  __$$InvoiceImplCopyWithImpl(
      _$InvoiceImpl _value, $Res Function(_$InvoiceImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? clientId = null,
    Object? reference = null,
    Object? amount = null,
    Object? currency = null,
    Object? status = null,
    Object? description = freezed,
    Object? lines = null,
    Object? unitCount = null,
    Object? unpricedUnitCount = null,
    Object? pdfUrl = freezed,
    Object? periodStart = freezed,
    Object? periodEnd = freezed,
    Object? dueAt = freezed,
    Object? paidAt = freezed,
    Object? paidBy = freezed,
    Object? paymentNote = freezed,
    Object? voidReason = freezed,
    Object? isDeleted = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$InvoiceImpl(
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
      reference: null == reference
          ? _value.reference
          : reference // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as PaymentStatus,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      lines: null == lines
          ? _value._lines
          : lines // ignore: cast_nullable_to_non_nullable
              as List<InvoiceLine>,
      unitCount: null == unitCount
          ? _value.unitCount
          : unitCount // ignore: cast_nullable_to_non_nullable
              as int,
      unpricedUnitCount: null == unpricedUnitCount
          ? _value.unpricedUnitCount
          : unpricedUnitCount // ignore: cast_nullable_to_non_nullable
              as int,
      pdfUrl: freezed == pdfUrl
          ? _value.pdfUrl
          : pdfUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      periodStart: freezed == periodStart
          ? _value.periodStart
          : periodStart // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      periodEnd: freezed == periodEnd
          ? _value.periodEnd
          : periodEnd // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dueAt: freezed == dueAt
          ? _value.dueAt
          : dueAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      paidAt: freezed == paidAt
          ? _value.paidAt
          : paidAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      paidBy: freezed == paidBy
          ? _value.paidBy
          : paidBy // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentNote: freezed == paymentNote
          ? _value.paymentNote
          : paymentNote // ignore: cast_nullable_to_non_nullable
              as String?,
      voidReason: freezed == voidReason
          ? _value.voidReason
          : voidReason // ignore: cast_nullable_to_non_nullable
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
class _$InvoiceImpl extends _Invoice {
  const _$InvoiceImpl(
      {required this.id,
      required this.tenantId,
      required this.clientId,
      this.reference = '',
      this.amount = 0,
      this.currency = 'zar',
      this.status = PaymentStatus.open,
      this.description,
      final List<InvoiceLine> lines = const [],
      this.unitCount = 0,
      this.unpricedUnitCount = 0,
      this.pdfUrl,
      @NullableTimestampConverter() this.periodStart,
      @NullableTimestampConverter() this.periodEnd,
      @NullableTimestampConverter() this.dueAt,
      @NullableTimestampConverter() this.paidAt,
      this.paidBy,
      this.paymentNote,
      this.voidReason,
      this.isDeleted = false,
      @NullableTimestampConverter() this.createdAt,
      @NullableTimestampConverter() this.updatedAt})
      : _lines = lines,
        super._();

  factory _$InvoiceImpl.fromJson(Map<String, dynamic> json) =>
      _$$InvoiceImplFromJson(json);

  @override
  final String id;
  @override
  final String tenantId;
  @override
  final String clientId;

  /// EFT reference, e.g. `INV-202611-AB12CD`.
  @override
  @JsonKey()
  final String reference;

  /// Rand, VAT inclusive.
  @override
  @JsonKey()
  final double amount;
  @override
  @JsonKey()
  final String currency;
  @override
  @JsonKey()
  final PaymentStatus status;
  @override
  final String? description;
  final List<InvoiceLine> _lines;
  @override
  @JsonKey()
  List<InvoiceLine> get lines {
    if (_lines is EqualUnmodifiableListView) return _lines;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lines);
  }

  @override
  @JsonKey()
  final int unitCount;

  /// Billable units with no size — not on this invoice.
  @override
  @JsonKey()
  final int unpricedUnitCount;
  @override
  final String? pdfUrl;
  @override
  @NullableTimestampConverter()
  final DateTime? periodStart;
  @override
  @NullableTimestampConverter()
  final DateTime? periodEnd;
  @override
  @NullableTimestampConverter()
  final DateTime? dueAt;
  @override
  @NullableTimestampConverter()
  final DateTime? paidAt;
  @override
  final String? paidBy;

  /// How it was paid, e.g. "EFT 12 Nov, FNB ref 8841".
  @override
  final String? paymentNote;
  @override
  final String? voidReason;
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
    return 'Invoice(id: $id, tenantId: $tenantId, clientId: $clientId, reference: $reference, amount: $amount, currency: $currency, status: $status, description: $description, lines: $lines, unitCount: $unitCount, unpricedUnitCount: $unpricedUnitCount, pdfUrl: $pdfUrl, periodStart: $periodStart, periodEnd: $periodEnd, dueAt: $dueAt, paidAt: $paidAt, paidBy: $paidBy, paymentNote: $paymentNote, voidReason: $voidReason, isDeleted: $isDeleted, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InvoiceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.clientId, clientId) ||
                other.clientId == clientId) &&
            (identical(other.reference, reference) ||
                other.reference == reference) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._lines, _lines) &&
            (identical(other.unitCount, unitCount) ||
                other.unitCount == unitCount) &&
            (identical(other.unpricedUnitCount, unpricedUnitCount) ||
                other.unpricedUnitCount == unpricedUnitCount) &&
            (identical(other.pdfUrl, pdfUrl) || other.pdfUrl == pdfUrl) &&
            (identical(other.periodStart, periodStart) ||
                other.periodStart == periodStart) &&
            (identical(other.periodEnd, periodEnd) ||
                other.periodEnd == periodEnd) &&
            (identical(other.dueAt, dueAt) || other.dueAt == dueAt) &&
            (identical(other.paidAt, paidAt) || other.paidAt == paidAt) &&
            (identical(other.paidBy, paidBy) || other.paidBy == paidBy) &&
            (identical(other.paymentNote, paymentNote) ||
                other.paymentNote == paymentNote) &&
            (identical(other.voidReason, voidReason) ||
                other.voidReason == voidReason) &&
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
        clientId,
        reference,
        amount,
        currency,
        status,
        description,
        const DeepCollectionEquality().hash(_lines),
        unitCount,
        unpricedUnitCount,
        pdfUrl,
        periodStart,
        periodEnd,
        dueAt,
        paidAt,
        paidBy,
        paymentNote,
        voidReason,
        isDeleted,
        createdAt,
        updatedAt
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$InvoiceImplCopyWith<_$InvoiceImpl> get copyWith =>
      __$$InvoiceImplCopyWithImpl<_$InvoiceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InvoiceImplToJson(
      this,
    );
  }
}

abstract class _Invoice extends Invoice {
  const factory _Invoice(
      {required final String id,
      required final String tenantId,
      required final String clientId,
      final String reference,
      final double amount,
      final String currency,
      final PaymentStatus status,
      final String? description,
      final List<InvoiceLine> lines,
      final int unitCount,
      final int unpricedUnitCount,
      final String? pdfUrl,
      @NullableTimestampConverter() final DateTime? periodStart,
      @NullableTimestampConverter() final DateTime? periodEnd,
      @NullableTimestampConverter() final DateTime? dueAt,
      @NullableTimestampConverter() final DateTime? paidAt,
      final String? paidBy,
      final String? paymentNote,
      final String? voidReason,
      final bool isDeleted,
      @NullableTimestampConverter() final DateTime? createdAt,
      @NullableTimestampConverter() final DateTime? updatedAt}) = _$InvoiceImpl;
  const _Invoice._() : super._();

  factory _Invoice.fromJson(Map<String, dynamic> json) = _$InvoiceImpl.fromJson;

  @override
  String get id;
  @override
  String get tenantId;
  @override
  String get clientId;
  @override

  /// EFT reference, e.g. `INV-202611-AB12CD`.
  String get reference;
  @override

  /// Rand, VAT inclusive.
  double get amount;
  @override
  String get currency;
  @override
  PaymentStatus get status;
  @override
  String? get description;
  @override
  List<InvoiceLine> get lines;
  @override
  int get unitCount;
  @override

  /// Billable units with no size — not on this invoice.
  int get unpricedUnitCount;
  @override
  String? get pdfUrl;
  @override
  @NullableTimestampConverter()
  DateTime? get periodStart;
  @override
  @NullableTimestampConverter()
  DateTime? get periodEnd;
  @override
  @NullableTimestampConverter()
  DateTime? get dueAt;
  @override
  @NullableTimestampConverter()
  DateTime? get paidAt;
  @override
  String? get paidBy;
  @override

  /// How it was paid, e.g. "EFT 12 Nov, FNB ref 8841".
  String? get paymentNote;
  @override
  String? get voidReason;
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
  _$$InvoiceImplCopyWith<_$InvoiceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

InvoiceLine _$InvoiceLineFromJson(Map<String, dynamic> json) {
  return _InvoiceLine.fromJson(json);
}

/// @nodoc
mixin _$InvoiceLine {
  String get unitId => throw _privateConstructorUsedError;
  String get qrCodeId => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  String? get priceKey => throw _privateConstructorUsedError;
  int get rateZar => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $InvoiceLineCopyWith<InvoiceLine> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InvoiceLineCopyWith<$Res> {
  factory $InvoiceLineCopyWith(
          InvoiceLine value, $Res Function(InvoiceLine) then) =
      _$InvoiceLineCopyWithImpl<$Res, InvoiceLine>;
  @useResult
  $Res call(
      {String unitId,
      String qrCodeId,
      String label,
      String? priceKey,
      int rateZar});
}

/// @nodoc
class _$InvoiceLineCopyWithImpl<$Res, $Val extends InvoiceLine>
    implements $InvoiceLineCopyWith<$Res> {
  _$InvoiceLineCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? unitId = null,
    Object? qrCodeId = null,
    Object? label = null,
    Object? priceKey = freezed,
    Object? rateZar = null,
  }) {
    return _then(_value.copyWith(
      unitId: null == unitId
          ? _value.unitId
          : unitId // ignore: cast_nullable_to_non_nullable
              as String,
      qrCodeId: null == qrCodeId
          ? _value.qrCodeId
          : qrCodeId // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      priceKey: freezed == priceKey
          ? _value.priceKey
          : priceKey // ignore: cast_nullable_to_non_nullable
              as String?,
      rateZar: null == rateZar
          ? _value.rateZar
          : rateZar // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InvoiceLineImplCopyWith<$Res>
    implements $InvoiceLineCopyWith<$Res> {
  factory _$$InvoiceLineImplCopyWith(
          _$InvoiceLineImpl value, $Res Function(_$InvoiceLineImpl) then) =
      __$$InvoiceLineImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String unitId,
      String qrCodeId,
      String label,
      String? priceKey,
      int rateZar});
}

/// @nodoc
class __$$InvoiceLineImplCopyWithImpl<$Res>
    extends _$InvoiceLineCopyWithImpl<$Res, _$InvoiceLineImpl>
    implements _$$InvoiceLineImplCopyWith<$Res> {
  __$$InvoiceLineImplCopyWithImpl(
      _$InvoiceLineImpl _value, $Res Function(_$InvoiceLineImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? unitId = null,
    Object? qrCodeId = null,
    Object? label = null,
    Object? priceKey = freezed,
    Object? rateZar = null,
  }) {
    return _then(_$InvoiceLineImpl(
      unitId: null == unitId
          ? _value.unitId
          : unitId // ignore: cast_nullable_to_non_nullable
              as String,
      qrCodeId: null == qrCodeId
          ? _value.qrCodeId
          : qrCodeId // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      priceKey: freezed == priceKey
          ? _value.priceKey
          : priceKey // ignore: cast_nullable_to_non_nullable
              as String?,
      rateZar: null == rateZar
          ? _value.rateZar
          : rateZar // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$InvoiceLineImpl implements _InvoiceLine {
  const _$InvoiceLineImpl(
      {required this.unitId,
      this.qrCodeId = '',
      this.label = '',
      this.priceKey,
      this.rateZar = 0});

  factory _$InvoiceLineImpl.fromJson(Map<String, dynamic> json) =>
      _$$InvoiceLineImplFromJson(json);

  @override
  final String unitId;
  @override
  @JsonKey()
  final String qrCodeId;
  @override
  @JsonKey()
  final String label;
  @override
  final String? priceKey;
  @override
  @JsonKey()
  final int rateZar;

  @override
  String toString() {
    return 'InvoiceLine(unitId: $unitId, qrCodeId: $qrCodeId, label: $label, priceKey: $priceKey, rateZar: $rateZar)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InvoiceLineImpl &&
            (identical(other.unitId, unitId) || other.unitId == unitId) &&
            (identical(other.qrCodeId, qrCodeId) ||
                other.qrCodeId == qrCodeId) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.priceKey, priceKey) ||
                other.priceKey == priceKey) &&
            (identical(other.rateZar, rateZar) || other.rateZar == rateZar));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, unitId, qrCodeId, label, priceKey, rateZar);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$InvoiceLineImplCopyWith<_$InvoiceLineImpl> get copyWith =>
      __$$InvoiceLineImplCopyWithImpl<_$InvoiceLineImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InvoiceLineImplToJson(
      this,
    );
  }
}

abstract class _InvoiceLine implements InvoiceLine {
  const factory _InvoiceLine(
      {required final String unitId,
      final String qrCodeId,
      final String label,
      final String? priceKey,
      final int rateZar}) = _$InvoiceLineImpl;

  factory _InvoiceLine.fromJson(Map<String, dynamic> json) =
      _$InvoiceLineImpl.fromJson;

  @override
  String get unitId;
  @override
  String get qrCodeId;
  @override
  String get label;
  @override
  String? get priceKey;
  @override
  int get rateZar;
  @override
  @JsonKey(ignore: true)
  _$$InvoiceLineImplCopyWith<_$InvoiceLineImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
