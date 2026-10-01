// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'periodo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Periodo _$PeriodoFromJson(Map<String, dynamic> json) => _Periodo(
  id: json['id'] as String,
  sucursalId: json['sucursal_id'] as String,
  fechaInicio: DateTime.parse(json['fecha_inicio'] as String),
  fechaFin: DateTime.parse(json['fecha_fin'] as String),
  estado:
      $enumDecodeNullable(_$EstadoPeriodoEnumMap, json['estado']) ??
      EstadoPeriodo.abierto,
  stockInicialManual: (json['stock_inicial_manual'] as num?)?.toDouble(),
  creadoAt: json['creado_at'] == null
      ? null
      : DateTime.parse(json['creado_at'] as String),
);

Map<String, dynamic> _$PeriodoToJson(_Periodo instance) => <String, dynamic>{
  'id': instance.id,
  'sucursal_id': instance.sucursalId,
  'fecha_inicio': instance.fechaInicio.toIso8601String(),
  'fecha_fin': instance.fechaFin.toIso8601String(),
  'estado': _$EstadoPeriodoEnumMap[instance.estado]!,
  'stock_inicial_manual': instance.stockInicialManual,
  'creado_at': instance.creadoAt?.toIso8601String(),
};

const _$EstadoPeriodoEnumMap = {
  EstadoPeriodo.abierto: 'abierto',
  EstadoPeriodo.cerrado: 'cerrado',
};
