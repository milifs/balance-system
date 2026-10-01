// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gasto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Gasto _$GastoFromJson(Map<String, dynamic> json) => _Gasto(
  id: json['id'] as String,
  periodoId: json['periodo_id'] as String,
  sucursalId: json['sucursal_id'] as String,
  fecha: DateTime.parse(json['fecha'] as String),
  tipoGastoId: json['tipo_gasto_id'] as String,
  monto: (json['monto'] as num?)?.toDouble() ?? 0,
  creadoAt: json['creado_at'] == null
      ? null
      : DateTime.parse(json['creado_at'] as String),
);

Map<String, dynamic> _$GastoToJson(_Gasto instance) => <String, dynamic>{
  'id': instance.id,
  'periodo_id': instance.periodoId,
  'sucursal_id': instance.sucursalId,
  'fecha': instance.fecha.toIso8601String(),
  'tipo_gasto_id': instance.tipoGastoId,
  'monto': instance.monto,
  'creado_at': instance.creadoAt?.toIso8601String(),
};
