// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'price_catalog.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BoxPrice _$BoxPriceFromJson(Map<String, dynamic> json) {
  return _BoxPrice.fromJson(json);
}

/// @nodoc
mixin _$BoxPrice {
  String get id => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  @JsonKey(name: 'desc')
  String get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'price')
  int get monthlyZar => throw _privateConstructorUsedError;

  /// False once retired: hidden from the website and from new units, but
  /// still names the units already stored under it.
  bool get active => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BoxPriceCopyWith<BoxPrice> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BoxPriceCopyWith<$Res> {
  factory $BoxPriceCopyWith(BoxPrice value, $Res Function(BoxPrice) then) =
      _$BoxPriceCopyWithImpl<$Res, BoxPrice>;
  @useResult
  $Res call(
      {String id,
      String label,
      @JsonKey(name: 'desc') String description,
      @JsonKey(name: 'price') int monthlyZar,
      bool active});
}

/// @nodoc
class _$BoxPriceCopyWithImpl<$Res, $Val extends BoxPrice>
    implements $BoxPriceCopyWith<$Res> {
  _$BoxPriceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? description = null,
    Object? monthlyZar = null,
    Object? active = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      monthlyZar: null == monthlyZar
          ? _value.monthlyZar
          : monthlyZar // ignore: cast_nullable_to_non_nullable
              as int,
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BoxPriceImplCopyWith<$Res>
    implements $BoxPriceCopyWith<$Res> {
  factory _$$BoxPriceImplCopyWith(
          _$BoxPriceImpl value, $Res Function(_$BoxPriceImpl) then) =
      __$$BoxPriceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String label,
      @JsonKey(name: 'desc') String description,
      @JsonKey(name: 'price') int monthlyZar,
      bool active});
}

/// @nodoc
class __$$BoxPriceImplCopyWithImpl<$Res>
    extends _$BoxPriceCopyWithImpl<$Res, _$BoxPriceImpl>
    implements _$$BoxPriceImplCopyWith<$Res> {
  __$$BoxPriceImplCopyWithImpl(
      _$BoxPriceImpl _value, $Res Function(_$BoxPriceImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? description = null,
    Object? monthlyZar = null,
    Object? active = null,
  }) {
    return _then(_$BoxPriceImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      monthlyZar: null == monthlyZar
          ? _value.monthlyZar
          : monthlyZar // ignore: cast_nullable_to_non_nullable
              as int,
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BoxPriceImpl implements _BoxPrice {
  const _$BoxPriceImpl(
      {required this.id,
      required this.label,
      @JsonKey(name: 'desc') this.description = '',
      @JsonKey(name: 'price') required this.monthlyZar,
      this.active = true});

  factory _$BoxPriceImpl.fromJson(Map<String, dynamic> json) =>
      _$$BoxPriceImplFromJson(json);

  @override
  final String id;
  @override
  final String label;
  @override
  @JsonKey(name: 'desc')
  final String description;
  @override
  @JsonKey(name: 'price')
  final int monthlyZar;

  /// False once retired: hidden from the website and from new units, but
  /// still names the units already stored under it.
  @override
  @JsonKey()
  final bool active;

  @override
  String toString() {
    return 'BoxPrice(id: $id, label: $label, description: $description, monthlyZar: $monthlyZar, active: $active)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BoxPriceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.monthlyZar, monthlyZar) ||
                other.monthlyZar == monthlyZar) &&
            (identical(other.active, active) || other.active == active));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, label, description, monthlyZar, active);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BoxPriceImplCopyWith<_$BoxPriceImpl> get copyWith =>
      __$$BoxPriceImplCopyWithImpl<_$BoxPriceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BoxPriceImplToJson(
      this,
    );
  }
}

abstract class _BoxPrice implements BoxPrice {
  const factory _BoxPrice(
      {required final String id,
      required final String label,
      @JsonKey(name: 'desc') final String description,
      @JsonKey(name: 'price') required final int monthlyZar,
      final bool active}) = _$BoxPriceImpl;

  factory _BoxPrice.fromJson(Map<String, dynamic> json) =
      _$BoxPriceImpl.fromJson;

  @override
  String get id;
  @override
  String get label;
  @override
  @JsonKey(name: 'desc')
  String get description;
  @override
  @JsonKey(name: 'price')
  int get monthlyZar;
  @override

  /// False once retired: hidden from the website and from new units, but
  /// still names the units already stored under it.
  bool get active;
  @override
  @JsonKey(ignore: true)
  _$$BoxPriceImplCopyWith<_$BoxPriceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LooseItemPrice _$LooseItemPriceFromJson(Map<String, dynamic> json) {
  return _LooseItemPrice.fromJson(json);
}

/// @nodoc
mixin _$LooseItemPrice {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;

  /// Material Symbols name used by the website — one of
  /// [PriceCatalog.itemIcons].
  String get icon => throw _privateConstructorUsedError;
  @JsonKey(name: 'price')
  int get monthlyZar => throw _privateConstructorUsedError;
  bool get active => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LooseItemPriceCopyWith<LooseItemPrice> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LooseItemPriceCopyWith<$Res> {
  factory $LooseItemPriceCopyWith(
          LooseItemPrice value, $Res Function(LooseItemPrice) then) =
      _$LooseItemPriceCopyWithImpl<$Res, LooseItemPrice>;
  @useResult
  $Res call(
      {String id,
      String name,
      String category,
      String icon,
      @JsonKey(name: 'price') int monthlyZar,
      bool active});
}

/// @nodoc
class _$LooseItemPriceCopyWithImpl<$Res, $Val extends LooseItemPrice>
    implements $LooseItemPriceCopyWith<$Res> {
  _$LooseItemPriceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? category = null,
    Object? icon = null,
    Object? monthlyZar = null,
    Object? active = null,
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
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      monthlyZar: null == monthlyZar
          ? _value.monthlyZar
          : monthlyZar // ignore: cast_nullable_to_non_nullable
              as int,
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LooseItemPriceImplCopyWith<$Res>
    implements $LooseItemPriceCopyWith<$Res> {
  factory _$$LooseItemPriceImplCopyWith(_$LooseItemPriceImpl value,
          $Res Function(_$LooseItemPriceImpl) then) =
      __$$LooseItemPriceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String category,
      String icon,
      @JsonKey(name: 'price') int monthlyZar,
      bool active});
}

/// @nodoc
class __$$LooseItemPriceImplCopyWithImpl<$Res>
    extends _$LooseItemPriceCopyWithImpl<$Res, _$LooseItemPriceImpl>
    implements _$$LooseItemPriceImplCopyWith<$Res> {
  __$$LooseItemPriceImplCopyWithImpl(
      _$LooseItemPriceImpl _value, $Res Function(_$LooseItemPriceImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? category = null,
    Object? icon = null,
    Object? monthlyZar = null,
    Object? active = null,
  }) {
    return _then(_$LooseItemPriceImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      monthlyZar: null == monthlyZar
          ? _value.monthlyZar
          : monthlyZar // ignore: cast_nullable_to_non_nullable
              as int,
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LooseItemPriceImpl implements _LooseItemPrice {
  const _$LooseItemPriceImpl(
      {required this.id,
      required this.name,
      required this.category,
      this.icon = 'inventory_2',
      @JsonKey(name: 'price') required this.monthlyZar,
      this.active = true});

  factory _$LooseItemPriceImpl.fromJson(Map<String, dynamic> json) =>
      _$$LooseItemPriceImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String category;

  /// Material Symbols name used by the website — one of
  /// [PriceCatalog.itemIcons].
  @override
  @JsonKey()
  final String icon;
  @override
  @JsonKey(name: 'price')
  final int monthlyZar;
  @override
  @JsonKey()
  final bool active;

  @override
  String toString() {
    return 'LooseItemPrice(id: $id, name: $name, category: $category, icon: $icon, monthlyZar: $monthlyZar, active: $active)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LooseItemPriceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.monthlyZar, monthlyZar) ||
                other.monthlyZar == monthlyZar) &&
            (identical(other.active, active) || other.active == active));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, category, icon, monthlyZar, active);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LooseItemPriceImplCopyWith<_$LooseItemPriceImpl> get copyWith =>
      __$$LooseItemPriceImplCopyWithImpl<_$LooseItemPriceImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LooseItemPriceImplToJson(
      this,
    );
  }
}

abstract class _LooseItemPrice implements LooseItemPrice {
  const factory _LooseItemPrice(
      {required final String id,
      required final String name,
      required final String category,
      final String icon,
      @JsonKey(name: 'price') required final int monthlyZar,
      final bool active}) = _$LooseItemPriceImpl;

  factory _LooseItemPrice.fromJson(Map<String, dynamic> json) =
      _$LooseItemPriceImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get category;
  @override

  /// Material Symbols name used by the website — one of
  /// [PriceCatalog.itemIcons].
  String get icon;
  @override
  @JsonKey(name: 'price')
  int get monthlyZar;
  @override
  bool get active;
  @override
  @JsonKey(ignore: true)
  _$$LooseItemPriceImplCopyWith<_$LooseItemPriceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VehiclePrice _$VehiclePriceFromJson(Map<String, dynamic> json) {
  return _VehiclePrice.fromJson(json);
}

/// @nodoc
mixin _$VehiclePrice {
  String get id => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  @JsonKey(name: 'desc')
  String get description => throw _privateConstructorUsedError;
  double get capacityM3 => throw _privateConstructorUsedError;
  @JsonKey(name: 'price')
  int get onceOffZar => throw _privateConstructorUsedError;
  bool get recommended => throw _privateConstructorUsedError;

  /// Material Symbols name the website's calculator shows.
  String get icon => throw _privateConstructorUsedError;
  bool get active => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $VehiclePriceCopyWith<VehiclePrice> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VehiclePriceCopyWith<$Res> {
  factory $VehiclePriceCopyWith(
          VehiclePrice value, $Res Function(VehiclePrice) then) =
      _$VehiclePriceCopyWithImpl<$Res, VehiclePrice>;
  @useResult
  $Res call(
      {String id,
      String label,
      @JsonKey(name: 'desc') String description,
      double capacityM3,
      @JsonKey(name: 'price') int onceOffZar,
      bool recommended,
      String icon,
      bool active});
}

/// @nodoc
class _$VehiclePriceCopyWithImpl<$Res, $Val extends VehiclePrice>
    implements $VehiclePriceCopyWith<$Res> {
  _$VehiclePriceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? description = null,
    Object? capacityM3 = null,
    Object? onceOffZar = null,
    Object? recommended = null,
    Object? icon = null,
    Object? active = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      capacityM3: null == capacityM3
          ? _value.capacityM3
          : capacityM3 // ignore: cast_nullable_to_non_nullable
              as double,
      onceOffZar: null == onceOffZar
          ? _value.onceOffZar
          : onceOffZar // ignore: cast_nullable_to_non_nullable
              as int,
      recommended: null == recommended
          ? _value.recommended
          : recommended // ignore: cast_nullable_to_non_nullable
              as bool,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VehiclePriceImplCopyWith<$Res>
    implements $VehiclePriceCopyWith<$Res> {
  factory _$$VehiclePriceImplCopyWith(
          _$VehiclePriceImpl value, $Res Function(_$VehiclePriceImpl) then) =
      __$$VehiclePriceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String label,
      @JsonKey(name: 'desc') String description,
      double capacityM3,
      @JsonKey(name: 'price') int onceOffZar,
      bool recommended,
      String icon,
      bool active});
}

/// @nodoc
class __$$VehiclePriceImplCopyWithImpl<$Res>
    extends _$VehiclePriceCopyWithImpl<$Res, _$VehiclePriceImpl>
    implements _$$VehiclePriceImplCopyWith<$Res> {
  __$$VehiclePriceImplCopyWithImpl(
      _$VehiclePriceImpl _value, $Res Function(_$VehiclePriceImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? description = null,
    Object? capacityM3 = null,
    Object? onceOffZar = null,
    Object? recommended = null,
    Object? icon = null,
    Object? active = null,
  }) {
    return _then(_$VehiclePriceImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      capacityM3: null == capacityM3
          ? _value.capacityM3
          : capacityM3 // ignore: cast_nullable_to_non_nullable
              as double,
      onceOffZar: null == onceOffZar
          ? _value.onceOffZar
          : onceOffZar // ignore: cast_nullable_to_non_nullable
              as int,
      recommended: null == recommended
          ? _value.recommended
          : recommended // ignore: cast_nullable_to_non_nullable
              as bool,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VehiclePriceImpl implements _VehiclePrice {
  const _$VehiclePriceImpl(
      {required this.id,
      required this.label,
      @JsonKey(name: 'desc') this.description = '',
      this.capacityM3 = 0.0,
      @JsonKey(name: 'price') required this.onceOffZar,
      this.recommended = false,
      this.icon = 'local_shipping',
      this.active = true});

  factory _$VehiclePriceImpl.fromJson(Map<String, dynamic> json) =>
      _$$VehiclePriceImplFromJson(json);

  @override
  final String id;
  @override
  final String label;
  @override
  @JsonKey(name: 'desc')
  final String description;
  @override
  @JsonKey()
  final double capacityM3;
  @override
  @JsonKey(name: 'price')
  final int onceOffZar;
  @override
  @JsonKey()
  final bool recommended;

  /// Material Symbols name the website's calculator shows.
  @override
  @JsonKey()
  final String icon;
  @override
  @JsonKey()
  final bool active;

  @override
  String toString() {
    return 'VehiclePrice(id: $id, label: $label, description: $description, capacityM3: $capacityM3, onceOffZar: $onceOffZar, recommended: $recommended, icon: $icon, active: $active)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VehiclePriceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.capacityM3, capacityM3) ||
                other.capacityM3 == capacityM3) &&
            (identical(other.onceOffZar, onceOffZar) ||
                other.onceOffZar == onceOffZar) &&
            (identical(other.recommended, recommended) ||
                other.recommended == recommended) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.active, active) || other.active == active));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, label, description,
      capacityM3, onceOffZar, recommended, icon, active);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$VehiclePriceImplCopyWith<_$VehiclePriceImpl> get copyWith =>
      __$$VehiclePriceImplCopyWithImpl<_$VehiclePriceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VehiclePriceImplToJson(
      this,
    );
  }
}

abstract class _VehiclePrice implements VehiclePrice {
  const factory _VehiclePrice(
      {required final String id,
      required final String label,
      @JsonKey(name: 'desc') final String description,
      final double capacityM3,
      @JsonKey(name: 'price') required final int onceOffZar,
      final bool recommended,
      final String icon,
      final bool active}) = _$VehiclePriceImpl;

  factory _VehiclePrice.fromJson(Map<String, dynamic> json) =
      _$VehiclePriceImpl.fromJson;

  @override
  String get id;
  @override
  String get label;
  @override
  @JsonKey(name: 'desc')
  String get description;
  @override
  double get capacityM3;
  @override
  @JsonKey(name: 'price')
  int get onceOffZar;
  @override
  bool get recommended;
  @override

  /// Material Symbols name the website's calculator shows.
  String get icon;
  @override
  bool get active;
  @override
  @JsonKey(ignore: true)
  _$$VehiclePriceImplCopyWith<_$VehiclePriceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PriceCatalog _$PriceCatalogFromJson(Map<String, dynamic> json) {
  return _PriceCatalog.fromJson(json);
}

/// @nodoc
mixin _$PriceCatalog {
  List<BoxPrice> get boxes => throw _privateConstructorUsedError;
  List<String> get looseItemCategories => throw _privateConstructorUsedError;
  List<LooseItemPrice> get looseItems => throw _privateConstructorUsedError;
  List<String> get itemIcons => throw _privateConstructorUsedError;
  List<VehiclePrice> get vehicles => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  String? get updatedBy => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PriceCatalogCopyWith<PriceCatalog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PriceCatalogCopyWith<$Res> {
  factory $PriceCatalogCopyWith(
          PriceCatalog value, $Res Function(PriceCatalog) then) =
      _$PriceCatalogCopyWithImpl<$Res, PriceCatalog>;
  @useResult
  $Res call(
      {List<BoxPrice> boxes,
      List<String> looseItemCategories,
      List<LooseItemPrice> looseItems,
      List<String> itemIcons,
      List<VehiclePrice> vehicles,
      @NullableTimestampConverter() DateTime? updatedAt,
      String? updatedBy});
}

/// @nodoc
class _$PriceCatalogCopyWithImpl<$Res, $Val extends PriceCatalog>
    implements $PriceCatalogCopyWith<$Res> {
  _$PriceCatalogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? boxes = null,
    Object? looseItemCategories = null,
    Object? looseItems = null,
    Object? itemIcons = null,
    Object? vehicles = null,
    Object? updatedAt = freezed,
    Object? updatedBy = freezed,
  }) {
    return _then(_value.copyWith(
      boxes: null == boxes
          ? _value.boxes
          : boxes // ignore: cast_nullable_to_non_nullable
              as List<BoxPrice>,
      looseItemCategories: null == looseItemCategories
          ? _value.looseItemCategories
          : looseItemCategories // ignore: cast_nullable_to_non_nullable
              as List<String>,
      looseItems: null == looseItems
          ? _value.looseItems
          : looseItems // ignore: cast_nullable_to_non_nullable
              as List<LooseItemPrice>,
      itemIcons: null == itemIcons
          ? _value.itemIcons
          : itemIcons // ignore: cast_nullable_to_non_nullable
              as List<String>,
      vehicles: null == vehicles
          ? _value.vehicles
          : vehicles // ignore: cast_nullable_to_non_nullable
              as List<VehiclePrice>,
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
}

/// @nodoc
abstract class _$$PriceCatalogImplCopyWith<$Res>
    implements $PriceCatalogCopyWith<$Res> {
  factory _$$PriceCatalogImplCopyWith(
          _$PriceCatalogImpl value, $Res Function(_$PriceCatalogImpl) then) =
      __$$PriceCatalogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<BoxPrice> boxes,
      List<String> looseItemCategories,
      List<LooseItemPrice> looseItems,
      List<String> itemIcons,
      List<VehiclePrice> vehicles,
      @NullableTimestampConverter() DateTime? updatedAt,
      String? updatedBy});
}

/// @nodoc
class __$$PriceCatalogImplCopyWithImpl<$Res>
    extends _$PriceCatalogCopyWithImpl<$Res, _$PriceCatalogImpl>
    implements _$$PriceCatalogImplCopyWith<$Res> {
  __$$PriceCatalogImplCopyWithImpl(
      _$PriceCatalogImpl _value, $Res Function(_$PriceCatalogImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? boxes = null,
    Object? looseItemCategories = null,
    Object? looseItems = null,
    Object? itemIcons = null,
    Object? vehicles = null,
    Object? updatedAt = freezed,
    Object? updatedBy = freezed,
  }) {
    return _then(_$PriceCatalogImpl(
      boxes: null == boxes
          ? _value._boxes
          : boxes // ignore: cast_nullable_to_non_nullable
              as List<BoxPrice>,
      looseItemCategories: null == looseItemCategories
          ? _value._looseItemCategories
          : looseItemCategories // ignore: cast_nullable_to_non_nullable
              as List<String>,
      looseItems: null == looseItems
          ? _value._looseItems
          : looseItems // ignore: cast_nullable_to_non_nullable
              as List<LooseItemPrice>,
      itemIcons: null == itemIcons
          ? _value._itemIcons
          : itemIcons // ignore: cast_nullable_to_non_nullable
              as List<String>,
      vehicles: null == vehicles
          ? _value._vehicles
          : vehicles // ignore: cast_nullable_to_non_nullable
              as List<VehiclePrice>,
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
class _$PriceCatalogImpl extends _PriceCatalog {
  const _$PriceCatalogImpl(
      {final List<BoxPrice> boxes = const [],
      final List<String> looseItemCategories = const [],
      final List<LooseItemPrice> looseItems = const [],
      final List<String> itemIcons = const [],
      final List<VehiclePrice> vehicles = const [],
      @NullableTimestampConverter() this.updatedAt,
      this.updatedBy})
      : _boxes = boxes,
        _looseItemCategories = looseItemCategories,
        _looseItems = looseItems,
        _itemIcons = itemIcons,
        _vehicles = vehicles,
        super._();

  factory _$PriceCatalogImpl.fromJson(Map<String, dynamic> json) =>
      _$$PriceCatalogImplFromJson(json);

  final List<BoxPrice> _boxes;
  @override
  @JsonKey()
  List<BoxPrice> get boxes {
    if (_boxes is EqualUnmodifiableListView) return _boxes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_boxes);
  }

  final List<String> _looseItemCategories;
  @override
  @JsonKey()
  List<String> get looseItemCategories {
    if (_looseItemCategories is EqualUnmodifiableListView)
      return _looseItemCategories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_looseItemCategories);
  }

  final List<LooseItemPrice> _looseItems;
  @override
  @JsonKey()
  List<LooseItemPrice> get looseItems {
    if (_looseItems is EqualUnmodifiableListView) return _looseItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_looseItems);
  }

  final List<String> _itemIcons;
  @override
  @JsonKey()
  List<String> get itemIcons {
    if (_itemIcons is EqualUnmodifiableListView) return _itemIcons;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_itemIcons);
  }

  final List<VehiclePrice> _vehicles;
  @override
  @JsonKey()
  List<VehiclePrice> get vehicles {
    if (_vehicles is EqualUnmodifiableListView) return _vehicles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_vehicles);
  }

  @override
  @NullableTimestampConverter()
  final DateTime? updatedAt;
  @override
  final String? updatedBy;

  @override
  String toString() {
    return 'PriceCatalog(boxes: $boxes, looseItemCategories: $looseItemCategories, looseItems: $looseItems, itemIcons: $itemIcons, vehicles: $vehicles, updatedAt: $updatedAt, updatedBy: $updatedBy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PriceCatalogImpl &&
            const DeepCollectionEquality().equals(other._boxes, _boxes) &&
            const DeepCollectionEquality()
                .equals(other._looseItemCategories, _looseItemCategories) &&
            const DeepCollectionEquality()
                .equals(other._looseItems, _looseItems) &&
            const DeepCollectionEquality()
                .equals(other._itemIcons, _itemIcons) &&
            const DeepCollectionEquality().equals(other._vehicles, _vehicles) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.updatedBy, updatedBy) ||
                other.updatedBy == updatedBy));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_boxes),
      const DeepCollectionEquality().hash(_looseItemCategories),
      const DeepCollectionEquality().hash(_looseItems),
      const DeepCollectionEquality().hash(_itemIcons),
      const DeepCollectionEquality().hash(_vehicles),
      updatedAt,
      updatedBy);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PriceCatalogImplCopyWith<_$PriceCatalogImpl> get copyWith =>
      __$$PriceCatalogImplCopyWithImpl<_$PriceCatalogImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PriceCatalogImplToJson(
      this,
    );
  }
}

abstract class _PriceCatalog extends PriceCatalog {
  const factory _PriceCatalog(
      {final List<BoxPrice> boxes,
      final List<String> looseItemCategories,
      final List<LooseItemPrice> looseItems,
      final List<String> itemIcons,
      final List<VehiclePrice> vehicles,
      @NullableTimestampConverter() final DateTime? updatedAt,
      final String? updatedBy}) = _$PriceCatalogImpl;
  const _PriceCatalog._() : super._();

  factory _PriceCatalog.fromJson(Map<String, dynamic> json) =
      _$PriceCatalogImpl.fromJson;

  @override
  List<BoxPrice> get boxes;
  @override
  List<String> get looseItemCategories;
  @override
  List<LooseItemPrice> get looseItems;
  @override
  List<String> get itemIcons;
  @override
  List<VehiclePrice> get vehicles;
  @override
  @NullableTimestampConverter()
  DateTime? get updatedAt;
  @override
  String? get updatedBy;
  @override
  @JsonKey(ignore: true)
  _$$PriceCatalogImplCopyWith<_$PriceCatalogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
