// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'categoria.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Categoria _$CategoriaFromJson(Map<String, dynamic> json) => _Categoria(
  id: json['id'] as String,
  nombre: json['nombre'] as String,
  orden: (json['orden'] as num).toInt(),
  piezaBaseNombre: json['pieza_base_nombre'] as String?,
  piezaBaseKg: (json['pieza_base_kg'] as num?)?.toDouble(),
  piezaBaseCostoKg: (json['pieza_base_costo_kg'] as num?)?.toDouble(),
  factorIncremento: (json['factor_incremento'] as num?)?.toDouble() ?? 1.0,
);

Map<String, dynamic> _$CategoriaToJson(_Categoria instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nombre': instance.nombre,
      'orden': instance.orden,
      'pieza_base_nombre': instance.piezaBaseNombre,
      'pieza_base_kg': instance.piezaBaseKg,
      'pieza_base_costo_kg': instance.piezaBaseCostoKg,
      'factor_incremento': instance.factorIncremento,
    };
