// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pesaje_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PesajeItem _$PesajeItemFromJson(Map<String, dynamic> json) => _PesajeItem(
  id: json['id'] as String,
  pesajeId: json['pesaje_id'] as String,
  kg: (json['kg'] as num?)?.toDouble() ?? 0,
  origen: json['origen'] as String?,
  creadoAt: json['creado_at'] == null
      ? null
      : DateTime.parse(json['creado_at'] as String),
);

Map<String, dynamic> _$PesajeItemToJson(_PesajeItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pesaje_id': instance.pesajeId,
      'kg': instance.kg,
      'origen': instance.origen,
      'creado_at': instance.creadoAt?.toIso8601String(),
    };
