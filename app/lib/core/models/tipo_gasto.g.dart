// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tipo_gasto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TipoGasto _$TipoGastoFromJson(Map<String, dynamic> json) => _TipoGasto(
  id: json['id'] as String,
  nombre: json['nombre'] as String,
  orden: (json['orden'] as num?)?.toInt() ?? 0,
  activo: json['activo'] as bool? ?? true,
);

Map<String, dynamic> _$TipoGastoToJson(_TipoGasto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nombre': instance.nombre,
      'orden': instance.orden,
      'activo': instance.activo,
    };
