// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pesaje.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Pesaje _$PesajeFromJson(Map<String, dynamic> json) => _Pesaje(
  id: json['id'] as String,
  corteId: json['corte_id'] as String,
  sucursalId: json['sucursal_id'] as String,
  periodoId: json['periodo_id'] as String?,
  fecha: DateTime.parse(json['fecha'] as String),
  momento: $enumDecodeNullable(_$MomentoPesajeEnumMap, json['momento']),
  precioSnapshot: (json['precio_snapshot'] as num?)?.toDouble(),
  creadoAt: json['creado_at'] == null
      ? null
      : DateTime.parse(json['creado_at'] as String),
);

Map<String, dynamic> _$PesajeToJson(_Pesaje instance) => <String, dynamic>{
  'id': instance.id,
  'corte_id': instance.corteId,
  'sucursal_id': instance.sucursalId,
  'periodo_id': instance.periodoId,
  'fecha': instance.fecha.toIso8601String(),
  'momento': _$MomentoPesajeEnumMap[instance.momento],
  'precio_snapshot': instance.precioSnapshot,
  'creado_at': instance.creadoAt?.toIso8601String(),
};

const _$MomentoPesajeEnumMap = {
  MomentoPesaje.apertura: 'apertura',
  MomentoPesaje.cierre: 'cierre',
};
