// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'value_objects.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Address _$AddressFromJson(Map<String, dynamic> json) {
  return _Address.fromJson(json);
}

/// @nodoc
mixin _$Address {
  String get line1 => throw _privateConstructorUsedError;
  String? get line2 => throw _privateConstructorUsedError;
  String get city => throw _privateConstructorUsedError;
  String? get state => throw _privateConstructorUsedError;
  String get postCode => throw _privateConstructorUsedError;
  String get country => throw _privateConstructorUsedError;
  double? get lat => throw _privateConstructorUsedError;
  double? get lng => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AddressCopyWith<Address> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AddressCopyWith<$Res> {
  factory $AddressCopyWith(Address value, $Res Function(Address) then) =
      _$AddressCopyWithImpl<$Res, Address>;
  @useResult
  $Res call(
      {String line1,
      String? line2,
      String city,
      String? state,
      String postCode,
      String country,
      double? lat,
      double? lng});
}

/// @nodoc
class _$AddressCopyWithImpl<$Res, $Val extends Address>
    implements $AddressCopyWith<$Res> {
  _$AddressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? line1 = null,
    Object? line2 = freezed,
    Object? city = null,
    Object? state = freezed,
    Object? postCode = null,
    Object? country = null,
    Object? lat = freezed,
    Object? lng = freezed,
  }) {
    return _then(_value.copyWith(
      line1: null == line1
          ? _value.line1
          : line1 // ignore: cast_nullable_to_non_nullable
              as String,
      line2: freezed == line2
          ? _value.line2
          : line2 // ignore: cast_nullable_to_non_nullable
              as String?,
      city: null == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String,
      state: freezed == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
      postCode: null == postCode
          ? _value.postCode
          : postCode // ignore: cast_nullable_to_non_nullable
              as String,
      country: null == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String,
      lat: freezed == lat
          ? _value.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double?,
      lng: freezed == lng
          ? _value.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AddressImplCopyWith<$Res> implements $AddressCopyWith<$Res> {
  factory _$$AddressImplCopyWith(
          _$AddressImpl value, $Res Function(_$AddressImpl) then) =
      __$$AddressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String line1,
      String? line2,
      String city,
      String? state,
      String postCode,
      String country,
      double? lat,
      double? lng});
}

/// @nodoc
class __$$AddressImplCopyWithImpl<$Res>
    extends _$AddressCopyWithImpl<$Res, _$AddressImpl>
    implements _$$AddressImplCopyWith<$Res> {
  __$$AddressImplCopyWithImpl(
      _$AddressImpl _value, $Res Function(_$AddressImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? line1 = null,
    Object? line2 = freezed,
    Object? city = null,
    Object? state = freezed,
    Object? postCode = null,
    Object? country = null,
    Object? lat = freezed,
    Object? lng = freezed,
  }) {
    return _then(_$AddressImpl(
      line1: null == line1
          ? _value.line1
          : line1 // ignore: cast_nullable_to_non_nullable
              as String,
      line2: freezed == line2
          ? _value.line2
          : line2 // ignore: cast_nullable_to_non_nullable
              as String?,
      city: null == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String,
      state: freezed == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
      postCode: null == postCode
          ? _value.postCode
          : postCode // ignore: cast_nullable_to_non_nullable
              as String,
      country: null == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String,
      lat: freezed == lat
          ? _value.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double?,
      lng: freezed == lng
          ? _value.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AddressImpl implements _Address {
  const _$AddressImpl(
      {this.line1 = '',
      this.line2,
      this.city = '',
      this.state,
      this.postCode = '',
      this.country = 'ZA',
      this.lat,
      this.lng});

  factory _$AddressImpl.fromJson(Map<String, dynamic> json) =>
      _$$AddressImplFromJson(json);

  @override
  @JsonKey()
  final String line1;
  @override
  final String? line2;
  @override
  @JsonKey()
  final String city;
  @override
  final String? state;
  @override
  @JsonKey()
  final String postCode;
  @override
  @JsonKey()
  final String country;
  @override
  final double? lat;
  @override
  final double? lng;

  @override
  String toString() {
    return 'Address(line1: $line1, line2: $line2, city: $city, state: $state, postCode: $postCode, country: $country, lat: $lat, lng: $lng)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AddressImpl &&
            (identical(other.line1, line1) || other.line1 == line1) &&
            (identical(other.line2, line2) || other.line2 == line2) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.postCode, postCode) ||
                other.postCode == postCode) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, line1, line2, city, state, postCode, country, lat, lng);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AddressImplCopyWith<_$AddressImpl> get copyWith =>
      __$$AddressImplCopyWithImpl<_$AddressImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AddressImplToJson(
      this,
    );
  }
}

abstract class _Address implements Address {
  const factory _Address(
      {final String line1,
      final String? line2,
      final String city,
      final String? state,
      final String postCode,
      final String country,
      final double? lat,
      final double? lng}) = _$AddressImpl;

  factory _Address.fromJson(Map<String, dynamic> json) = _$AddressImpl.fromJson;

  @override
  String get line1;
  @override
  String? get line2;
  @override
  String get city;
  @override
  String? get state;
  @override
  String get postCode;
  @override
  String get country;
  @override
  double? get lat;
  @override
  double? get lng;
  @override
  @JsonKey(ignore: true)
  _$$AddressImplCopyWith<_$AddressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

NotificationPrefs _$NotificationPrefsFromJson(Map<String, dynamic> json) {
  return _NotificationPrefs.fromJson(json);
}

/// @nodoc
mixin _$NotificationPrefs {
  bool get pickupStartedEmail => throw _privateConstructorUsedError;
  bool get pickupStartedSms => throw _privateConstructorUsedError;
  bool get deliveryCompletedEmail => throw _privateConstructorUsedError;
  bool get deliveryCompletedSms => throw _privateConstructorUsedError;
  bool get invoiceReadyEmail => throw _privateConstructorUsedError;
  bool get invoiceReadySms => throw _privateConstructorUsedError;
  bool get storageThresholdEmail => throw _privateConstructorUsedError;
  bool get storageThresholdSms => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $NotificationPrefsCopyWith<NotificationPrefs> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationPrefsCopyWith<$Res> {
  factory $NotificationPrefsCopyWith(
          NotificationPrefs value, $Res Function(NotificationPrefs) then) =
      _$NotificationPrefsCopyWithImpl<$Res, NotificationPrefs>;
  @useResult
  $Res call(
      {bool pickupStartedEmail,
      bool pickupStartedSms,
      bool deliveryCompletedEmail,
      bool deliveryCompletedSms,
      bool invoiceReadyEmail,
      bool invoiceReadySms,
      bool storageThresholdEmail,
      bool storageThresholdSms});
}

/// @nodoc
class _$NotificationPrefsCopyWithImpl<$Res, $Val extends NotificationPrefs>
    implements $NotificationPrefsCopyWith<$Res> {
  _$NotificationPrefsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pickupStartedEmail = null,
    Object? pickupStartedSms = null,
    Object? deliveryCompletedEmail = null,
    Object? deliveryCompletedSms = null,
    Object? invoiceReadyEmail = null,
    Object? invoiceReadySms = null,
    Object? storageThresholdEmail = null,
    Object? storageThresholdSms = null,
  }) {
    return _then(_value.copyWith(
      pickupStartedEmail: null == pickupStartedEmail
          ? _value.pickupStartedEmail
          : pickupStartedEmail // ignore: cast_nullable_to_non_nullable
              as bool,
      pickupStartedSms: null == pickupStartedSms
          ? _value.pickupStartedSms
          : pickupStartedSms // ignore: cast_nullable_to_non_nullable
              as bool,
      deliveryCompletedEmail: null == deliveryCompletedEmail
          ? _value.deliveryCompletedEmail
          : deliveryCompletedEmail // ignore: cast_nullable_to_non_nullable
              as bool,
      deliveryCompletedSms: null == deliveryCompletedSms
          ? _value.deliveryCompletedSms
          : deliveryCompletedSms // ignore: cast_nullable_to_non_nullable
              as bool,
      invoiceReadyEmail: null == invoiceReadyEmail
          ? _value.invoiceReadyEmail
          : invoiceReadyEmail // ignore: cast_nullable_to_non_nullable
              as bool,
      invoiceReadySms: null == invoiceReadySms
          ? _value.invoiceReadySms
          : invoiceReadySms // ignore: cast_nullable_to_non_nullable
              as bool,
      storageThresholdEmail: null == storageThresholdEmail
          ? _value.storageThresholdEmail
          : storageThresholdEmail // ignore: cast_nullable_to_non_nullable
              as bool,
      storageThresholdSms: null == storageThresholdSms
          ? _value.storageThresholdSms
          : storageThresholdSms // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationPrefsImplCopyWith<$Res>
    implements $NotificationPrefsCopyWith<$Res> {
  factory _$$NotificationPrefsImplCopyWith(_$NotificationPrefsImpl value,
          $Res Function(_$NotificationPrefsImpl) then) =
      __$$NotificationPrefsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool pickupStartedEmail,
      bool pickupStartedSms,
      bool deliveryCompletedEmail,
      bool deliveryCompletedSms,
      bool invoiceReadyEmail,
      bool invoiceReadySms,
      bool storageThresholdEmail,
      bool storageThresholdSms});
}

/// @nodoc
class __$$NotificationPrefsImplCopyWithImpl<$Res>
    extends _$NotificationPrefsCopyWithImpl<$Res, _$NotificationPrefsImpl>
    implements _$$NotificationPrefsImplCopyWith<$Res> {
  __$$NotificationPrefsImplCopyWithImpl(_$NotificationPrefsImpl _value,
      $Res Function(_$NotificationPrefsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pickupStartedEmail = null,
    Object? pickupStartedSms = null,
    Object? deliveryCompletedEmail = null,
    Object? deliveryCompletedSms = null,
    Object? invoiceReadyEmail = null,
    Object? invoiceReadySms = null,
    Object? storageThresholdEmail = null,
    Object? storageThresholdSms = null,
  }) {
    return _then(_$NotificationPrefsImpl(
      pickupStartedEmail: null == pickupStartedEmail
          ? _value.pickupStartedEmail
          : pickupStartedEmail // ignore: cast_nullable_to_non_nullable
              as bool,
      pickupStartedSms: null == pickupStartedSms
          ? _value.pickupStartedSms
          : pickupStartedSms // ignore: cast_nullable_to_non_nullable
              as bool,
      deliveryCompletedEmail: null == deliveryCompletedEmail
          ? _value.deliveryCompletedEmail
          : deliveryCompletedEmail // ignore: cast_nullable_to_non_nullable
              as bool,
      deliveryCompletedSms: null == deliveryCompletedSms
          ? _value.deliveryCompletedSms
          : deliveryCompletedSms // ignore: cast_nullable_to_non_nullable
              as bool,
      invoiceReadyEmail: null == invoiceReadyEmail
          ? _value.invoiceReadyEmail
          : invoiceReadyEmail // ignore: cast_nullable_to_non_nullable
              as bool,
      invoiceReadySms: null == invoiceReadySms
          ? _value.invoiceReadySms
          : invoiceReadySms // ignore: cast_nullable_to_non_nullable
              as bool,
      storageThresholdEmail: null == storageThresholdEmail
          ? _value.storageThresholdEmail
          : storageThresholdEmail // ignore: cast_nullable_to_non_nullable
              as bool,
      storageThresholdSms: null == storageThresholdSms
          ? _value.storageThresholdSms
          : storageThresholdSms // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationPrefsImpl implements _NotificationPrefs {
  const _$NotificationPrefsImpl(
      {this.pickupStartedEmail = true,
      this.pickupStartedSms = false,
      this.deliveryCompletedEmail = true,
      this.deliveryCompletedSms = true,
      this.invoiceReadyEmail = true,
      this.invoiceReadySms = false,
      this.storageThresholdEmail = true,
      this.storageThresholdSms = false});

  factory _$NotificationPrefsImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationPrefsImplFromJson(json);

  @override
  @JsonKey()
  final bool pickupStartedEmail;
  @override
  @JsonKey()
  final bool pickupStartedSms;
  @override
  @JsonKey()
  final bool deliveryCompletedEmail;
  @override
  @JsonKey()
  final bool deliveryCompletedSms;
  @override
  @JsonKey()
  final bool invoiceReadyEmail;
  @override
  @JsonKey()
  final bool invoiceReadySms;
  @override
  @JsonKey()
  final bool storageThresholdEmail;
  @override
  @JsonKey()
  final bool storageThresholdSms;

  @override
  String toString() {
    return 'NotificationPrefs(pickupStartedEmail: $pickupStartedEmail, pickupStartedSms: $pickupStartedSms, deliveryCompletedEmail: $deliveryCompletedEmail, deliveryCompletedSms: $deliveryCompletedSms, invoiceReadyEmail: $invoiceReadyEmail, invoiceReadySms: $invoiceReadySms, storageThresholdEmail: $storageThresholdEmail, storageThresholdSms: $storageThresholdSms)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationPrefsImpl &&
            (identical(other.pickupStartedEmail, pickupStartedEmail) ||
                other.pickupStartedEmail == pickupStartedEmail) &&
            (identical(other.pickupStartedSms, pickupStartedSms) ||
                other.pickupStartedSms == pickupStartedSms) &&
            (identical(other.deliveryCompletedEmail, deliveryCompletedEmail) ||
                other.deliveryCompletedEmail == deliveryCompletedEmail) &&
            (identical(other.deliveryCompletedSms, deliveryCompletedSms) ||
                other.deliveryCompletedSms == deliveryCompletedSms) &&
            (identical(other.invoiceReadyEmail, invoiceReadyEmail) ||
                other.invoiceReadyEmail == invoiceReadyEmail) &&
            (identical(other.invoiceReadySms, invoiceReadySms) ||
                other.invoiceReadySms == invoiceReadySms) &&
            (identical(other.storageThresholdEmail, storageThresholdEmail) ||
                other.storageThresholdEmail == storageThresholdEmail) &&
            (identical(other.storageThresholdSms, storageThresholdSms) ||
                other.storageThresholdSms == storageThresholdSms));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      pickupStartedEmail,
      pickupStartedSms,
      deliveryCompletedEmail,
      deliveryCompletedSms,
      invoiceReadyEmail,
      invoiceReadySms,
      storageThresholdEmail,
      storageThresholdSms);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationPrefsImplCopyWith<_$NotificationPrefsImpl> get copyWith =>
      __$$NotificationPrefsImplCopyWithImpl<_$NotificationPrefsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationPrefsImplToJson(
      this,
    );
  }
}

abstract class _NotificationPrefs implements NotificationPrefs {
  const factory _NotificationPrefs(
      {final bool pickupStartedEmail,
      final bool pickupStartedSms,
      final bool deliveryCompletedEmail,
      final bool deliveryCompletedSms,
      final bool invoiceReadyEmail,
      final bool invoiceReadySms,
      final bool storageThresholdEmail,
      final bool storageThresholdSms}) = _$NotificationPrefsImpl;

  factory _NotificationPrefs.fromJson(Map<String, dynamic> json) =
      _$NotificationPrefsImpl.fromJson;

  @override
  bool get pickupStartedEmail;
  @override
  bool get pickupStartedSms;
  @override
  bool get deliveryCompletedEmail;
  @override
  bool get deliveryCompletedSms;
  @override
  bool get invoiceReadyEmail;
  @override
  bool get invoiceReadySms;
  @override
  bool get storageThresholdEmail;
  @override
  bool get storageThresholdSms;
  @override
  @JsonKey(ignore: true)
  _$$NotificationPrefsImplCopyWith<_$NotificationPrefsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BreakPeriod _$BreakPeriodFromJson(Map<String, dynamic> json) {
  return _BreakPeriod.fromJson(json);
}

/// @nodoc
mixin _$BreakPeriod {
  DateTime get startedAt => throw _privateConstructorUsedError;
  DateTime? get endedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BreakPeriodCopyWith<BreakPeriod> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BreakPeriodCopyWith<$Res> {
  factory $BreakPeriodCopyWith(
          BreakPeriod value, $Res Function(BreakPeriod) then) =
      _$BreakPeriodCopyWithImpl<$Res, BreakPeriod>;
  @useResult
  $Res call({DateTime startedAt, DateTime? endedAt});
}

/// @nodoc
class _$BreakPeriodCopyWithImpl<$Res, $Val extends BreakPeriod>
    implements $BreakPeriodCopyWith<$Res> {
  _$BreakPeriodCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startedAt = null,
    Object? endedAt = freezed,
  }) {
    return _then(_value.copyWith(
      startedAt: null == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endedAt: freezed == endedAt
          ? _value.endedAt
          : endedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BreakPeriodImplCopyWith<$Res>
    implements $BreakPeriodCopyWith<$Res> {
  factory _$$BreakPeriodImplCopyWith(
          _$BreakPeriodImpl value, $Res Function(_$BreakPeriodImpl) then) =
      __$$BreakPeriodImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime startedAt, DateTime? endedAt});
}

/// @nodoc
class __$$BreakPeriodImplCopyWithImpl<$Res>
    extends _$BreakPeriodCopyWithImpl<$Res, _$BreakPeriodImpl>
    implements _$$BreakPeriodImplCopyWith<$Res> {
  __$$BreakPeriodImplCopyWithImpl(
      _$BreakPeriodImpl _value, $Res Function(_$BreakPeriodImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startedAt = null,
    Object? endedAt = freezed,
  }) {
    return _then(_$BreakPeriodImpl(
      startedAt: null == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endedAt: freezed == endedAt
          ? _value.endedAt
          : endedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BreakPeriodImpl implements _BreakPeriod {
  const _$BreakPeriodImpl({required this.startedAt, this.endedAt});

  factory _$BreakPeriodImpl.fromJson(Map<String, dynamic> json) =>
      _$$BreakPeriodImplFromJson(json);

  @override
  final DateTime startedAt;
  @override
  final DateTime? endedAt;

  @override
  String toString() {
    return 'BreakPeriod(startedAt: $startedAt, endedAt: $endedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BreakPeriodImpl &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.endedAt, endedAt) || other.endedAt == endedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, startedAt, endedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BreakPeriodImplCopyWith<_$BreakPeriodImpl> get copyWith =>
      __$$BreakPeriodImplCopyWithImpl<_$BreakPeriodImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BreakPeriodImplToJson(
      this,
    );
  }
}

abstract class _BreakPeriod implements BreakPeriod {
  const factory _BreakPeriod(
      {required final DateTime startedAt,
      final DateTime? endedAt}) = _$BreakPeriodImpl;

  factory _BreakPeriod.fromJson(Map<String, dynamic> json) =
      _$BreakPeriodImpl.fromJson;

  @override
  DateTime get startedAt;
  @override
  DateTime? get endedAt;
  @override
  @JsonKey(ignore: true)
  _$$BreakPeriodImplCopyWith<_$BreakPeriodImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
