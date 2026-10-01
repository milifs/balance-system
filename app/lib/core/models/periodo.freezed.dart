// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'periodo.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Periodo {

 String get id; String get sucursalId; DateTime get fechaInicio; DateTime get fechaFin; EstadoPeriodo get estado; double? get stockInicialManual; DateTime? get creadoAt;
/// Create a copy of Periodo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PeriodoCopyWith<Periodo> get copyWith => _$PeriodoCopyWithImpl<Periodo>(this as Periodo, _$identity);

  /// Serializes this Periodo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Periodo&&(identical(other.id, id) || other.id == id)&&(identical(other.sucursalId, sucursalId) || other.sucursalId == sucursalId)&&(identical(other.fechaInicio, fechaInicio) || other.fechaInicio == fechaInicio)&&(identical(other.fechaFin, fechaFin) || other.fechaFin == fechaFin)&&(identical(other.estado, estado) || other.estado == estado)&&(identical(other.stockInicialManual, stockInicialManual) || other.stockInicialManual == stockInicialManual)&&(identical(other.creadoAt, creadoAt) || other.creadoAt == creadoAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sucursalId,fechaInicio,fechaFin,estado,stockInicialManual,creadoAt);

@override
String toString() {
  return 'Periodo(id: $id, sucursalId: $sucursalId, fechaInicio: $fechaInicio, fechaFin: $fechaFin, estado: $estado, stockInicialManual: $stockInicialManual, creadoAt: $creadoAt)';
}


}

/// @nodoc
abstract mixin class $PeriodoCopyWith<$Res>  {
  factory $PeriodoCopyWith(Periodo value, $Res Function(Periodo) _then) = _$PeriodoCopyWithImpl;
@useResult
$Res call({
 String id, String sucursalId, DateTime fechaInicio, DateTime fechaFin, EstadoPeriodo estado, double? stockInicialManual, DateTime? creadoAt
});




}
/// @nodoc
class _$PeriodoCopyWithImpl<$Res>
    implements $PeriodoCopyWith<$Res> {
  _$PeriodoCopyWithImpl(this._self, this._then);

  final Periodo _self;
  final $Res Function(Periodo) _then;

/// Create a copy of Periodo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sucursalId = null,Object? fechaInicio = null,Object? fechaFin = null,Object? estado = null,Object? stockInicialManual = freezed,Object? creadoAt = freezed,}) {
  return _then(Periodo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sucursalId: null == sucursalId ? _self.sucursalId : sucursalId // ignore: cast_nullable_to_non_nullable
as String,fechaInicio: null == fechaInicio ? _self.fechaInicio : fechaInicio // ignore: cast_nullable_to_non_nullable
as DateTime,fechaFin: null == fechaFin ? _self.fechaFin : fechaFin // ignore: cast_nullable_to_non_nullable
as DateTime,estado: null == estado ? _self.estado : estado // ignore: cast_nullable_to_non_nullable
as EstadoPeriodo,stockInicialManual: freezed == stockInicialManual ? _self.stockInicialManual : stockInicialManual // ignore: cast_nullable_to_non_nullable
as double?,creadoAt: freezed == creadoAt ? _self.creadoAt : creadoAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Periodo].
extension PeriodoPatterns on Periodo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Periodo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Periodo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Periodo value)  $default,){
final _that = this;
switch (_that) {
case _Periodo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Periodo value)?  $default,){
final _that = this;
switch (_that) {
case _Periodo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String sucursalId,  DateTime fechaInicio,  DateTime fechaFin,  EstadoPeriodo estado,  double? stockInicialManual,  DateTime? creadoAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Periodo() when $default != null:
return $default(_that.id,_that.sucursalId,_that.fechaInicio,_that.fechaFin,_that.estado,_that.stockInicialManual,_that.creadoAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String sucursalId,  DateTime fechaInicio,  DateTime fechaFin,  EstadoPeriodo estado,  double? stockInicialManual,  DateTime? creadoAt)  $default,) {final _that = this;
switch (_that) {
case _Periodo():
return $default(_that.id,_that.sucursalId,_that.fechaInicio,_that.fechaFin,_that.estado,_that.stockInicialManual,_that.creadoAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String sucursalId,  DateTime fechaInicio,  DateTime fechaFin,  EstadoPeriodo estado,  double? stockInicialManual,  DateTime? creadoAt)?  $default,) {final _that = this;
switch (_that) {
case _Periodo() when $default != null:
return $default(_that.id,_that.sucursalId,_that.fechaInicio,_that.fechaFin,_that.estado,_that.stockInicialManual,_that.creadoAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Periodo implements Periodo {
  const _Periodo({required this.id, required this.sucursalId, required this.fechaInicio, required this.fechaFin, this.estado = EstadoPeriodo.abierto, this.stockInicialManual, this.creadoAt});
  factory _Periodo.fromJson(Map<String, dynamic> json) => _$PeriodoFromJson(json);

@override final  String id;
@override final  String sucursalId;
@override final  DateTime fechaInicio;
@override final  DateTime fechaFin;
@override@JsonKey() final  EstadoPeriodo estado;
@override final  double? stockInicialManual;
@override final  DateTime? creadoAt;

/// Create a copy of Periodo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PeriodoCopyWith<_Periodo> get copyWith => __$PeriodoCopyWithImpl<_Periodo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PeriodoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Periodo&&(identical(other.id, id) || other.id == id)&&(identical(other.sucursalId, sucursalId) || other.sucursalId == sucursalId)&&(identical(other.fechaInicio, fechaInicio) || other.fechaInicio == fechaInicio)&&(identical(other.fechaFin, fechaFin) || other.fechaFin == fechaFin)&&(identical(other.estado, estado) || other.estado == estado)&&(identical(other.stockInicialManual, stockInicialManual) || other.stockInicialManual == stockInicialManual)&&(identical(other.creadoAt, creadoAt) || other.creadoAt == creadoAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sucursalId,fechaInicio,fechaFin,estado,stockInicialManual,creadoAt);

@override
String toString() {
  return 'Periodo(id: $id, sucursalId: $sucursalId, fechaInicio: $fechaInicio, fechaFin: $fechaFin, estado: $estado, stockInicialManual: $stockInicialManual, creadoAt: $creadoAt)';
}


}

/// @nodoc
abstract mixin class _$PeriodoCopyWith<$Res> implements $PeriodoCopyWith<$Res> {
  factory _$PeriodoCopyWith(_Periodo value, $Res Function(_Periodo) _then) = __$PeriodoCopyWithImpl;
@override @useResult
$Res call({
 String id, String sucursalId, DateTime fechaInicio, DateTime fechaFin, EstadoPeriodo estado, double? stockInicialManual, DateTime? creadoAt
});




}
/// @nodoc
class __$PeriodoCopyWithImpl<$Res>
    implements _$PeriodoCopyWith<$Res> {
  __$PeriodoCopyWithImpl(this._self, this._then);

  final _Periodo _self;
  final $Res Function(_Periodo) _then;

/// Create a copy of Periodo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sucursalId = null,Object? fechaInicio = null,Object? fechaFin = null,Object? estado = null,Object? stockInicialManual = freezed,Object? creadoAt = freezed,}) {
  return _then(_Periodo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sucursalId: null == sucursalId ? _self.sucursalId : sucursalId // ignore: cast_nullable_to_non_nullable
as String,fechaInicio: null == fechaInicio ? _self.fechaInicio : fechaInicio // ignore: cast_nullable_to_non_nullable
as DateTime,fechaFin: null == fechaFin ? _self.fechaFin : fechaFin // ignore: cast_nullable_to_non_nullable
as DateTime,estado: null == estado ? _self.estado : estado // ignore: cast_nullable_to_non_nullable
as EstadoPeriodo,stockInicialManual: freezed == stockInicialManual ? _self.stockInicialManual : stockInicialManual // ignore: cast_nullable_to_non_nullable
as double?,creadoAt: freezed == creadoAt ? _self.creadoAt : creadoAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
