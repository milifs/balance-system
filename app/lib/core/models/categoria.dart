import 'package:freezed_annotation/freezed_annotation.dart';

part 'categoria.freezed.dart';
part 'categoria.g.dart';

@freezed
abstract class Categoria with _$Categoria {
  const factory Categoria({
    required String id,
    required String nombre,
    required int orden,
    String? piezaBaseNombre,
    double? piezaBaseKg,
    double? piezaBaseCostoKg,
    @Default(1.0) double factorIncremento,
  }) = _Categoria;

  const Categoria._();

  factory Categoria.fromJson(Map<String, dynamic> json) =>
      _$CategoriaFromJson(json);

  /// Costo de la pieza base = kg × $/kg (null si falta algún dato).
  double? get costoPiezaBase =>
      (piezaBaseKg != null && piezaBaseCostoKg != null)
          ? piezaBaseKg! * piezaBaseCostoKg!
          : null;
}
