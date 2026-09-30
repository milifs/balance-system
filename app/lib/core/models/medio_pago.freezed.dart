// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'medio_pago.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MedioPago {

 String get id; String get nombre; double get retencionPct; int get orden; bool get activo;
/// Create a copy of MedioPago
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MedioPagoCopyWith<MedioPago> get copyWith => _$MedioPagoCopyWithImpl<MedioPago>(this as MedioPago, _$identity);

  /// Serializes this MedioPago to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MedioPago&&(identical(other.id, id) || other.id == id)&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.retencionPct, retencionPct) || other.retencionPct == retencionPct)&&(identical(other.orden, orden) || other.orden == orden)&&(identical(other.activo, activo) || other.activo == activo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nombre,retencionPct,orden,activo);

@override
String toString() {
  return 'MedioPago(id: $id, nombre: $nombre, retencionPct: $retencionPct, orden: $orden, activo: $activo)';
}


}

/// @nodoc
abstract mixin class $MedioPagoCopyWith<$Res>  {
  factory $MedioPagoCopyWith(MedioPago value, $Res Function(MedioPago) _then) = _$MedioPagoCopyWithImpl;
@useResult
$Res call({
 String id, String nombre, double retencionPct, int orden, bool activo
});




}
/// @nodoc
class _$MedioPagoCopyWithImpl<$Res>
    implements $MedioPagoCopyWith<$Res> {
  _$MedioPagoCopyWithImpl(this._self, this._then);

  final MedioPago _self;
  final $Res Function(MedioPago) _then;

/// Create a copy of MedioPago
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nombre = null,Object? retencionPct = null,Object? orden = null,Object? activo = null,}) {
  return _then(MedioPago(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,retencionPct: null == retencionPct ? _self.retencionPct : retencionPct // ignore: cast_nullable_to_non_nullable
as double,orden: null == orden ? _self.orden : orden // ignore: cast_nullable_to_non_nullable
as int,activo: null == activo ? _self.activo : activo // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MedioPago].
extension MedioPagoPatterns on MedioPago {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MedioPago value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MedioPago() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MedioPago value)  $default,){
final _that = this;
switch (_that) {
case _MedioPago():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MedioPago value)?  $default,){
final _that = this;
switch (_that) {
case _MedioPago() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String nombre,  double retencionPct,  int orden,  bool activo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MedioPago() when $default != null:
return $default(_that.id,_that.nombre,_that.retencionPct,_that.orden,_that.activo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String nombre,  double retencionPct,  int orden,  bool activo)  $default,) {final _that = this;
switch (_that) {
case _MedioPago():
return $default(_that.id,_that.nombre,_that.retencionPct,_that.orden,_that.activo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String nombre,  double retencionPct,  int orden,  bool activo)?  $default,) {final _that = this;
switch (_that) {
case _MedioPago() when $default != null:
return $default(_that.id,_that.nombre,_that.retencionPct,_that.orden,_that.activo);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MedioPago implements MedioPago {
  const _MedioPago({required this.id, required this.nombre, this.retencionPct = 0, this.orden = 0, this.activo = true});
  factory _MedioPago.fromJson(Map<String, dynamic> json) => _$MedioPagoFromJson(json);

@override final  String id;
@override final  String nombre;
@override@JsonKey() final  double retencionPct;
@override@JsonKey() final  int orden;
@override@JsonKey() final  bool activo;

/// Create a copy of MedioPago
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MedioPagoCopyWith<_MedioPago> get copyWith => __$MedioPagoCopyWithImpl<_MedioPago>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MedioPagoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MedioPago&&(identical(other.id, id) || other.id == id)&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.retencionPct, retencionPct) || other.retencionPct == retencionPct)&&(identical(other.orden, orden) || other.orden == orden)&&(identical(other.activo, activo) || other.activo == activo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nombre,retencionPct,orden,activo);

@override
String toString() {
  return 'MedioPago(id: $id, nombre: $nombre, retencionPct: $retencionPct, orden: $orden, activo: $activo)';
}


}

/// @nodoc
abstract mixin class _$MedioPagoCopyWith<$Res> implements $MedioPagoCopyWith<$Res> {
  factory _$MedioPagoCopyWith(_MedioPago value, $Res Function(_MedioPago) _then) = __$MedioPagoCopyWithImpl;
@override @useResult
$Res call({
 String id, String nombre, double retencionPct, int orden, bool activo
});




}
/// @nodoc
class __$MedioPagoCopyWithImpl<$Res>
    implements _$MedioPagoCopyWith<$Res> {
  __$MedioPagoCopyWithImpl(this._self, this._then);

  final _MedioPago _self;
  final $Res Function(_MedioPago) _then;

/// Create a copy of MedioPago
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nombre = null,Object? retencionPct = null,Object? orden = null,Object? activo = null,}) {
  return _then(_MedioPago(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,retencionPct: null == retencionPct ? _self.retencionPct : retencionPct // ignore: cast_nullable_to_non_nullable
as double,orden: null == orden ? _self.orden : orden // ignore: cast_nullable_to_non_nullable
as int,activo: null == activo ? _self.activo : activo // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
