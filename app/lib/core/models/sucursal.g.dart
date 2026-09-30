// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sucursal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Sucursal _$SucursalFromJson(Map<String, dynamic> json) => _Sucursal(
  id: json['id'] as String,
  nombre: json['nombre'] as String,
  orden: (json['orden'] as num).toInt(),
  activo: json['activo'] as bool? ?? true,
);

Map<String, dynamic> _$SucursalToJson(_Sucursal instance) => <String, dynamic>{
  'id': instance.id,
  'nombre': instance.nombre,
  'orden': instance.orden,
  'activo': instance.activo,
};
