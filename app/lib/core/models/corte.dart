import 'package:freezed_annotation/freezed_annotation.dart';

part 'corte.freezed.dart';
part 'corte.g.dart';

/// Cómo se valoriza el corte en el pesaje.
enum ValorizaA {
  @JsonValue('venta')
  venta,
  @JsonValue('costo')
  costo,
}

@freezed
abstract class Corte with _$Corte {
  const factory Corte({
    required String id,
    required String categoriaId,
    required String nombre,
    @Default(0) double kgrRinde,
    @Default(true) bool activo,
    @Default(0) int orden,
    @Default(ValorizaA.venta) ValorizaA valorizaA,
    double? costoManual,
  }) = _Corte;

  factory Corte.fromJson(Map<String, dynamic> json) => _$CorteFromJson(json);
}
