import 'package:freezed_annotation/freezed_annotation.dart';

part 'periodo.freezed.dart';
part 'periodo.g.dart';

/// Estado de un período de balance.
enum EstadoPeriodo {
  @JsonValue('abierto')
  abierto,
  @JsonValue('cerrado')
  cerrado,
}

/// Rango de fechas del balance de una sucursal (entre dos pesajes).
@freezed
abstract class Periodo with _$Periodo {
  const factory Periodo({
    required String id,
    required String sucursalId,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    @Default(EstadoPeriodo.abierto) EstadoPeriodo estado,
    double? stockInicialManual,
    DateTime? creadoAt,
  }) = _Periodo;

  factory Periodo.fromJson(Map<String, dynamic> json) =>
      _$PeriodoFromJson(json);
}
