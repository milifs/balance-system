import 'package:freezed_annotation/freezed_annotation.dart';

part 'pesaje_item.freezed.dart';
part 'pesaje_item.g.dart';

/// Peso individual dentro de un pesaje (una batea, una cámara, etc.).
@freezed
abstract class PesajeItem with _$PesajeItem {
  const factory PesajeItem({
    required String id,
    required String pesajeId,
    @Default(0) double kg,
    String? origen,
    DateTime? creadoAt,
  }) = _PesajeItem;

  factory PesajeItem.fromJson(Map<String, dynamic> json) =>
      _$PesajeItemFromJson(json);
}
