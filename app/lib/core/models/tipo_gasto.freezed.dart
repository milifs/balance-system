// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tipo_gasto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TipoGasto {

 String get id; String get nombre; int get orden; bool get activo;
/// Create a copy of TipoGasto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TipoGastoCopyWith<TipoGasto> get copyWith => _$TipoGastoCopyWithImpl<TipoGasto>(this as TipoGasto, _$identity);

  /// Serializes this TipoGasto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TipoGasto&&(identical(other.id, id) || other.id == id)&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.orden, orden) || other.orden == orden)&&(identical(other.activo, activo) || other.activo == activo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nombre,orden,activo);

@override
String toString() {
  return 'TipoGasto(id: $id, nombre: $nombre, orden: $orden, activo: $activo)';
}


}

/// @nodoc
abstract mixin class $TipoGastoCopyWith<$Res>  {
  factory $TipoGastoCopyWith(TipoGasto value, $Res Function(TipoGasto) _then) = _$TipoGastoCopyWithImpl;
@useResult
$Res call({
 String id, String nombre, int orden, bool activo
});




}
/// @nodoc
class _$TipoGastoCopyWithImpl<$Res>
    implements $TipoGastoCopyWith<$Res> {
  _$TipoGastoCopyWithImpl(this._self, this._then);

  final TipoGasto _self;
  final $Res Function(TipoGasto) _then;

/// Create a copy of TipoGasto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nombre = null,Object? orden = null,Object? activo = null,}) {
  return _then(TipoGasto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,orden: null == orden ? _self.orden : orden // ignore: cast_nullable_to_non_nullable
as int,activo: null == activo ? _self.activo : activo // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TipoGasto].
extension TipoGastoPatterns on TipoGasto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TipoGasto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TipoGasto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TipoGasto value)  $default,){
final _that = this;
switch (_that) {
case _TipoGasto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TipoGasto value)?  $default,){
final _that = this;
switch (_that) {
case _TipoGasto() when $default != null:
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
case _TipoGasto() when $default != null:
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
case _TipoGasto():
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
case _TipoGasto() when $default != null:
return $default(_that.id,_that.nombre,_that.orden,_that.activo);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TipoGasto implements TipoGasto {
  const _TipoGasto({required this.id, required this.nombre, this.orden = 0, this.activo = true});
  factory _TipoGasto.fromJson(Map<String, dynamic> json) => _$TipoGastoFromJson(json);

@override final  String id;
@override final  String nombre;
@override@JsonKey() final  int orden;
@override@JsonKey() final  bool activo;

/// Create a copy of TipoGasto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TipoGastoCopyWith<_TipoGasto> get copyWith => __$TipoGastoCopyWithImpl<_TipoGasto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TipoGastoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TipoGasto&&(identical(other.id, id) || other.id == id)&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.orden, orden) || other.orden == orden)&&(identical(other.activo, activo) || other.activo == activo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nombre,orden,activo);

@override
String toString() {
  return 'TipoGasto(id: $id, nombre: $nombre, orden: $orden, activo: $activo)';
}


}

/// @nodoc
abstract mixin class _$TipoGastoCopyWith<$Res> implements $TipoGastoCopyWith<$Res> {
  factory _$TipoGastoCopyWith(_TipoGasto value, $Res Function(_TipoGasto) _then) = __$TipoGastoCopyWithImpl;
@override @useResult
$Res call({
 String id, String nombre, int orden, bool activo
});




}
/// @nodoc
class __$TipoGastoCopyWithImpl<$Res>
    implements _$TipoGastoCopyWith<$Res> {
  __$TipoGastoCopyWithImpl(this._self, this._then);

  final _TipoGasto _self;
  final $Res Function(_TipoGasto) _then;

/// Create a copy of TipoGasto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nombre = null,Object? orden = null,Object? activo = null,}) {
  return _then(_TipoGasto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,orden: null == orden ? _self.orden : orden // ignore: cast_nullable_to_non_nullable
as int,activo: null == activo ? _self.activo : activo // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
