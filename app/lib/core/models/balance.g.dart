// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'balance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BalancePeriodo _$BalancePeriodoFromJson(Map<String, dynamic> json) =>
    _BalancePeriodo(
      ventasBruto: (json['ventas_bruto'] as num?)?.toDouble() ?? 0,
      ventasNeto: (json['ventas_neto'] as num?)?.toDouble() ?? 0,
      comprasTotal: (json['compras_total'] as num?)?.toDouble() ?? 0,
      stockInicial: (json['stock_inicial'] as num?)?.toDouble() ?? 0,
      stockFinal: (json['stock_final'] as num?)?.toDouble() ?? 0,
      cmv: (json['cmv'] as num?)?.toDouble() ?? 0,
      gastosTotal: (json['gastos_total'] as num?)?.toDouble() ?? 0,
      ganancia: (json['ganancia'] as num?)?.toDouble() ?? 0,
      utilidadNetaPct: (json['utilidad_neta_pct'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$BalancePeriodoToJson(_BalancePeriodo instance) =>
    <String, dynamic>{
      'ventas_bruto': instance.ventasBruto,
      'ventas_neto': instance.ventasNeto,
      'compras_total': instance.comprasTotal,
      'stock_inicial': instance.stockInicial,
      'stock_final': instance.stockFinal,
      'cmv': instance.cmv,
      'gastos_total': instance.gastosTotal,
      'ganancia': instance.ganancia,
      'utilidad_neta_pct': instance.utilidadNetaPct,
    };

_Consolidado _$ConsolidadoFromJson(Map<String, dynamic> json) => _Consolidado(
  ventasBruto: (json['ventas_bruto'] as num?)?.toDouble() ?? 0,
  ventasNeto: (json['ventas_neto'] as num?)?.toDouble() ?? 0,
  comprasTotal: (json['compras_total'] as num?)?.toDouble() ?? 0,
  cmv: (json['cmv'] as num?)?.toDouble() ?? 0,
  gastosTotal: (json['gastos_total'] as num?)?.toDouble() ?? 0,
  ganancia: (json['ganancia'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$ConsolidadoToJson(_Consolidado instance) =>
    <String, dynamic>{
      'ventas_bruto': instance.ventasBruto,
      'ventas_neto': instance.ventasNeto,
      'compras_total': instance.comprasTotal,
      'cmv': instance.cmv,
      'gastos_total': instance.gastosTotal,
      'ganancia': instance.ganancia,
    };

_ConsolidadoSucursal _$ConsolidadoSucursalFromJson(Map<String, dynamic> json) =>
    _ConsolidadoSucursal(
      sucursalId: json['sucursal_id'] as String,
      sucursal: json['sucursal'] as String,
      orden: (json['orden'] as num?)?.toInt() ?? 0,
      periodos: (json['periodos'] as num?)?.toInt() ?? 0,
      ventasBruto: (json['ventas_bruto'] as num?)?.toDouble() ?? 0,
      ventasNeto: (json['ventas_neto'] as num?)?.toDouble() ?? 0,
      comprasTotal: (json['compras_total'] as num?)?.toDouble() ?? 0,
      cmv: (json['cmv'] as num?)?.toDouble() ?? 0,
      gastosTotal: (json['gastos_total'] as num?)?.toDouble() ?? 0,
      ganancia: (json['ganancia'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$ConsolidadoSucursalToJson(
  _ConsolidadoSucursal instance,
) => <String, dynamic>{
  'sucursal_id': instance.sucursalId,
  'sucursal': instance.sucursal,
  'orden': instance.orden,
  'periodos': instance.periodos,
  'ventas_bruto': instance.ventasBruto,
  'ventas_neto': instance.ventasNeto,
  'compras_total': instance.comprasTotal,
  'cmv': instance.cmv,
  'gastos_total': instance.gastosTotal,
  'ganancia': instance.ganancia,
};
