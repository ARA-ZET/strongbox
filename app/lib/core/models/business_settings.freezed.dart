// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'business_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WindowHours _$WindowHoursFromJson(Map<String, dynamic> json) {
  return _WindowHours.fromJson(json);
}

/// @nodoc
mixin _$WindowHours {
  String get start => throw _privateConstructorUsedError;
  String get end => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WindowHoursCopyWith<WindowHours> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WindowHoursCopyWith<$Res> {
  factory $WindowHoursCopyWith(
          WindowHours value, $Res Function(WindowHours) then) =
      _$WindowHoursCopyWithImpl<$Res, WindowHours>;
  @useResult
  $Res call({String start, String end});
}

/// @nodoc
class _$WindowHoursCopyWithImpl<$Res, $Val extends WindowHours>
    implements $WindowHoursCopyWith<$Res> {
  _$WindowHoursCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? start = null,
    Object? end = null,
  }) {
    return _then(_value.copyWith(
      start: null == start
          ? _value.start
          : start // ignore: cast_nullable_to_non_nullable
              as String,
      end: null == end
          ? _value.end
          : end // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WindowHoursImplCopyWith<$Res>
    implements $WindowHoursCopyWith<$Res> {
  factory _$$WindowHoursImplCopyWith(
          _$WindowHoursImpl value, $Res Function(_$WindowHoursImpl) then) =
      __$$WindowHoursImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String start, String end});
}

/// @nodoc
class __$$WindowHoursImplCopyWithImpl<$Res>
    extends _$WindowHoursCopyWithImpl<$Res, _$WindowHoursImpl>
    implements _$$WindowHoursImplCopyWith<$Res> {
  __$$WindowHoursImplCopyWithImpl(
      _$WindowHoursImpl _value, $Res Function(_$WindowHoursImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? start = null,
    Object? end = null,
  }) {
    return _then(_$WindowHoursImpl(
      start: null == start
          ? _value.start
          : start // ignore: cast_nullable_to_non_nullable
              as String,
      end: null == end
          ? _value.end
          : end // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WindowHoursImpl implements _WindowHours {
  const _$WindowHoursImpl({required this.start, required this.end});

  factory _$WindowHoursImpl.fromJson(Map<String, dynamic> json) =>
      _$$WindowHoursImplFromJson(json);

  @override
  final String start;
  @override
  final String end;

  @override
  String toString() {
    return 'WindowHours(start: $start, end: $end)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WindowHoursImpl &&
            (identical(other.start, start) || other.start == start) &&
            (identical(other.end, end) || other.end == end));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, start, end);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WindowHoursImplCopyWith<_$WindowHoursImpl> get copyWith =>
      __$$WindowHoursImplCopyWithImpl<_$WindowHoursImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WindowHoursImplToJson(
      this,
    );
  }
}

abstract class _WindowHours implements WindowHours {
  const factory _WindowHours(
      {required final String start,
      required final String end}) = _$WindowHoursImpl;

  factory _WindowHours.fromJson(Map<String, dynamic> json) =
      _$WindowHoursImpl.fromJson;

  @override
  String get start;
  @override
  String get end;
  @override
  @JsonKey(ignore: true)
  _$$WindowHoursImplCopyWith<_$WindowHoursImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BusinessSettings _$BusinessSettingsFromJson(Map<String, dynamic> json) {
  return _BusinessSettings.fromJson(json);
}

/// @nodoc
mixin _$BusinessSettings {
  String get name => throw _privateConstructorUsedError;
  String get contactPhone => throw _privateConstructorUsedError;
  String get contactEmail => throw _privateConstructorUsedError;
  Address get address => throw _privateConstructorUsedError;

  /// Where pickups and deliveries are offered, e.g. "Cape Town and
  /// surrounds" — shown when booking.
  String get serviceArea => throw _privateConstructorUsedError;
  WindowHours get morning => throw _privateConstructorUsedError;
  WindowHours get afternoon => throw _privateConstructorUsedError;
  WindowHours get evening => throw _privateConstructorUsedError;

  /// How clients pay their monthly invoice — bank, account number, branch
  /// code. Shown on the client billing page with each invoice's EFT
  /// reference. Public like the rest of this doc, so banking details
  /// only, never logins.
  String get paymentInstructions => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  String? get updatedBy => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BusinessSettingsCopyWith<BusinessSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BusinessSettingsCopyWith<$Res> {
  factory $BusinessSettingsCopyWith(
          BusinessSettings value, $Res Function(BusinessSettings) then) =
      _$BusinessSettingsCopyWithImpl<$Res, BusinessSettings>;
  @useResult
  $Res call(
      {String name,
      String contactPhone,
      String contactEmail,
      Address address,
      String serviceArea,
      WindowHours morning,
      WindowHours afternoon,
      WindowHours evening,
      String paymentInstructions,
      @NullableTimestampConverter() DateTime? updatedAt,
      String? updatedBy});

  $AddressCopyWith<$Res> get address;
  $WindowHoursCopyWith<$Res> get morning;
  $WindowHoursCopyWith<$Res> get afternoon;
  $WindowHoursCopyWith<$Res> get evening;
}

/// @nodoc
class _$BusinessSettingsCopyWithImpl<$Res, $Val extends BusinessSettings>
    implements $BusinessSettingsCopyWith<$Res> {
  _$BusinessSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? contactPhone = null,
    Object? contactEmail = null,
    Object? address = null,
    Object? serviceArea = null,
    Object? morning = null,
    Object? afternoon = null,
    Object? evening = null,
    Object? paymentInstructions = null,
    Object? updatedAt = freezed,
    Object? updatedBy = freezed,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      contactPhone: null == contactPhone
          ? _value.contactPhone
          : contactPhone // ignore: cast_nullable_to_non_nullable
              as String,
      contactEmail: null == contactEmail
          ? _value.contactEmail
          : contactEmail // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as Address,
      serviceArea: null == serviceArea
          ? _value.serviceArea
          : serviceArea // ignore: cast_nullable_to_non_nullable
              as String,
      morning: null == morning
          ? _value.morning
          : morning // ignore: cast_nullable_to_non_nullable
              as WindowHours,
      afternoon: null == afternoon
          ? _value.afternoon
          : afternoon // ignore: cast_nullable_to_non_nullable
              as WindowHours,
      evening: null == evening
          ? _value.evening
          : evening // ignore: cast_nullable_to_non_nullable
              as WindowHours,
      paymentInstructions: null == paymentInstructions
          ? _value.paymentInstructions
          : paymentInstructions // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedBy: freezed == updatedBy
          ? _value.updatedBy
          : updatedBy // ignore: cast_nullable_to_non_nullable
              as String?,
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
  $WindowHoursCopyWith<$Res> get morning {
    return $WindowHoursCopyWith<$Res>(_value.morning, (value) {
      return _then(_value.copyWith(morning: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $WindowHoursCopyWith<$Res> get afternoon {
    return $WindowHoursCopyWith<$Res>(_value.afternoon, (value) {
      return _then(_value.copyWith(afternoon: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $WindowHoursCopyWith<$Res> get evening {
    return $WindowHoursCopyWith<$Res>(_value.evening, (value) {
      return _then(_value.copyWith(evening: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BusinessSettingsImplCopyWith<$Res>
    implements $BusinessSettingsCopyWith<$Res> {
  factory _$$BusinessSettingsImplCopyWith(_$BusinessSettingsImpl value,
          $Res Function(_$BusinessSettingsImpl) then) =
      __$$BusinessSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String contactPhone,
      String contactEmail,
      Address address,
      String serviceArea,
      WindowHours morning,
      WindowHours afternoon,
      WindowHours evening,
      String paymentInstructions,
      @NullableTimestampConverter() DateTime? updatedAt,
      String? updatedBy});

  @override
  $AddressCopyWith<$Res> get address;
  @override
  $WindowHoursCopyWith<$Res> get morning;
  @override
  $WindowHoursCopyWith<$Res> get afternoon;
  @override
  $WindowHoursCopyWith<$Res> get evening;
}

/// @nodoc
class __$$BusinessSettingsImplCopyWithImpl<$Res>
    extends _$BusinessSettingsCopyWithImpl<$Res, _$BusinessSettingsImpl>
    implements _$$BusinessSettingsImplCopyWith<$Res> {
  __$$BusinessSettingsImplCopyWithImpl(_$BusinessSettingsImpl _value,
      $Res Function(_$BusinessSettingsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? contactPhone = null,
    Object? contactEmail = null,
    Object? address = null,
    Object? serviceArea = null,
    Object? morning = null,
    Object? afternoon = null,
    Object? evening = null,
    Object? paymentInstructions = null,
    Object? updatedAt = freezed,
    Object? updatedBy = freezed,
  }) {
    return _then(_$BusinessSettingsImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      contactPhone: null == contactPhone
          ? _value.contactPhone
          : contactPhone // ignore: cast_nullable_to_non_nullable
              as String,
      contactEmail: null == contactEmail
          ? _value.contactEmail
          : contactEmail // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as Address,
      serviceArea: null == serviceArea
          ? _value.serviceArea
          : serviceArea // ignore: cast_nullable_to_non_nullable
              as String,
      morning: null == morning
          ? _value.morning
          : morning // ignore: cast_nullable_to_non_nullable
              as WindowHours,
      afternoon: null == afternoon
          ? _value.afternoon
          : afternoon // ignore: cast_nullable_to_non_nullable
              as WindowHours,
      evening: null == evening
          ? _value.evening
          : evening // ignore: cast_nullable_to_non_nullable
              as WindowHours,
      paymentInstructions: null == paymentInstructions
          ? _value.paymentInstructions
          : paymentInstructions // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedBy: freezed == updatedBy
          ? _value.updatedBy
          : updatedBy // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BusinessSettingsImpl extends _BusinessSettings {
  const _$BusinessSettingsImpl(
      {this.name = 'StrongBox Logistics',
      this.contactPhone = ContactInfo.phoneDisplay,
      this.contactEmail = ContactInfo.email,
      this.address = const Address(),
      this.serviceArea = 'Cape Town and surrounds',
      this.morning = const WindowHours(start: '08:00', end: '12:00'),
      this.afternoon = const WindowHours(start: '12:00', end: '16:00'),
      this.evening = const WindowHours(start: '16:00', end: '20:00'),
      this.paymentInstructions = '',
      @NullableTimestampConverter() this.updatedAt,
      this.updatedBy})
      : super._();

  factory _$BusinessSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$BusinessSettingsImplFromJson(json);

  @override
  @JsonKey()
  final String name;
  @override
  @JsonKey()
  final String contactPhone;
  @override
  @JsonKey()
  final String contactEmail;
  @override
  @JsonKey()
  final Address address;

  /// Where pickups and deliveries are offered, e.g. "Cape Town and
  /// surrounds" — shown when booking.
  @override
  @JsonKey()
  final String serviceArea;
  @override
  @JsonKey()
  final WindowHours morning;
  @override
  @JsonKey()
  final WindowHours afternoon;
  @override
  @JsonKey()
  final WindowHours evening;

  /// How clients pay their monthly invoice — bank, account number, branch
  /// code. Shown on the client billing page with each invoice's EFT
  /// reference. Public like the rest of this doc, so banking details
  /// only, never logins.
  @override
  @JsonKey()
  final String paymentInstructions;
  @override
  @NullableTimestampConverter()
  final DateTime? updatedAt;
  @override
  final String? updatedBy;

  @override
  String toString() {
    return 'BusinessSettings(name: $name, contactPhone: $contactPhone, contactEmail: $contactEmail, address: $address, serviceArea: $serviceArea, morning: $morning, afternoon: $afternoon, evening: $evening, paymentInstructions: $paymentInstructions, updatedAt: $updatedAt, updatedBy: $updatedBy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BusinessSettingsImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.contactPhone, contactPhone) ||
                other.contactPhone == contactPhone) &&
            (identical(other.contactEmail, contactEmail) ||
                other.contactEmail == contactEmail) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.serviceArea, serviceArea) ||
                other.serviceArea == serviceArea) &&
            (identical(other.morning, morning) || other.morning == morning) &&
            (identical(other.afternoon, afternoon) ||
                other.afternoon == afternoon) &&
            (identical(other.evening, evening) || other.evening == evening) &&
            (identical(other.paymentInstructions, paymentInstructions) ||
                other.paymentInstructions == paymentInstructions) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.updatedBy, updatedBy) ||
                other.updatedBy == updatedBy));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      name,
      contactPhone,
      contactEmail,
      address,
      serviceArea,
      morning,
      afternoon,
      evening,
      paymentInstructions,
      updatedAt,
      updatedBy);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BusinessSettingsImplCopyWith<_$BusinessSettingsImpl> get copyWith =>
      __$$BusinessSettingsImplCopyWithImpl<_$BusinessSettingsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BusinessSettingsImplToJson(
      this,
    );
  }
}

abstract class _BusinessSettings extends BusinessSettings {
  const factory _BusinessSettings(
      {final String name,
      final String contactPhone,
      final String contactEmail,
      final Address address,
      final String serviceArea,
      final WindowHours morning,
      final WindowHours afternoon,
      final WindowHours evening,
      final String paymentInstructions,
      @NullableTimestampConverter() final DateTime? updatedAt,
      final String? updatedBy}) = _$BusinessSettingsImpl;
  const _BusinessSettings._() : super._();

  factory _BusinessSettings.fromJson(Map<String, dynamic> json) =
      _$BusinessSettingsImpl.fromJson;

  @override
  String get name;
  @override
  String get contactPhone;
  @override
  String get contactEmail;
  @override
  Address get address;
  @override

  /// Where pickups and deliveries are offered, e.g. "Cape Town and
  /// surrounds" — shown when booking.
  String get serviceArea;
  @override
  WindowHours get morning;
  @override
  WindowHours get afternoon;
  @override
  WindowHours get evening;
  @override

  /// How clients pay their monthly invoice — bank, account number, branch
  /// code. Shown on the client billing page with each invoice's EFT
  /// reference. Public like the rest of this doc, so banking details
  /// only, never logins.
  String get paymentInstructions;
  @override
  @NullableTimestampConverter()
  DateTime? get updatedAt;
  @override
  String? get updatedBy;
  @override
  @JsonKey(ignore: true)
  _$$BusinessSettingsImplCopyWith<_$BusinessSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
