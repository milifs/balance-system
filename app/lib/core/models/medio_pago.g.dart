// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medio_pago.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MedioPago _$MedioPagoFromJson(Map<String, dynamic> json) => _MedioPago(
  id: json['id'] as String,
  nombre: json['nombre'] as String,
  retencionPct: (json['retencion_pct'] as num?)?.toDouble() ?? 0,
  orden: (json['orden'] as num?)?.toInt() ?? 0,
  activo: json['activo'] as bool? ?? true,
);

Map<String, dynamic> _$MedioPagoToJson(_MedioPago instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nombre': instance.nombre,
      'retencion_pct': instance.retencionPct,
      'orden': instance.orden,
      'activo': instance.activo,
    };
