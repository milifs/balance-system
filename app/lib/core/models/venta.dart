import 'package:freezed_annotation/freezed_annotation.dart';

part 'venta.freezed.dart';
part 'venta.g.dart';

/// Venta del período discriminada por medio de pago.
@freezed
abstract class Venta with _$Venta {
  const factory Venta({
    required String id,
    required String periodoId,
    required String sucursalId,
    required DateTime fecha,
    required String medioPagoId,
    @Default(0) double monto,
    /// Retención del medio de pago al momento de cargar la venta. La completa
    /// el trigger `trg_ventas_retencion`; el balance calcula el neto con esta
    /// y no con el % que el medio tenga hoy.
    double? retencionPct,
    DateTime? creadoAt,
  }) = _Venta;

  factory Venta.fromJson(Map<String, dynamic> json) => _$VentaFromJson(json);
}

extension VentaNeto on Venta {
  /// Monto menos la retención que tenía el medio de pago cuando se cargó la
  /// venta. [retencionActual] es el respaldo para las ventas que se cargaron
  /// antes de que la retención se guardara por venta.
  double netoCon(double retencionActual) =>
      monto * (1 - (retencionPct ?? retencionActual) / 100);
}
