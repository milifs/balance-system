// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tipo_compra.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TipoCompra _$TipoCompraFromJson(Map<String, dynamic> json) => _TipoCompra(
  id: json['id'] as String,
  nombre: json['nombre'] as String,
  orden: (json['orden'] as num?)?.toInt() ?? 0,
  activo: json['activo'] as bool? ?? true,
);

Map<String, dynamic> _$TipoCompraToJson(_TipoCompra instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nombre': instance.nombre,
      'orden': instance.orden,
      'activo': instance.activo,
    };
