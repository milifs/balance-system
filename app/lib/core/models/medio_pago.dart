import 'package:freezed_annotation/freezed_annotation.dart';

part 'medio_pago.freezed.dart';
part 'medio_pago.g.dart';

@freezed
abstract class MedioPago with _$MedioPago {
  const factory MedioPago({
    required String id,
    required String nombre,
    @Default(0) double retencionPct,
    @Default(0) int orden,
    @Default(true) bool activo,
  }) = _MedioPago;

  factory MedioPago.fromJson(Map<String, dynamic> json) =>
      _$MedioPagoFromJson(json);
}
