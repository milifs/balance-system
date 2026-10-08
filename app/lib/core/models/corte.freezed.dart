// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'corte.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Corte {

 String get id; String get categoriaId; String get nombre;/// Kilos que rinde el corte al despiezar la pieza base. Alimenta el cuadro
/// de rinde de Lista de Precios; no tiene relación con los kilos pesados
/// en cada período.
 double get kgrRinde; bool get activo; int get orden;
/// Create a copy of Corte
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CorteCopyWith<Corte> get copyWith => _$CorteCopyWithImpl<Corte>(this as Corte, _$identity);

  /// Serializes this Corte to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Corte&&(identical(other.id, id) || other.id == id)&&(identical(other.categoriaId, categoriaId) || other.categoriaId == categoriaId)&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.kgrRinde, kgrRinde) || other.kgrRinde == kgrRinde)&&(identical(other.activo, activo) || other.activo == activo)&&(identical(other.orden, orden) || other.orden == orden));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,categoriaId,nombre,kgrRinde,activo,orden);

@override
String toString() {
  return 'Corte(id: $id, categoriaId: $categoriaId, nombre: $nombre, kgrRinde: $kgrRinde, activo: $activo, orden: $orden)';
}


}

/// @nodoc
abstract mixin class $CorteCopyWith<$Res>  {
  factory $CorteCopyWith(Corte value, $Res Function(Corte) _then) = _$CorteCopyWithImpl;
@useResult
$Res call({
 String id, String categoriaId, String nombre, double kgrRinde, bool activo, int orden
});




}
/// @nodoc
class _$CorteCopyWithImpl<$Res>
    implements $CorteCopyWith<$Res> {
  _$CorteCopyWithImpl(this._self, this._then);

  final Corte _self;
  final $Res Function(Corte) _then;

/// Create a copy of Corte
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? categoriaId = null,Object? nombre = null,Object? kgrRinde = null,Object? activo = null,Object? orden = null,}) {
  return _then(Corte(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,categoriaId: null == categoriaId ? _self.categoriaId : categoriaId // ignore: cast_nullable_to_non_nullable
as String,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,kgrRinde: null == kgrRinde ? _self.kgrRinde : kgrRinde // ignore: cast_nullable_to_non_nullable
as double,activo: null == activo ? _self.activo : activo // ignore: cast_nullable_to_non_nullable
as bool,orden: null == orden ? _self.orden : orden // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Corte].
extension CortePatterns on Corte {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Corte value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Corte() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Corte value)  $default,){
final _that = this;
switch (_that) {
case _Corte():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Corte value)?  $default,){
final _that = this;
switch (_that) {
case _Corte() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String categoriaId,  String nombre,  double kgrRinde,  bool activo,  int orden)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Corte() when $default != null:
return $default(_that.id,_that.categoriaId,_that.nombre,_that.kgrRinde,_that.activo,_that.orden);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String categoriaId,  String nombre,  double kgrRinde,  bool activo,  int orden)  $default,) {final _that = this;
switch (_that) {
case _Corte():
return $default(_that.id,_that.categoriaId,_that.nombre,_that.kgrRinde,_that.activo,_that.orden);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String categoriaId,  String nombre,  double kgrRinde,  bool activo,  int orden)?  $default,) {final _that = this;
switch (_that) {
case _Corte() when $default != null:
return $default(_that.id,_that.categoriaId,_that.nombre,_that.kgrRinde,_that.activo,_that.orden);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Corte implements Corte {
  const _Corte({required this.id, required this.categoriaId, required this.nombre, this.kgrRinde = 0, this.activo = true, this.orden = 0});
  factory _Corte.fromJson(Map<String, dynamic> json) => _$CorteFromJson(json);

@override final  String id;
@override final  String categoriaId;
@override final  String nombre;
/// Kilos que rinde el corte al despiezar la pieza base. Alimenta el cuadro
/// de rinde de Lista de Precios; no tiene relación con los kilos pesados
/// en cada período.
@override@JsonKey() final  double kgrRinde;
@override@JsonKey() final  bool activo;
@override@JsonKey() final  int orden;

/// Create a copy of Corte
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CorteCopyWith<_Corte> get copyWith => __$CorteCopyWithImpl<_Corte>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CorteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Corte&&(identical(other.id, id) || other.id == id)&&(identical(other.categoriaId, categoriaId) || other.categoriaId == categoriaId)&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.kgrRinde, kgrRinde) || other.kgrRinde == kgrRinde)&&(identical(other.activo, activo) || other.activo == activo)&&(identical(other.orden, orden) || other.orden == orden));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,categoriaId,nombre,kgrRinde,activo,orden);

@override
String toString() {
  return 'Corte(id: $id, categoriaId: $categoriaId, nombre: $nombre, kgrRinde: $kgrRinde, activo: $activo, orden: $orden)';
}


}

/// @nodoc
abstract mixin class _$CorteCopyWith<$Res> implements $CorteCopyWith<$Res> {
  factory _$CorteCopyWith(_Corte value, $Res Function(_Corte) _then) = __$CorteCopyWithImpl;
@override @useResult
$Res call({
 String id, String categoriaId, String nombre, double kgrRinde, bool activo, int orden
});




}
/// @nodoc
class __$CorteCopyWithImpl<$Res>
    implements _$CorteCopyWith<$Res> {
  __$CorteCopyWithImpl(this._self, this._then);

  final _Corte _self;
  final $Res Function(_Corte) _then;

/// Create a copy of Corte
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? categoriaId = null,Object? nombre = null,Object? kgrRinde = null,Object? activo = null,Object? orden = null,}) {
  return _then(_Corte(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,categoriaId: null == categoriaId ? _self.categoriaId : categoriaId // ignore: cast_nullable_to_non_nullable
as String,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,kgrRinde: null == kgrRinde ? _self.kgrRinde : kgrRinde // ignore: cast_nullable_to_non_nullable
as double,activo: null == activo ? _self.activo : activo // ignore: cast_nullable_to_non_nullable
as bool,orden: null == orden ? _self.orden : orden // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
