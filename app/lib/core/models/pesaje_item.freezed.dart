// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pesaje_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PesajeItem {

 String get id; String get pesajeId; double get kg; String? get origen; DateTime? get creadoAt;
/// Create a copy of PesajeItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PesajeItemCopyWith<PesajeItem> get copyWith => _$PesajeItemCopyWithImpl<PesajeItem>(this as PesajeItem, _$identity);

  /// Serializes this PesajeItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PesajeItem&&(identical(other.id, id) || other.id == id)&&(identical(other.pesajeId, pesajeId) || other.pesajeId == pesajeId)&&(identical(other.kg, kg) || other.kg == kg)&&(identical(other.origen, origen) || other.origen == origen)&&(identical(other.creadoAt, creadoAt) || other.creadoAt == creadoAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,pesajeId,kg,origen,creadoAt);

@override
String toString() {
  return 'PesajeItem(id: $id, pesajeId: $pesajeId, kg: $kg, origen: $origen, creadoAt: $creadoAt)';
}


}

/// @nodoc
abstract mixin class $PesajeItemCopyWith<$Res>  {
  factory $PesajeItemCopyWith(PesajeItem value, $Res Function(PesajeItem) _then) = _$PesajeItemCopyWithImpl;
@useResult
$Res call({
 String id, String pesajeId, double kg, String? origen, DateTime? creadoAt
});




}
/// @nodoc
class _$PesajeItemCopyWithImpl<$Res>
    implements $PesajeItemCopyWith<$Res> {
  _$PesajeItemCopyWithImpl(this._self, this._then);

  final PesajeItem _self;
  final $Res Function(PesajeItem) _then;

/// Create a copy of PesajeItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? pesajeId = null,Object? kg = null,Object? origen = freezed,Object? creadoAt = freezed,}) {
  return _then(PesajeItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,pesajeId: null == pesajeId ? _self.pesajeId : pesajeId // ignore: cast_nullable_to_non_nullable
as String,kg: null == kg ? _self.kg : kg // ignore: cast_nullable_to_non_nullable
as double,origen: freezed == origen ? _self.origen : origen // ignore: cast_nullable_to_non_nullable
as String?,creadoAt: freezed == creadoAt ? _self.creadoAt : creadoAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [PesajeItem].
extension PesajeItemPatterns on PesajeItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PesajeItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PesajeItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PesajeItem value)  $default,){
final _that = this;
switch (_that) {
case _PesajeItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PesajeItem value)?  $default,){
final _that = this;
switch (_that) {
case _PesajeItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String pesajeId,  double kg,  String? origen,  DateTime? creadoAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PesajeItem() when $default != null:
return $default(_that.id,_that.pesajeId,_that.kg,_that.origen,_that.creadoAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String pesajeId,  double kg,  String? origen,  DateTime? creadoAt)  $default,) {final _that = this;
switch (_that) {
case _PesajeItem():
return $default(_that.id,_that.pesajeId,_that.kg,_that.origen,_that.creadoAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String pesajeId,  double kg,  String? origen,  DateTime? creadoAt)?  $default,) {final _that = this;
switch (_that) {
case _PesajeItem() when $default != null:
return $default(_that.id,_that.pesajeId,_that.kg,_that.origen,_that.creadoAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PesajeItem implements PesajeItem {
  const _PesajeItem({required this.id, required this.pesajeId, this.kg = 0, this.origen, this.creadoAt});
  factory _PesajeItem.fromJson(Map<String, dynamic> json) => _$PesajeItemFromJson(json);

@override final  String id;
@override final  String pesajeId;
@override@JsonKey() final  double kg;
@override final  String? origen;
@override final  DateTime? creadoAt;

/// Create a copy of PesajeItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PesajeItemCopyWith<_PesajeItem> get copyWith => __$PesajeItemCopyWithImpl<_PesajeItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PesajeItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PesajeItem&&(identical(other.id, id) || other.id == id)&&(identical(other.pesajeId, pesajeId) || other.pesajeId == pesajeId)&&(identical(other.kg, kg) || other.kg == kg)&&(identical(other.origen, origen) || other.origen == origen)&&(identical(other.creadoAt, creadoAt) || other.creadoAt == creadoAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,pesajeId,kg,origen,creadoAt);

@override
String toString() {
  return 'PesajeItem(id: $id, pesajeId: $pesajeId, kg: $kg, origen: $origen, creadoAt: $creadoAt)';
}


}

/// @nodoc
abstract mixin class _$PesajeItemCopyWith<$Res> implements $PesajeItemCopyWith<$Res> {
  factory _$PesajeItemCopyWith(_PesajeItem value, $Res Function(_PesajeItem) _then) = __$PesajeItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String pesajeId, double kg, String? origen, DateTime? creadoAt
});




}
/// @nodoc
class __$PesajeItemCopyWithImpl<$Res>
    implements _$PesajeItemCopyWith<$Res> {
  __$PesajeItemCopyWithImpl(this._self, this._then);

  final _PesajeItem _self;
  final $Res Function(_PesajeItem) _then;

/// Create a copy of PesajeItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? pesajeId = null,Object? kg = null,Object? origen = freezed,Object? creadoAt = freezed,}) {
  return _then(_PesajeItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,pesajeId: null == pesajeId ? _self.pesajeId : pesajeId // ignore: cast_nullable_to_non_nullable
as String,kg: null == kg ? _self.kg : kg // ignore: cast_nullable_to_non_nullable
as double,origen: freezed == origen ? _self.origen : origen // ignore: cast_nullable_to_non_nullable
as String?,creadoAt: freezed == creadoAt ? _self.creadoAt : creadoAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
