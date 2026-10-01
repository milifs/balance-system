import 'package:freezed_annotation/freezed_annotation.dart';

part 'gasto.freezed.dart';
part 'gasto.g.dart';

/// Gasto operativo de la sucursal en el período (luz, internet, etc.).
@freezed
abstract class Gasto with _$Gasto {
  const factory Gasto({
    required String id,
    required String periodoId,
    required String sucursalId,
    required DateTime fecha,
    required String tipoGastoId,
    @Default(0) double monto,
    DateTime? creadoAt,
  }) = _Gasto;

  factory Gasto.fromJson(Map<String, dynamic> json) => _$GastoFromJson(json);
}
