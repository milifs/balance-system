import 'package:freezed_annotation/freezed_annotation.dart';

part 'pesaje.freezed.dart';
part 'pesaje.g.dart';

/// Momento del pesaje dentro del período: apertura (stock inicial) o
/// cierre (stock final). El balance valoriza cada momento por separado.
enum MomentoPesaje {
  @JsonValue('apertura')
  apertura,
  @JsonValue('cierre')
  cierre,
}

extension MomentoPesajeX on MomentoPesaje {
  String get label =>
      this == MomentoPesaje.apertura ? 'Apertura' : 'Cierre';
}

/// Sesión de pesaje de un corte en una sucursal/fecha. Agrupa uno o más
/// [PesajeItem] (pesos individuales) y guarda el precio vigente al momento.
@freezed
abstract class Pesaje with _$Pesaje {
  const factory Pesaje({
    required String id,
    required String corteId,
    required String sucursalId,
    String? periodoId,
    required DateTime fecha,
    MomentoPesaje? momento,
    double? precioSnapshot,
    DateTime? creadoAt,
  }) = _Pesaje;

  factory Pesaje.fromJson(Map<String, dynamic> json) => _$PesajeFromJson(json);
}
