// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'balance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BalancePeriodo {

 double get ventasBruto; double get ventasNeto; double get comprasTotal; double get stockInicial; double get stockFinal; double get cmv; double get gastosTotal; double get ganancia; double get utilidadNetaPct;
/// Create a copy of BalancePeriodo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BalancePeriodoCopyWith<BalancePeriodo> get copyWith => _$BalancePeriodoCopyWithImpl<BalancePeriodo>(this as BalancePeriodo, _$identity);

  /// Serializes this BalancePeriodo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BalancePeriodo&&(identical(other.ventasBruto, ventasBruto) || other.ventasBruto == ventasBruto)&&(identical(other.ventasNeto, ventasNeto) || other.ventasNeto == ventasNeto)&&(identical(other.comprasTotal, comprasTotal) || other.comprasTotal == comprasTotal)&&(identical(other.stockInicial, stockInicial) || other.stockInicial == stockInicial)&&(identical(other.stockFinal, stockFinal) || other.stockFinal == stockFinal)&&(identical(other.cmv, cmv) || other.cmv == cmv)&&(identical(other.gastosTotal, gastosTotal) || other.gastosTotal == gastosTotal)&&(identical(other.ganancia, ganancia) || other.ganancia == ganancia)&&(identical(other.utilidadNetaPct, utilidadNetaPct) || other.utilidadNetaPct == utilidadNetaPct));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ventasBruto,ventasNeto,comprasTotal,stockInicial,stockFinal,cmv,gastosTotal,ganancia,utilidadNetaPct);

@override
String toString() {
  return 'BalancePeriodo(ventasBruto: $ventasBruto, ventasNeto: $ventasNeto, comprasTotal: $comprasTotal, stockInicial: $stockInicial, stockFinal: $stockFinal, cmv: $cmv, gastosTotal: $gastosTotal, ganancia: $ganancia, utilidadNetaPct: $utilidadNetaPct)';
}


}

/// @nodoc
abstract mixin class $BalancePeriodoCopyWith<$Res>  {
  factory $BalancePeriodoCopyWith(BalancePeriodo value, $Res Function(BalancePeriodo) _then) = _$BalancePeriodoCopyWithImpl;
@useResult
$Res call({
 double ventasBruto, double ventasNeto, double comprasTotal, double stockInicial, double stockFinal, double cmv, double gastosTotal, double ganancia, double utilidadNetaPct
});




}
/// @nodoc
class _$BalancePeriodoCopyWithImpl<$Res>
    implements $BalancePeriodoCopyWith<$Res> {
  _$BalancePeriodoCopyWithImpl(this._self, this._then);

  final BalancePeriodo _self;
  final $Res Function(BalancePeriodo) _then;

/// Create a copy of BalancePeriodo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ventasBruto = null,Object? ventasNeto = null,Object? comprasTotal = null,Object? stockInicial = null,Object? stockFinal = null,Object? cmv = null,Object? gastosTotal = null,Object? ganancia = null,Object? utilidadNetaPct = null,}) {
  return _then(BalancePeriodo(
ventasBruto: null == ventasBruto ? _self.ventasBruto : ventasBruto // ignore: cast_nullable_to_non_nullable
as double,ventasNeto: null == ventasNeto ? _self.ventasNeto : ventasNeto // ignore: cast_nullable_to_non_nullable
as double,comprasTotal: null == comprasTotal ? _self.comprasTotal : comprasTotal // ignore: cast_nullable_to_non_nullable
as double,stockInicial: null == stockInicial ? _self.stockInicial : stockInicial // ignore: cast_nullable_to_non_nullable
as double,stockFinal: null == stockFinal ? _self.stockFinal : stockFinal // ignore: cast_nullable_to_non_nullable
as double,cmv: null == cmv ? _self.cmv : cmv // ignore: cast_nullable_to_non_nullable
as double,gastosTotal: null == gastosTotal ? _self.gastosTotal : gastosTotal // ignore: cast_nullable_to_non_nullable
as double,ganancia: null == ganancia ? _self.ganancia : ganancia // ignore: cast_nullable_to_non_nullable
as double,utilidadNetaPct: null == utilidadNetaPct ? _self.utilidadNetaPct : utilidadNetaPct // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [BalancePeriodo].
extension BalancePeriodoPatterns on BalancePeriodo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BalancePeriodo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BalancePeriodo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BalancePeriodo value)  $default,){
final _that = this;
switch (_that) {
case _BalancePeriodo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BalancePeriodo value)?  $default,){
final _that = this;
switch (_that) {
case _BalancePeriodo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double ventasBruto,  double ventasNeto,  double comprasTotal,  double stockInicial,  double stockFinal,  double cmv,  double gastosTotal,  double ganancia,  double utilidadNetaPct)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BalancePeriodo() when $default != null:
return $default(_that.ventasBruto,_that.ventasNeto,_that.comprasTotal,_that.stockInicial,_that.stockFinal,_that.cmv,_that.gastosTotal,_that.ganancia,_that.utilidadNetaPct);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double ventasBruto,  double ventasNeto,  double comprasTotal,  double stockInicial,  double stockFinal,  double cmv,  double gastosTotal,  double ganancia,  double utilidadNetaPct)  $default,) {final _that = this;
switch (_that) {
case _BalancePeriodo():
return $default(_that.ventasBruto,_that.ventasNeto,_that.comprasTotal,_that.stockInicial,_that.stockFinal,_that.cmv,_that.gastosTotal,_that.ganancia,_that.utilidadNetaPct);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double ventasBruto,  double ventasNeto,  double comprasTotal,  double stockInicial,  double stockFinal,  double cmv,  double gastosTotal,  double ganancia,  double utilidadNetaPct)?  $default,) {final _that = this;
switch (_that) {
case _BalancePeriodo() when $default != null:
return $default(_that.ventasBruto,_that.ventasNeto,_that.comprasTotal,_that.stockInicial,_that.stockFinal,_that.cmv,_that.gastosTotal,_that.ganancia,_that.utilidadNetaPct);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BalancePeriodo implements BalancePeriodo {
  const _BalancePeriodo({this.ventasBruto = 0, this.ventasNeto = 0, this.comprasTotal = 0, this.stockInicial = 0, this.stockFinal = 0, this.cmv = 0, this.gastosTotal = 0, this.ganancia = 0, this.utilidadNetaPct = 0});
  factory _BalancePeriodo.fromJson(Map<String, dynamic> json) => _$BalancePeriodoFromJson(json);

@override@JsonKey() final  double ventasBruto;
@override@JsonKey() final  double ventasNeto;
@override@JsonKey() final  double comprasTotal;
@override@JsonKey() final  double stockInicial;
@override@JsonKey() final  double stockFinal;
@override@JsonKey() final  double cmv;
@override@JsonKey() final  double gastosTotal;
@override@JsonKey() final  double ganancia;
@override@JsonKey() final  double utilidadNetaPct;

/// Create a copy of BalancePeriodo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BalancePeriodoCopyWith<_BalancePeriodo> get copyWith => __$BalancePeriodoCopyWithImpl<_BalancePeriodo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BalancePeriodoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BalancePeriodo&&(identical(other.ventasBruto, ventasBruto) || other.ventasBruto == ventasBruto)&&(identical(other.ventasNeto, ventasNeto) || other.ventasNeto == ventasNeto)&&(identical(other.comprasTotal, comprasTotal) || other.comprasTotal == comprasTotal)&&(identical(other.stockInicial, stockInicial) || other.stockInicial == stockInicial)&&(identical(other.stockFinal, stockFinal) || other.stockFinal == stockFinal)&&(identical(other.cmv, cmv) || other.cmv == cmv)&&(identical(other.gastosTotal, gastosTotal) || other.gastosTotal == gastosTotal)&&(identical(other.ganancia, ganancia) || other.ganancia == ganancia)&&(identical(other.utilidadNetaPct, utilidadNetaPct) || other.utilidadNetaPct == utilidadNetaPct));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ventasBruto,ventasNeto,comprasTotal,stockInicial,stockFinal,cmv,gastosTotal,ganancia,utilidadNetaPct);

@override
String toString() {
  return 'BalancePeriodo(ventasBruto: $ventasBruto, ventasNeto: $ventasNeto, comprasTotal: $comprasTotal, stockInicial: $stockInicial, stockFinal: $stockFinal, cmv: $cmv, gastosTotal: $gastosTotal, ganancia: $ganancia, utilidadNetaPct: $utilidadNetaPct)';
}


}

/// @nodoc
abstract mixin class _$BalancePeriodoCopyWith<$Res> implements $BalancePeriodoCopyWith<$Res> {
  factory _$BalancePeriodoCopyWith(_BalancePeriodo value, $Res Function(_BalancePeriodo) _then) = __$BalancePeriodoCopyWithImpl;
@override @useResult
$Res call({
 double ventasBruto, double ventasNeto, double comprasTotal, double stockInicial, double stockFinal, double cmv, double gastosTotal, double ganancia, double utilidadNetaPct
});




}
/// @nodoc
class __$BalancePeriodoCopyWithImpl<$Res>
    implements _$BalancePeriodoCopyWith<$Res> {
  __$BalancePeriodoCopyWithImpl(this._self, this._then);

  final _BalancePeriodo _self;
  final $Res Function(_BalancePeriodo) _then;

/// Create a copy of BalancePeriodo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ventasBruto = null,Object? ventasNeto = null,Object? comprasTotal = null,Object? stockInicial = null,Object? stockFinal = null,Object? cmv = null,Object? gastosTotal = null,Object? ganancia = null,Object? utilidadNetaPct = null,}) {
  return _then(_BalancePeriodo(
ventasBruto: null == ventasBruto ? _self.ventasBruto : ventasBruto // ignore: cast_nullable_to_non_nullable
as double,ventasNeto: null == ventasNeto ? _self.ventasNeto : ventasNeto // ignore: cast_nullable_to_non_nullable
as double,comprasTotal: null == comprasTotal ? _self.comprasTotal : comprasTotal // ignore: cast_nullable_to_non_nullable
as double,stockInicial: null == stockInicial ? _self.stockInicial : stockInicial // ignore: cast_nullable_to_non_nullable
as double,stockFinal: null == stockFinal ? _self.stockFinal : stockFinal // ignore: cast_nullable_to_non_nullable
as double,cmv: null == cmv ? _self.cmv : cmv // ignore: cast_nullable_to_non_nullable
as double,gastosTotal: null == gastosTotal ? _self.gastosTotal : gastosTotal // ignore: cast_nullable_to_non_nullable
as double,ganancia: null == ganancia ? _self.ganancia : ganancia // ignore: cast_nullable_to_non_nullable
as double,utilidadNetaPct: null == utilidadNetaPct ? _self.utilidadNetaPct : utilidadNetaPct // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$Consolidado {

 double get ventasBruto; double get ventasNeto; double get comprasTotal; double get cmv; double get gastosTotal; double get ganancia;
/// Create a copy of Consolidado
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConsolidadoCopyWith<Consolidado> get copyWith => _$ConsolidadoCopyWithImpl<Consolidado>(this as Consolidado, _$identity);

  /// Serializes this Consolidado to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Consolidado&&(identical(other.ventasBruto, ventasBruto) || other.ventasBruto == ventasBruto)&&(identical(other.ventasNeto, ventasNeto) || other.ventasNeto == ventasNeto)&&(identical(other.comprasTotal, comprasTotal) || other.comprasTotal == comprasTotal)&&(identical(other.cmv, cmv) || other.cmv == cmv)&&(identical(other.gastosTotal, gastosTotal) || other.gastosTotal == gastosTotal)&&(identical(other.ganancia, ganancia) || other.ganancia == ganancia));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ventasBruto,ventasNeto,comprasTotal,cmv,gastosTotal,ganancia);

@override
String toString() {
  return 'Consolidado(ventasBruto: $ventasBruto, ventasNeto: $ventasNeto, comprasTotal: $comprasTotal, cmv: $cmv, gastosTotal: $gastosTotal, ganancia: $ganancia)';
}


}

/// @nodoc
abstract mixin class $ConsolidadoCopyWith<$Res>  {
  factory $ConsolidadoCopyWith(Consolidado value, $Res Function(Consolidado) _then) = _$ConsolidadoCopyWithImpl;
@useResult
$Res call({
 double ventasBruto, double ventasNeto, double comprasTotal, double cmv, double gastosTotal, double ganancia
});




}
/// @nodoc
class _$ConsolidadoCopyWithImpl<$Res>
    implements $ConsolidadoCopyWith<$Res> {
  _$ConsolidadoCopyWithImpl(this._self, this._then);

  final Consolidado _self;
  final $Res Function(Consolidado) _then;

/// Create a copy of Consolidado
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ventasBruto = null,Object? ventasNeto = null,Object? comprasTotal = null,Object? cmv = null,Object? gastosTotal = null,Object? ganancia = null,}) {
  return _then(Consolidado(
ventasBruto: null == ventasBruto ? _self.ventasBruto : ventasBruto // ignore: cast_nullable_to_non_nullable
as double,ventasNeto: null == ventasNeto ? _self.ventasNeto : ventasNeto // ignore: cast_nullable_to_non_nullable
as double,comprasTotal: null == comprasTotal ? _self.comprasTotal : comprasTotal // ignore: cast_nullable_to_non_nullable
as double,cmv: null == cmv ? _self.cmv : cmv // ignore: cast_nullable_to_non_nullable
as double,gastosTotal: null == gastosTotal ? _self.gastosTotal : gastosTotal // ignore: cast_nullable_to_non_nullable
as double,ganancia: null == ganancia ? _self.ganancia : ganancia // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [Consolidado].
extension ConsolidadoPatterns on Consolidado {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Consolidado value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Consolidado() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Consolidado value)  $default,){
final _that = this;
switch (_that) {
case _Consolidado():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Consolidado value)?  $default,){
final _that = this;
switch (_that) {
case _Consolidado() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double ventasBruto,  double ventasNeto,  double comprasTotal,  double cmv,  double gastosTotal,  double ganancia)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Consolidado() when $default != null:
return $default(_that.ventasBruto,_that.ventasNeto,_that.comprasTotal,_that.cmv,_that.gastosTotal,_that.ganancia);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double ventasBruto,  double ventasNeto,  double comprasTotal,  double cmv,  double gastosTotal,  double ganancia)  $default,) {final _that = this;
switch (_that) {
case _Consolidado():
return $default(_that.ventasBruto,_that.ventasNeto,_that.comprasTotal,_that.cmv,_that.gastosTotal,_that.ganancia);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double ventasBruto,  double ventasNeto,  double comprasTotal,  double cmv,  double gastosTotal,  double ganancia)?  $default,) {final _that = this;
switch (_that) {
case _Consolidado() when $default != null:
return $default(_that.ventasBruto,_that.ventasNeto,_that.comprasTotal,_that.cmv,_that.gastosTotal,_that.ganancia);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Consolidado implements Consolidado {
  const _Consolidado({this.ventasBruto = 0, this.ventasNeto = 0, this.comprasTotal = 0, this.cmv = 0, this.gastosTotal = 0, this.ganancia = 0});
  factory _Consolidado.fromJson(Map<String, dynamic> json) => _$ConsolidadoFromJson(json);

@override@JsonKey() final  double ventasBruto;
@override@JsonKey() final  double ventasNeto;
@override@JsonKey() final  double comprasTotal;
@override@JsonKey() final  double cmv;
@override@JsonKey() final  double gastosTotal;
@override@JsonKey() final  double ganancia;

/// Create a copy of Consolidado
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConsolidadoCopyWith<_Consolidado> get copyWith => __$ConsolidadoCopyWithImpl<_Consolidado>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConsolidadoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Consolidado&&(identical(other.ventasBruto, ventasBruto) || other.ventasBruto == ventasBruto)&&(identical(other.ventasNeto, ventasNeto) || other.ventasNeto == ventasNeto)&&(identical(other.comprasTotal, comprasTotal) || other.comprasTotal == comprasTotal)&&(identical(other.cmv, cmv) || other.cmv == cmv)&&(identical(other.gastosTotal, gastosTotal) || other.gastosTotal == gastosTotal)&&(identical(other.ganancia, ganancia) || other.ganancia == ganancia));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ventasBruto,ventasNeto,comprasTotal,cmv,gastosTotal,ganancia);

@override
String toString() {
  return 'Consolidado(ventasBruto: $ventasBruto, ventasNeto: $ventasNeto, comprasTotal: $comprasTotal, cmv: $cmv, gastosTotal: $gastosTotal, ganancia: $ganancia)';
}


}

/// @nodoc
abstract mixin class _$ConsolidadoCopyWith<$Res> implements $ConsolidadoCopyWith<$Res> {
  factory _$ConsolidadoCopyWith(_Consolidado value, $Res Function(_Consolidado) _then) = __$ConsolidadoCopyWithImpl;
@override @useResult
$Res call({
 double ventasBruto, double ventasNeto, double comprasTotal, double cmv, double gastosTotal, double ganancia
});




}
/// @nodoc
class __$ConsolidadoCopyWithImpl<$Res>
    implements _$ConsolidadoCopyWith<$Res> {
  __$ConsolidadoCopyWithImpl(this._self, this._then);

  final _Consolidado _self;
  final $Res Function(_Consolidado) _then;

/// Create a copy of Consolidado
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ventasBruto = null,Object? ventasNeto = null,Object? comprasTotal = null,Object? cmv = null,Object? gastosTotal = null,Object? ganancia = null,}) {
  return _then(_Consolidado(
ventasBruto: null == ventasBruto ? _self.ventasBruto : ventasBruto // ignore: cast_nullable_to_non_nullable
as double,ventasNeto: null == ventasNeto ? _self.ventasNeto : ventasNeto // ignore: cast_nullable_to_non_nullable
as double,comprasTotal: null == comprasTotal ? _self.comprasTotal : comprasTotal // ignore: cast_nullable_to_non_nullable
as double,cmv: null == cmv ? _self.cmv : cmv // ignore: cast_nullable_to_non_nullable
as double,gastosTotal: null == gastosTotal ? _self.gastosTotal : gastosTotal // ignore: cast_nullable_to_non_nullable
as double,ganancia: null == ganancia ? _self.ganancia : ganancia // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
