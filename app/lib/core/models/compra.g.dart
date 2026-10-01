// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compra.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Compra _$CompraFromJson(Map<String, dynamic> json) => _Compra(
  id: json['id'] as String,
  periodoId: json['periodo_id'] as String,
  sucursalId: json['sucursal_id'] as String,
  fecha: DateTime.parse(json['fecha'] as String),
  tipoCompra: $enumDecode(_$TipoCompraEnumMap, json['tipo_compra']),
  monto: (json['monto'] as num?)?.toDouble() ?? 0,
  proveedor: json['proveedor'] as String?,
  creadoAt: json['creado_at'] == null
      ? null
      : DateTime.parse(json['creado_at'] as String),
);

Map<String, dynamic> _$CompraToJson(_Compra instance) => <String, dynamic>{
  'id': instance.id,
  'periodo_id': instance.periodoId,
  'sucursal_id': instance.sucursalId,
  'fecha': instance.fecha.toIso8601String(),
  'tipo_compra': _$TipoCompraEnumMap[instance.tipoCompra]!,
  'monto': instance.monto,
  'proveedor': instance.proveedor,
  'creado_at': instance.creadoAt?.toIso8601String(),
};

const _$TipoCompraEnumMap = {
  TipoCompra.carne: 'Carne',
  TipoCompra.cerdo: 'Cerdo',
  TipoCompra.pollo: 'Pollo',
};
