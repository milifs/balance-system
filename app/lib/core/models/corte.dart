import 'package:freezed_annotation/freezed_annotation.dart';

part 'corte.freezed.dart';
part 'corte.g.dart';

@freezed
abstract class Corte with _$Corte {
  const factory Corte({
    required String id,
    required String categoriaId,
    required String nombre,
    /// Kilos que rinde el corte al despiezar la pieza base. Alimenta el cuadro
    /// de rinde de Lista de Precios; no tiene relación con los kilos pesados
    /// en cada período.
    @Default(0) double kgrRinde,
    @Default(true) bool activo,
    @Default(0) int orden,
  }) = _Corte;

  factory Corte.fromJson(Map<String, dynamic> json) => _$CorteFromJson(json);
}
