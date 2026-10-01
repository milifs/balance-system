// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pesaje.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Pesaje {

 String get id; String get corteId; String get sucursalId; String? get periodoId; DateTime get fecha; MomentoPesaje? get momento; double? get precioSnapshot; DateTime? get creadoAt;
/// Create a copy of Pesaje
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PesajeCopyWith<Pesaje> get copyWith => _$PesajeCopyWithImpl<Pesaje>(this as Pesaje, _$identity);

  /// Serializes this Pesaje to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Pesaje&&(identical(other.id, id) || other.id == id)&&(identical(other.corteId, corteId) || other.corteId == corteId)&&(identical(other.sucursalId, sucursalId) || other.sucursalId == sucursalId)&&(identical(other.periodoId, periodoId) || other.periodoId == periodoId)&&(identical(other.fecha, fecha) || other.fecha == fecha)&&(identical(other.momento, momento) || other.momento == momento)&&(identical(other.precioSnapshot, precioSnapshot) || other.precioSnapshot == precioSnapshot)&&(identical(other.creadoAt, creadoAt) || other.creadoAt == creadoAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,corteId,sucursalId,periodoId,fecha,momento,precioSnapshot,creadoAt);

@override
String toString() {
  return 'Pesaje(id: $id, corteId: $corteId, sucursalId: $sucursalId, periodoId: $periodoId, fecha: $fecha, momento: $momento, precioSnapshot: $precioSnapshot, creadoAt: $creadoAt)';
}


}

/// @nodoc
abstract mixin class $PesajeCopyWith<$Res>  {
  factory $PesajeCopyWith(Pesaje value, $Res Function(Pesaje) _then) = _$PesajeCopyWithImpl;
@useResult
$Res call({
 String id, String corteId, String sucursalId, String? periodoId, DateTime fecha, MomentoPesaje? momento, double? precioSnapshot, DateTime? creadoAt
});




}
/// @nodoc
class _$PesajeCopyWithImpl<$Res>
    implements $PesajeCopyWith<$Res> {
  _$PesajeCopyWithImpl(this._self, this._then);

  final Pesaje _self;
  final $Res Function(Pesaje) _then;

/// Create a copy of Pesaje
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? corteId = null,Object? sucursalId = null,Object? periodoId = freezed,Object? fecha = null,Object? momento = freezed,Object? precioSnapshot = freezed,Object? creadoAt = freezed,}) {
  return _then(Pesaje(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,corteId: null == corteId ? _self.corteId : corteId // ignore: cast_nullable_to_non_nullable
as String,sucursalId: null == sucursalId ? _self.sucursalId : sucursalId // ignore: cast_nullable_to_non_nullable
as String,periodoId: freezed == periodoId ? _self.periodoId : periodoId // ignore: cast_nullable_to_non_nullable
as String?,fecha: null == fecha ? _self.fecha : fecha // ignore: cast_nullable_to_non_nullable
as DateTime,momento: freezed == momento ? _self.momento : momento // ignore: cast_nullable_to_non_nullable
as MomentoPesaje?,precioSnapshot: freezed == precioSnapshot ? _self.precioSnapshot : precioSnapshot // ignore: cast_nullable_to_non_nullable
as double?,creadoAt: freezed == creadoAt ? _self.creadoAt : creadoAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Pesaje].
extension PesajePatterns on Pesaje {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Pesaje value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Pesaje() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Pesaje value)  $default,){
final _that = this;
switch (_that) {
case _Pesaje():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Pesaje value)?  $default,){
final _that = this;
switch (_that) {
case _Pesaje() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String corteId,  String sucursalId,  String? periodoId,  DateTime fecha,  MomentoPesaje? momento,  double? precioSnapshot,  DateTime? creadoAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Pesaje() when $default != null:
return $default(_that.id,_that.corteId,_that.sucursalId,_that.periodoId,_that.fecha,_that.momento,_that.precioSnapshot,_that.creadoAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String corteId,  String sucursalId,  String? periodoId,  DateTime fecha,  MomentoPesaje? momento,  double? precioSnapshot,  DateTime? creadoAt)  $default,) {final _that = this;
switch (_that) {
case _Pesaje():
return $default(_that.id,_that.corteId,_that.sucursalId,_that.periodoId,_that.fecha,_that.momento,_that.precioSnapshot,_that.creadoAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String corteId,  String sucursalId,  String? periodoId,  DateTime fecha,  MomentoPesaje? momento,  double? precioSnapshot,  DateTime? creadoAt)?  $default,) {final _that = this;
switch (_that) {
case _Pesaje() when $default != null:
return $default(_that.id,_that.corteId,_that.sucursalId,_that.periodoId,_that.fecha,_that.momento,_that.precioSnapshot,_that.creadoAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Pesaje implements Pesaje {
  const _Pesaje({required this.id, required this.corteId, required this.sucursalId, this.periodoId, required this.fecha, this.momento, this.precioSnapshot, this.creadoAt});
  factory _Pesaje.fromJson(Map<String, dynamic> json) => _$PesajeFromJson(json);

@override final  String id;
@override final  String corteId;
@override final  String sucursalId;
@override final  String? periodoId;
@override final  DateTime fecha;
@override final  MomentoPesaje? momento;
@override final  double? precioSnapshot;
@override final  DateTime? creadoAt;

/// Create a copy of Pesaje
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PesajeCopyWith<_Pesaje> get copyWith => __$PesajeCopyWithImpl<_Pesaje>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PesajeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Pesaje&&(identical(other.id, id) || other.id == id)&&(identical(other.corteId, corteId) || other.corteId == corteId)&&(identical(other.sucursalId, sucursalId) || other.sucursalId == sucursalId)&&(identical(other.periodoId, periodoId) || other.periodoId == periodoId)&&(identical(other.fecha, fecha) || other.fecha == fecha)&&(identical(other.momento, momento) || other.momento == momento)&&(identical(other.precioSnapshot, precioSnapshot) || other.precioSnapshot == precioSnapshot)&&(identical(other.creadoAt, creadoAt) || other.creadoAt == creadoAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,corteId,sucursalId,periodoId,fecha,momento,precioSnapshot,creadoAt);

@override
String toString() {
  return 'Pesaje(id: $id, corteId: $corteId, sucursalId: $sucursalId, periodoId: $periodoId, fecha: $fecha, momento: $momento, precioSnapshot: $precioSnapshot, creadoAt: $creadoAt)';
}


}

/// @nodoc
abstract mixin class _$PesajeCopyWith<$Res> implements $PesajeCopyWith<$Res> {
  factory _$PesajeCopyWith(_Pesaje value, $Res Function(_Pesaje) _then) = __$PesajeCopyWithImpl;
@override @useResult
$Res call({
 String id, String corteId, String sucursalId, String? periodoId, DateTime fecha, MomentoPesaje? momento, double? precioSnapshot, DateTime? creadoAt
});




}
/// @nodoc
class __$PesajeCopyWithImpl<$Res>
    implements _$PesajeCopyWith<$Res> {
  __$PesajeCopyWithImpl(this._self, this._then);

  final _Pesaje _self;
  final $Res Function(_Pesaje) _then;

/// Create a copy of Pesaje
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? corteId = null,Object? sucursalId = null,Object? periodoId = freezed,Object? fecha = null,Object? momento = freezed,Object? precioSnapshot = freezed,Object? creadoAt = freezed,}) {
  return _then(_Pesaje(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,corteId: null == corteId ? _self.corteId : corteId // ignore: cast_nullable_to_non_nullable
as String,sucursalId: null == sucursalId ? _self.sucursalId : sucursalId // ignore: cast_nullable_to_non_nullable
as String,periodoId: freezed == periodoId ? _self.periodoId : periodoId // ignore: cast_nullable_to_non_nullable
as String?,fecha: null == fecha ? _self.fecha : fecha // ignore: cast_nullable_to_non_nullable
as DateTime,momento: freezed == momento ? _self.momento : momento // ignore: cast_nullable_to_non_nullable
as MomentoPesaje?,precioSnapshot: freezed == precioSnapshot ? _self.precioSnapshot : precioSnapshot // ignore: cast_nullable_to_non_nullable
as double?,creadoAt: freezed == creadoAt ? _self.creadoAt : creadoAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
