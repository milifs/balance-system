// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'corte.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Corte _$CorteFromJson(Map<String, dynamic> json) => _Corte(
  id: json['id'] as String,
  categoriaId: json['categoria_id'] as String,
  nombre: json['nombre'] as String,
  kgrRinde: (json['kgr_rinde'] as num?)?.toDouble() ?? 0,
  activo: json['activo'] as bool? ?? true,
  orden: (json['orden'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$CorteToJson(_Corte instance) => <String, dynamic>{
  'id': instance.id,
  'categoria_id': instance.categoriaId,
  'nombre': instance.nombre,
  'kgr_rinde': instance.kgrRinde,
  'activo': instance.activo,
  'orden': instance.orden,
};
