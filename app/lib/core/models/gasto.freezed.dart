// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gasto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Gasto {

 String get id; String get periodoId; String get sucursalId; DateTime get fecha; String get tipoGastoId; double get monto; DateTime? get creadoAt;
/// Create a copy of Gasto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GastoCopyWith<Gasto> get copyWith => _$GastoCopyWithImpl<Gasto>(this as Gasto, _$identity);

  /// Serializes this Gasto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Gasto&&(identical(other.id, id) || other.id == id)&&(identical(other.periodoId, periodoId) || other.periodoId == periodoId)&&(identical(other.sucursalId, sucursalId) || other.sucursalId == sucursalId)&&(identical(other.fecha, fecha) || other.fecha == fecha)&&(identical(other.tipoGastoId, tipoGastoId) || other.tipoGastoId == tipoGastoId)&&(identical(other.monto, monto) || other.monto == monto)&&(identical(other.creadoAt, creadoAt) || other.creadoAt == creadoAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,periodoId,sucursalId,fecha,tipoGastoId,monto,creadoAt);

@override
String toString() {
  return 'Gasto(id: $id, periodoId: $periodoId, sucursalId: $sucursalId, fecha: $fecha, tipoGastoId: $tipoGastoId, monto: $monto, creadoAt: $creadoAt)';
}


}

/// @nodoc
abstract mixin class $GastoCopyWith<$Res>  {
  factory $GastoCopyWith(Gasto value, $Res Function(Gasto) _then) = _$GastoCopyWithImpl;
@useResult
$Res call({
 String id, String periodoId, String sucursalId, DateTime fecha, String tipoGastoId, double monto, DateTime? creadoAt
});




}
/// @nodoc
class _$GastoCopyWithImpl<$Res>
    implements $GastoCopyWith<$Res> {
  _$GastoCopyWithImpl(this._self, this._then);

  final Gasto _self;
  final $Res Function(Gasto) _then;

/// Create a copy of Gasto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? periodoId = null,Object? sucursalId = null,Object? fecha = null,Object? tipoGastoId = null,Object? monto = null,Object? creadoAt = freezed,}) {
  return _then(Gasto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,periodoId: null == periodoId ? _self.periodoId : periodoId // ignore: cast_nullable_to_non_nullable
as String,sucursalId: null == sucursalId ? _self.sucursalId : sucursalId // ignore: cast_nullable_to_non_nullable
as String,fecha: null == fecha ? _self.fecha : fecha // ignore: cast_nullable_to_non_nullable
as DateTime,tipoGastoId: null == tipoGastoId ? _self.tipoGastoId : tipoGastoId // ignore: cast_nullable_to_non_nullable
as String,monto: null == monto ? _self.monto : monto // ignore: cast_nullable_to_non_nullable
as double,creadoAt: freezed == creadoAt ? _self.creadoAt : creadoAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Gasto].
extension GastoPatterns on Gasto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Gasto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Gasto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Gasto value)  $default,){
final _that = this;
switch (_that) {
case _Gasto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Gasto value)?  $default,){
final _that = this;
switch (_that) {
case _Gasto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String periodoId,  String sucursalId,  DateTime fecha,  String tipoGastoId,  double monto,  DateTime? creadoAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Gasto() when $default != null:
return $default(_that.id,_that.periodoId,_that.sucursalId,_that.fecha,_that.tipoGastoId,_that.monto,_that.creadoAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String periodoId,  String sucursalId,  DateTime fecha,  String tipoGastoId,  double monto,  DateTime? creadoAt)  $default,) {final _that = this;
switch (_that) {
case _Gasto():
return $default(_that.id,_that.periodoId,_that.sucursalId,_that.fecha,_that.tipoGastoId,_that.monto,_that.creadoAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String periodoId,  String sucursalId,  DateTime fecha,  String tipoGastoId,  double monto,  DateTime? creadoAt)?  $default,) {final _that = this;
switch (_that) {
case _Gasto() when $default != null:
return $default(_that.id,_that.periodoId,_that.sucursalId,_that.fecha,_that.tipoGastoId,_that.monto,_that.creadoAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Gasto implements Gasto {
  const _Gasto({required this.id, required this.periodoId, required this.sucursalId, required this.fecha, required this.tipoGastoId, this.monto = 0, this.creadoAt});
  factory _Gasto.fromJson(Map<String, dynamic> json) => _$GastoFromJson(json);

@override final  String id;
@override final  String periodoId;
@override final  String sucursalId;
@override final  DateTime fecha;
@override final  String tipoGastoId;
@override@JsonKey() final  double monto;
@override final  DateTime? creadoAt;

/// Create a copy of Gasto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GastoCopyWith<_Gasto> get copyWith => __$GastoCopyWithImpl<_Gasto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GastoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Gasto&&(identical(other.id, id) || other.id == id)&&(identical(other.periodoId, periodoId) || other.periodoId == periodoId)&&(identical(other.sucursalId, sucursalId) || other.sucursalId == sucursalId)&&(identical(other.fecha, fecha) || other.fecha == fecha)&&(identical(other.tipoGastoId, tipoGastoId) || other.tipoGastoId == tipoGastoId)&&(identical(other.monto, monto) || other.monto == monto)&&(identical(other.creadoAt, creadoAt) || other.creadoAt == creadoAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,periodoId,sucursalId,fecha,tipoGastoId,monto,creadoAt);

@override
String toString() {
  return 'Gasto(id: $id, periodoId: $periodoId, sucursalId: $sucursalId, fecha: $fecha, tipoGastoId: $tipoGastoId, monto: $monto, creadoAt: $creadoAt)';
}


}

/// @nodoc
abstract mixin class _$GastoCopyWith<$Res> implements $GastoCopyWith<$Res> {
  factory _$GastoCopyWith(_Gasto value, $Res Function(_Gasto) _then) = __$GastoCopyWithImpl;
@override @useResult
$Res call({
 String id, String periodoId, String sucursalId, DateTime fecha, String tipoGastoId, double monto, DateTime? creadoAt
});




}
/// @nodoc
class __$GastoCopyWithImpl<$Res>
    implements _$GastoCopyWith<$Res> {
  __$GastoCopyWithImpl(this._self, this._then);

  final _Gasto _self;
  final $Res Function(_Gasto) _then;

/// Create a copy of Gasto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? periodoId = null,Object? sucursalId = null,Object? fecha = null,Object? tipoGastoId = null,Object? monto = null,Object? creadoAt = freezed,}) {
  return _then(_Gasto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,periodoId: null == periodoId ? _self.periodoId : periodoId // ignore: cast_nullable_to_non_nullable
as String,sucursalId: null == sucursalId ? _self.sucursalId : sucursalId // ignore: cast_nullable_to_non_nullable
as String,fecha: null == fecha ? _self.fecha : fecha // ignore: cast_nullable_to_non_nullable
as DateTime,tipoGastoId: null == tipoGastoId ? _self.tipoGastoId : tipoGastoId // ignore: cast_nullable_to_non_nullable
as String,monto: null == monto ? _self.monto : monto // ignore: cast_nullable_to_non_nullable
as double,creadoAt: freezed == creadoAt ? _self.creadoAt : creadoAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
