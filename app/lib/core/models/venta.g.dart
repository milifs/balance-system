// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'venta.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Venta _$VentaFromJson(Map<String, dynamic> json) => _Venta(
  id: json['id'] as String,
  periodoId: json['periodo_id'] as String,
  sucursalId: json['sucursal_id'] as String,
  fecha: DateTime.parse(json['fecha'] as String),
  medioPagoId: json['medio_pago_id'] as String,
  monto: (json['monto'] as num?)?.toDouble() ?? 0,
  creadoAt: json['creado_at'] == null
      ? null
      : DateTime.parse(json['creado_at'] as String),
);

Map<String, dynamic> _$VentaToJson(_Venta instance) => <String, dynamic>{
  'id': instance.id,
  'periodo_id': instance.periodoId,
  'sucursal_id': instance.sucursalId,
  'fecha': instance.fecha.toIso8601String(),
  'medio_pago_id': instance.medioPagoId,
  'monto': instance.monto,
  'creado_at': instance.creadoAt?.toIso8601String(),
};
