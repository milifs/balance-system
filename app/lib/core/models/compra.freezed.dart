// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'compra.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Compra {

 String get id; String get periodoId; String get sucursalId; DateTime get fecha; TipoCompra get tipoCompra; double get monto; String? get proveedor; DateTime? get creadoAt;
/// Create a copy of Compra
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompraCopyWith<Compra> get copyWith => _$CompraCopyWithImpl<Compra>(this as Compra, _$identity);

  /// Serializes this Compra to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Compra&&(identical(other.id, id) || other.id == id)&&(identical(other.periodoId, periodoId) || other.periodoId == periodoId)&&(identical(other.sucursalId, sucursalId) || other.sucursalId == sucursalId)&&(identical(other.fecha, fecha) || other.fecha == fecha)&&(identical(other.tipoCompra, tipoCompra) || other.tipoCompra == tipoCompra)&&(identical(other.monto, monto) || other.monto == monto)&&(identical(other.proveedor, proveedor) || other.proveedor == proveedor)&&(identical(other.creadoAt, creadoAt) || other.creadoAt == creadoAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,periodoId,sucursalId,fecha,tipoCompra,monto,proveedor,creadoAt);

@override
String toString() {
  return 'Compra(id: $id, periodoId: $periodoId, sucursalId: $sucursalId, fecha: $fecha, tipoCompra: $tipoCompra, monto: $monto, proveedor: $proveedor, creadoAt: $creadoAt)';
}


}

/// @nodoc
abstract mixin class $CompraCopyWith<$Res>  {
  factory $CompraCopyWith(Compra value, $Res Function(Compra) _then) = _$CompraCopyWithImpl;
@useResult
$Res call({
 String id, String periodoId, String sucursalId, DateTime fecha, TipoCompra tipoCompra, double monto, String? proveedor, DateTime? creadoAt
});




}
/// @nodoc
class _$CompraCopyWithImpl<$Res>
    implements $CompraCopyWith<$Res> {
  _$CompraCopyWithImpl(this._self, this._then);

  final Compra _self;
  final $Res Function(Compra) _then;

/// Create a copy of Compra
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? periodoId = null,Object? sucursalId = null,Object? fecha = null,Object? tipoCompra = null,Object? monto = null,Object? proveedor = freezed,Object? creadoAt = freezed,}) {
  return _then(Compra(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,periodoId: null == periodoId ? _self.periodoId : periodoId // ignore: cast_nullable_to_non_nullable
as String,sucursalId: null == sucursalId ? _self.sucursalId : sucursalId // ignore: cast_nullable_to_non_nullable
as String,fecha: null == fecha ? _self.fecha : fecha // ignore: cast_nullable_to_non_nullable
as DateTime,tipoCompra: null == tipoCompra ? _self.tipoCompra : tipoCompra // ignore: cast_nullable_to_non_nullable
as TipoCompra,monto: null == monto ? _self.monto : monto // ignore: cast_nullable_to_non_nullable
as double,proveedor: freezed == proveedor ? _self.proveedor : proveedor // ignore: cast_nullable_to_non_nullable
as String?,creadoAt: freezed == creadoAt ? _self.creadoAt : creadoAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Compra].
extension CompraPatterns on Compra {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Compra value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Compra() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Compra value)  $default,){
final _that = this;
switch (_that) {
case _Compra():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Compra value)?  $default,){
final _that = this;
switch (_that) {
case _Compra() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String periodoId,  String sucursalId,  DateTime fecha,  TipoCompra tipoCompra,  double monto,  String? proveedor,  DateTime? creadoAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Compra() when $default != null:
return $default(_that.id,_that.periodoId,_that.sucursalId,_that.fecha,_that.tipoCompra,_that.monto,_that.proveedor,_that.creadoAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String periodoId,  String sucursalId,  DateTime fecha,  TipoCompra tipoCompra,  double monto,  String? proveedor,  DateTime? creadoAt)  $default,) {final _that = this;
switch (_that) {
case _Compra():
return $default(_that.id,_that.periodoId,_that.sucursalId,_that.fecha,_that.tipoCompra,_that.monto,_that.proveedor,_that.creadoAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String periodoId,  String sucursalId,  DateTime fecha,  TipoCompra tipoCompra,  double monto,  String? proveedor,  DateTime? creadoAt)?  $default,) {final _that = this;
switch (_that) {
case _Compra() when $default != null:
return $default(_that.id,_that.periodoId,_that.sucursalId,_that.fecha,_that.tipoCompra,_that.monto,_that.proveedor,_that.creadoAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Compra implements Compra {
  const _Compra({required this.id, required this.periodoId, required this.sucursalId, required this.fecha, required this.tipoCompra, this.monto = 0, this.proveedor, this.creadoAt});
  factory _Compra.fromJson(Map<String, dynamic> json) => _$CompraFromJson(json);

@override final  String id;
@override final  String periodoId;
@override final  String sucursalId;
@override final  DateTime fecha;
@override final  TipoCompra tipoCompra;
@override@JsonKey() final  double monto;
@override final  String? proveedor;
@override final  DateTime? creadoAt;

/// Create a copy of Compra
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompraCopyWith<_Compra> get copyWith => __$CompraCopyWithImpl<_Compra>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CompraToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Compra&&(identical(other.id, id) || other.id == id)&&(identical(other.periodoId, periodoId) || other.periodoId == periodoId)&&(identical(other.sucursalId, sucursalId) || other.sucursalId == sucursalId)&&(identical(other.fecha, fecha) || other.fecha == fecha)&&(identical(other.tipoCompra, tipoCompra) || other.tipoCompra == tipoCompra)&&(identical(other.monto, monto) || other.monto == monto)&&(identical(other.proveedor, proveedor) || other.proveedor == proveedor)&&(identical(other.creadoAt, creadoAt) || other.creadoAt == creadoAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,periodoId,sucursalId,fecha,tipoCompra,monto,proveedor,creadoAt);

@override
String toString() {
  return 'Compra(id: $id, periodoId: $periodoId, sucursalId: $sucursalId, fecha: $fecha, tipoCompra: $tipoCompra, monto: $monto, proveedor: $proveedor, creadoAt: $creadoAt)';
}


}

/// @nodoc
abstract mixin class _$CompraCopyWith<$Res> implements $CompraCopyWith<$Res> {
  factory _$CompraCopyWith(_Compra value, $Res Function(_Compra) _then) = __$CompraCopyWithImpl;
@override @useResult
$Res call({
 String id, String periodoId, String sucursalId, DateTime fecha, TipoCompra tipoCompra, double monto, String? proveedor, DateTime? creadoAt
});




}
/// @nodoc
class __$CompraCopyWithImpl<$Res>
    implements _$CompraCopyWith<$Res> {
  __$CompraCopyWithImpl(this._self, this._then);

  final _Compra _self;
  final $Res Function(_Compra) _then;

/// Create a copy of Compra
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? periodoId = null,Object? sucursalId = null,Object? fecha = null,Object? tipoCompra = null,Object? monto = null,Object? proveedor = freezed,Object? creadoAt = freezed,}) {
  return _then(_Compra(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,periodoId: null == periodoId ? _self.periodoId : periodoId // ignore: cast_nullable_to_non_nullable
as String,sucursalId: null == sucursalId ? _self.sucursalId : sucursalId // ignore: cast_nullable_to_non_nullable
as String,fecha: null == fecha ? _self.fecha : fecha // ignore: cast_nullable_to_non_nullable
as DateTime,tipoCompra: null == tipoCompra ? _self.tipoCompra : tipoCompra // ignore: cast_nullable_to_non_nullable
as TipoCompra,monto: null == monto ? _self.monto : monto // ignore: cast_nullable_to_non_nullable
as double,proveedor: freezed == proveedor ? _self.proveedor : proveedor // ignore: cast_nullable_to_non_nullable
as String?,creadoAt: freezed == creadoAt ? _self.creadoAt : creadoAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
