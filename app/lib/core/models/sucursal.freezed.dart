// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sucursal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Sucursal {

 String get id; String get nombre; int get orden; bool get activo;
/// Create a copy of Sucursal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SucursalCopyWith<Sucursal> get copyWith => _$SucursalCopyWithImpl<Sucursal>(this as Sucursal, _$identity);

  /// Serializes this Sucursal to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Sucursal&&(identical(other.id, id) || other.id == id)&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.orden, orden) || other.orden == orden)&&(identical(other.activo, activo) || other.activo == activo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nombre,orden,activo);

@override
String toString() {
  return 'Sucursal(id: $id, nombre: $nombre, orden: $orden, activo: $activo)';
}


}

/// @nodoc
abstract mixin class $SucursalCopyWith<$Res>  {
  factory $SucursalCopyWith(Sucursal value, $Res Function(Sucursal) _then) = _$SucursalCopyWithImpl;
@useResult
$Res call({
 String id, String nombre, int orden, bool activo
});




}
/// @nodoc
class _$SucursalCopyWithImpl<$Res>
    implements $SucursalCopyWith<$Res> {
  _$SucursalCopyWithImpl(this._self, this._then);

  final Sucursal _self;
  final $Res Function(Sucursal) _then;

/// Create a copy of Sucursal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nombre = null,Object? orden = null,Object? activo = null,}) {
  return _then(Sucursal(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,orden: null == orden ? _self.orden : orden // ignore: cast_nullable_to_non_nullable
as int,activo: null == activo ? _self.activo : activo // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Sucursal].
extension SucursalPatterns on Sucursal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Sucursal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Sucursal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Sucursal value)  $default,){
final _that = this;
switch (_that) {
case _Sucursal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Sucursal value)?  $default,){
final _that = this;
switch (_that) {
case _Sucursal() when $default != null:
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
case _Sucursal() when $default != null:
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
case _Sucursal():
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
case _Sucursal() when $default != null:
return $default(_that.id,_that.nombre,_that.orden,_that.activo);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Sucursal implements Sucursal {
  const _Sucursal({required this.id, required this.nombre, required this.orden, this.activo = true});
  factory _Sucursal.fromJson(Map<String, dynamic> json) => _$SucursalFromJson(json);

@override final  String id;
@override final  String nombre;
@override final  int orden;
@override@JsonKey() final  bool activo;

/// Create a copy of Sucursal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SucursalCopyWith<_Sucursal> get copyWith => __$SucursalCopyWithImpl<_Sucursal>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SucursalToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Sucursal&&(identical(other.id, id) || other.id == id)&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.orden, orden) || other.orden == orden)&&(identical(other.activo, activo) || other.activo == activo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nombre,orden,activo);

@override
String toString() {
  return 'Sucursal(id: $id, nombre: $nombre, orden: $orden, activo: $activo)';
}


}

/// @nodoc
abstract mixin class _$SucursalCopyWith<$Res> implements $SucursalCopyWith<$Res> {
  factory _$SucursalCopyWith(_Sucursal value, $Res Function(_Sucursal) _then) = __$SucursalCopyWithImpl;
@override @useResult
$Res call({
 String id, String nombre, int orden, bool activo
});




}
/// @nodoc
class __$SucursalCopyWithImpl<$Res>
    implements _$SucursalCopyWith<$Res> {
  __$SucursalCopyWithImpl(this._self, this._then);

  final _Sucursal _self;
  final $Res Function(_Sucursal) _then;

/// Create a copy of Sucursal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nombre = null,Object? orden = null,Object? activo = null,}) {
  return _then(_Sucursal(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,orden: null == orden ? _self.orden : orden // ignore: cast_nullable_to_non_nullable
as int,activo: null == activo ? _self.activo : activo // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
