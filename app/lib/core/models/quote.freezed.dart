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

QuoteDraft _$QuoteDraftFromJson(Map<String, dynamic> json) {
  return _QuoteDraft.fromJson(json);
}

/// @nodoc
mixin _$QuoteDraft {
  Map<String, int> get boxes => throw _privateConstructorUsedError;
  Map<String, int> get loose => throw _privateConstructorUsedError;
  String? get vehicleId => throw _privateConstructorUsedError;

  /// Packing supplies by price-list id (once-off each).
  Map<String, int> get supplies => throw _privateConstructorUsedError;

  /// Packing-helper hours on pickup day (0 = none).
  int get helperHours => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $QuoteDraftCopyWith<QuoteDraft> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuoteDraftCopyWith<$Res> {
  factory $QuoteDraftCopyWith(
          QuoteDraft value, $Res Function(QuoteDraft) then) =
      _$QuoteDraftCopyWithImpl<$Res, QuoteDraft>;
  @useResult
  $Res call(
      {Map<String, int> boxes,
      Map<String, int> loose,
      String? vehicleId,
      Map<String, int> supplies,
      int helperHours});
}

/// @nodoc
class _$QuoteDraftCopyWithImpl<$Res, $Val extends QuoteDraft>
    implements $QuoteDraftCopyWith<$Res> {
  _$QuoteDraftCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? boxes = null,
    Object? loose = null,
    Object? vehicleId = freezed,
    Object? supplies = null,
    Object? helperHours = null,
  }) {
    return _then(_value.copyWith(
      boxes: null == boxes
          ? _value.boxes
          : boxes // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      loose: null == loose
          ? _value.loose
          : loose // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      vehicleId: freezed == vehicleId
          ? _value.vehicleId
          : vehicleId // ignore: cast_nullable_to_non_nullable
              as String?,
      supplies: null == supplies
          ? _value.supplies
          : supplies // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      helperHours: null == helperHours
          ? _value.helperHours
          : helperHours // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QuoteDraftImplCopyWith<$Res>
    implements $QuoteDraftCopyWith<$Res> {
  factory _$$QuoteDraftImplCopyWith(
          _$QuoteDraftImpl value, $Res Function(_$QuoteDraftImpl) then) =
      __$$QuoteDraftImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Map<String, int> boxes,
      Map<String, int> loose,
      String? vehicleId,
      Map<String, int> supplies,
      int helperHours});
}

/// @nodoc
class __$$QuoteDraftImplCopyWithImpl<$Res>
    extends _$QuoteDraftCopyWithImpl<$Res, _$QuoteDraftImpl>
    implements _$$QuoteDraftImplCopyWith<$Res> {
  __$$QuoteDraftImplCopyWithImpl(
      _$QuoteDraftImpl _value, $Res Function(_$QuoteDraftImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? boxes = null,
    Object? loose = null,
    Object? vehicleId = freezed,
    Object? supplies = null,
    Object? helperHours = null,
  }) {
    return _then(_$QuoteDraftImpl(
      boxes: null == boxes
          ? _value._boxes
          : boxes // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      loose: null == loose
          ? _value._loose
          : loose // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      vehicleId: freezed == vehicleId
          ? _value.vehicleId
          : vehicleId // ignore: cast_nullable_to_non_nullable
              as String?,
      supplies: null == supplies
          ? _value._supplies
          : supplies // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      helperHours: null == helperHours
          ? _value.helperHours
          : helperHours // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$QuoteDraftImpl extends _QuoteDraft {
  const _$QuoteDraftImpl(
      {final Map<String, int> boxes = const {},
      final Map<String, int> loose = const {},
      this.vehicleId,
      final Map<String, int> supplies = const {},
      this.helperHours = 0})
      : _boxes = boxes,
        _loose = loose,
        _supplies = supplies,
        super._();

  factory _$QuoteDraftImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuoteDraftImplFromJson(json);

  final Map<String, int> _boxes;
  @override
  @JsonKey()
  Map<String, int> get boxes {
    if (_boxes is EqualUnmodifiableMapView) return _boxes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_boxes);
  }

  final Map<String, int> _loose;
  @override
  @JsonKey()
  Map<String, int> get loose {
    if (_loose is EqualUnmodifiableMapView) return _loose;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_loose);
  }

  @override
  final String? vehicleId;

  /// Packing supplies by price-list id (once-off each).
  final Map<String, int> _supplies;

  /// Packing supplies by price-list id (once-off each).
  @override
  @JsonKey()
  Map<String, int> get supplies {
    if (_supplies is EqualUnmodifiableMapView) return _supplies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_supplies);
  }

  /// Packing-helper hours on pickup day (0 = none).
  @override
  @JsonKey()
  final int helperHours;

  @override
  String toString() {
    return 'QuoteDraft(boxes: $boxes, loose: $loose, vehicleId: $vehicleId, supplies: $supplies, helperHours: $helperHours)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuoteDraftImpl &&
            const DeepCollectionEquality().equals(other._boxes, _boxes) &&
            const DeepCollectionEquality().equals(other._loose, _loose) &&
            (identical(other.vehicleId, vehicleId) ||
                other.vehicleId == vehicleId) &&
            const DeepCollectionEquality().equals(other._supplies, _supplies) &&
            (identical(other.helperHours, helperHours) ||
                other.helperHours == helperHours));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_boxes),
      const DeepCollectionEquality().hash(_loose),
      vehicleId,
      const DeepCollectionEquality().hash(_supplies),
      helperHours);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$QuoteDraftImplCopyWith<_$QuoteDraftImpl> get copyWith =>
      __$$QuoteDraftImplCopyWithImpl<_$QuoteDraftImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QuoteDraftImplToJson(
      this,
    );
  }
}

abstract class _QuoteDraft extends QuoteDraft {
  const factory _QuoteDraft(
      {final Map<String, int> boxes,
      final Map<String, int> loose,
      final String? vehicleId,
      final Map<String, int> supplies,
      final int helperHours}) = _$QuoteDraftImpl;
  const _QuoteDraft._() : super._();

  factory _QuoteDraft.fromJson(Map<String, dynamic> json) =
      _$QuoteDraftImpl.fromJson;

  @override
  Map<String, int> get boxes;
  @override
  Map<String, int> get loose;
  @override
  String? get vehicleId;
  @override

  /// Packing supplies by price-list id (once-off each).
  Map<String, int> get supplies;
  @override

  /// Packing-helper hours on pickup day (0 = none).
  int get helperHours;
  @override
  @JsonKey(ignore: true)
  _$$QuoteDraftImplCopyWith<_$QuoteDraftImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
