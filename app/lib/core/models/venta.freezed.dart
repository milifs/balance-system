// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'venta.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Venta {

 String get id; String get periodoId; String get sucursalId; DateTime get fecha; String get medioPagoId; double get monto; DateTime? get creadoAt;
/// Create a copy of Venta
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VentaCopyWith<Venta> get copyWith => _$VentaCopyWithImpl<Venta>(this as Venta, _$identity);

  /// Serializes this Venta to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Venta&&(identical(other.id, id) || other.id == id)&&(identical(other.periodoId, periodoId) || other.periodoId == periodoId)&&(identical(other.sucursalId, sucursalId) || other.sucursalId == sucursalId)&&(identical(other.fecha, fecha) || other.fecha == fecha)&&(identical(other.medioPagoId, medioPagoId) || other.medioPagoId == medioPagoId)&&(identical(other.monto, monto) || other.monto == monto)&&(identical(other.creadoAt, creadoAt) || other.creadoAt == creadoAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,periodoId,sucursalId,fecha,medioPagoId,monto,creadoAt);

@override
String toString() {
  return 'Venta(id: $id, periodoId: $periodoId, sucursalId: $sucursalId, fecha: $fecha, medioPagoId: $medioPagoId, monto: $monto, creadoAt: $creadoAt)';
}


}

/// @nodoc
abstract mixin class $VentaCopyWith<$Res>  {
  factory $VentaCopyWith(Venta value, $Res Function(Venta) _then) = _$VentaCopyWithImpl;
@useResult
$Res call({
 String id, String periodoId, String sucursalId, DateTime fecha, String medioPagoId, double monto, DateTime? creadoAt
});




}
/// @nodoc
class _$VentaCopyWithImpl<$Res>
    implements $VentaCopyWith<$Res> {
  _$VentaCopyWithImpl(this._self, this._then);

  final Venta _self;
  final $Res Function(Venta) _then;

/// Create a copy of Venta
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? periodoId = null,Object? sucursalId = null,Object? fecha = null,Object? medioPagoId = null,Object? monto = null,Object? creadoAt = freezed,}) {
  return _then(Venta(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,periodoId: null == periodoId ? _self.periodoId : periodoId // ignore: cast_nullable_to_non_nullable
as String,sucursalId: null == sucursalId ? _self.sucursalId : sucursalId // ignore: cast_nullable_to_non_nullable
as String,fecha: null == fecha ? _self.fecha : fecha // ignore: cast_nullable_to_non_nullable
as DateTime,medioPagoId: null == medioPagoId ? _self.medioPagoId : medioPagoId // ignore: cast_nullable_to_non_nullable
as String,monto: null == monto ? _self.monto : monto // ignore: cast_nullable_to_non_nullable
as double,creadoAt: freezed == creadoAt ? _self.creadoAt : creadoAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Venta].
extension VentaPatterns on Venta {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Venta value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Venta() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Venta value)  $default,){
final _that = this;
switch (_that) {
case _Venta():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Venta value)?  $default,){
final _that = this;
switch (_that) {
case _Venta() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String periodoId,  String sucursalId,  DateTime fecha,  String medioPagoId,  double monto,  DateTime? creadoAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Venta() when $default != null:
return $default(_that.id,_that.periodoId,_that.sucursalId,_that.fecha,_that.medioPagoId,_that.monto,_that.creadoAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String periodoId,  String sucursalId,  DateTime fecha,  String medioPagoId,  double monto,  DateTime? creadoAt)  $default,) {final _that = this;
switch (_that) {
case _Venta():
return $default(_that.id,_that.periodoId,_that.sucursalId,_that.fecha,_that.medioPagoId,_that.monto,_that.creadoAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String periodoId,  String sucursalId,  DateTime fecha,  String medioPagoId,  double monto,  DateTime? creadoAt)?  $default,) {final _that = this;
switch (_that) {
case _Venta() when $default != null:
return $default(_that.id,_that.periodoId,_that.sucursalId,_that.fecha,_that.medioPagoId,_that.monto,_that.creadoAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Venta implements Venta {
  const _Venta({required this.id, required this.periodoId, required this.sucursalId, required this.fecha, required this.medioPagoId, this.monto = 0, this.creadoAt});
  factory _Venta.fromJson(Map<String, dynamic> json) => _$VentaFromJson(json);

@override final  String id;
@override final  String periodoId;
@override final  String sucursalId;
@override final  DateTime fecha;
@override final  String medioPagoId;
@override@JsonKey() final  double monto;
@override final  DateTime? creadoAt;

/// Create a copy of Venta
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VentaCopyWith<_Venta> get copyWith => __$VentaCopyWithImpl<_Venta>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VentaToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Venta&&(identical(other.id, id) || other.id == id)&&(identical(other.periodoId, periodoId) || other.periodoId == periodoId)&&(identical(other.sucursalId, sucursalId) || other.sucursalId == sucursalId)&&(identical(other.fecha, fecha) || other.fecha == fecha)&&(identical(other.medioPagoId, medioPagoId) || other.medioPagoId == medioPagoId)&&(identical(other.monto, monto) || other.monto == monto)&&(identical(other.creadoAt, creadoAt) || other.creadoAt == creadoAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,periodoId,sucursalId,fecha,medioPagoId,monto,creadoAt);

@override
String toString() {
  return 'Venta(id: $id, periodoId: $periodoId, sucursalId: $sucursalId, fecha: $fecha, medioPagoId: $medioPagoId, monto: $monto, creadoAt: $creadoAt)';
}


}

/// @nodoc
abstract mixin class _$VentaCopyWith<$Res> implements $VentaCopyWith<$Res> {
  factory _$VentaCopyWith(_Venta value, $Res Function(_Venta) _then) = __$VentaCopyWithImpl;
@override @useResult
$Res call({
 String id, String periodoId, String sucursalId, DateTime fecha, String medioPagoId, double monto, DateTime? creadoAt
});




}
/// @nodoc
class __$VentaCopyWithImpl<$Res>
    implements _$VentaCopyWith<$Res> {
  __$VentaCopyWithImpl(this._self, this._then);

  final _Venta _self;
  final $Res Function(_Venta) _then;

/// Create a copy of Venta
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? periodoId = null,Object? sucursalId = null,Object? fecha = null,Object? medioPagoId = null,Object? monto = null,Object? creadoAt = freezed,}) {
  return _then(_Venta(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,periodoId: null == periodoId ? _self.periodoId : periodoId // ignore: cast_nullable_to_non_nullable
as String,sucursalId: null == sucursalId ? _self.sucursalId : sucursalId // ignore: cast_nullable_to_non_nullable
as String,fecha: null == fecha ? _self.fecha : fecha // ignore: cast_nullable_to_non_nullable
as DateTime,medioPagoId: null == medioPagoId ? _self.medioPagoId : medioPagoId // ignore: cast_nullable_to_non_nullable
as String,monto: null == monto ? _self.monto : monto // ignore: cast_nullable_to_non_nullable
as double,creadoAt: freezed == creadoAt ? _self.creadoAt : creadoAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
