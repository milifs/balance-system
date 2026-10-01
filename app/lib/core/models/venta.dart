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
    DateTime? creadoAt,
  }) = _Venta;

  factory Venta.fromJson(Map<String, dynamic> json) => _$VentaFromJson(json);
}
