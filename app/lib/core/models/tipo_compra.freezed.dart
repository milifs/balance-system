// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tipo_compra.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TipoCompra {

 String get id; String get nombre; int get orden; bool get activo;
/// Create a copy of TipoCompra
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TipoCompraCopyWith<TipoCompra> get copyWith => _$TipoCompraCopyWithImpl<TipoCompra>(this as TipoCompra, _$identity);

  /// Serializes this TipoCompra to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TipoCompra&&(identical(other.id, id) || other.id == id)&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.orden, orden) || other.orden == orden)&&(identical(other.activo, activo) || other.activo == activo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nombre,orden,activo);

@override
String toString() {
  return 'TipoCompra(id: $id, nombre: $nombre, orden: $orden, activo: $activo)';
}


}

/// @nodoc
abstract mixin class $TipoCompraCopyWith<$Res>  {
  factory $TipoCompraCopyWith(TipoCompra value, $Res Function(TipoCompra) _then) = _$TipoCompraCopyWithImpl;
@useResult
$Res call({
 String id, String nombre, int orden, bool activo
});




}
/// @nodoc
class _$TipoCompraCopyWithImpl<$Res>
    implements $TipoCompraCopyWith<$Res> {
  _$TipoCompraCopyWithImpl(this._self, this._then);

  final TipoCompra _self;
  final $Res Function(TipoCompra) _then;

/// Create a copy of TipoCompra
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nombre = null,Object? orden = null,Object? activo = null,}) {
  return _then(TipoCompra(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,orden: null == orden ? _self.orden : orden // ignore: cast_nullable_to_non_nullable
as int,activo: null == activo ? _self.activo : activo // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TipoCompra].
extension TipoCompraPatterns on TipoCompra {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TipoCompra value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TipoCompra() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TipoCompra value)  $default,){
final _that = this;
switch (_that) {
case _TipoCompra():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TipoCompra value)?  $default,){
final _that = this;
switch (_that) {
case _TipoCompra() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String nombre,  int orden,  bool activo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TipoCompra() when $default != null:
return $default(_that.id,_that.nombre,_that.orden,_that.activo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String nombre,  int orden,  bool activo)  $default,) {final _that = this;
switch (_that) {
case _TipoCompra():
return $default(_that.id,_that.nombre,_that.orden,_that.activo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String nombre,  int orden,  bool activo)?  $default,) {final _that = this;
switch (_that) {
case _TipoCompra() when $default != null:
return $default(_that.id,_that.nombre,_that.orden,_that.activo);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TipoCompra implements TipoCompra {
  const _TipoCompra({required this.id, required this.nombre, this.orden = 0, this.activo = true});
  factory _TipoCompra.fromJson(Map<String, dynamic> json) => _$TipoCompraFromJson(json);

@override final  String id;
@override final  String nombre;
@override@JsonKey() final  int orden;
@override@JsonKey() final  bool activo;

/// Create a copy of TipoCompra
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TipoCompraCopyWith<_TipoCompra> get copyWith => __$TipoCompraCopyWithImpl<_TipoCompra>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TipoCompraToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TipoCompra&&(identical(other.id, id) || other.id == id)&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.orden, orden) || other.orden == orden)&&(identical(other.activo, activo) || other.activo == activo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nombre,orden,activo);

@override
String toString() {
  return 'TipoCompra(id: $id, nombre: $nombre, orden: $orden, activo: $activo)';
}


}

/// @nodoc
abstract mixin class _$TipoCompraCopyWith<$Res> implements $TipoCompraCopyWith<$Res> {
  factory _$TipoCompraCopyWith(_TipoCompra value, $Res Function(_TipoCompra) _then) = __$TipoCompraCopyWithImpl;
@override @useResult
$Res call({
 String id, String nombre, int orden, bool activo
});




}
/// @nodoc
class __$TipoCompraCopyWithImpl<$Res>
    implements _$TipoCompraCopyWith<$Res> {
  __$TipoCompraCopyWithImpl(this._self, this._then);

  final _TipoCompra _self;
  final $Res Function(_TipoCompra) _then;

/// Create a copy of TipoCompra
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nombre = null,Object? orden = null,Object? activo = null,}) {
  return _then(_TipoCompra(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,orden: null == orden ? _self.orden : orden // ignore: cast_nullable_to_non_nullable
as int,activo: null == activo ? _self.activo : activo // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
