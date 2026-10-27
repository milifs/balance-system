import 'package:freezed_annotation/freezed_annotation.dart';

part 'balance.freezed.dart';
part 'balance.g.dart';

/// Resultado de `fn_balance_periodo(periodo_id)`: el balance de una sucursal
/// en un período. Todos los montos ya vienen calculados desde Postgres
/// (única fuente de verdad de la fórmula).
@freezed
abstract class BalancePeriodo with _$BalancePeriodo {
  const factory BalancePeriodo({
    @Default(0) double ventasBruto,
    @Default(0) double ventasNeto,
    @Default(0) double comprasTotal,
    @Default(0) double stockInicial,
    @Default(0) double stockFinal,
    @Default(0) double cmv,
    @Default(0) double gastosTotal,
    @Default(0) double ganancia,
    @Default(0) double utilidadNetaPct,
  }) = _BalancePeriodo;

  factory BalancePeriodo.fromJson(Map<String, dynamic> json) =>
      _$BalancePeriodoFromJson(json);
}

/// Resultado de `fn_consolidado(fecha_ini, fecha_fin)`: suma de los balances
/// de las sucursales cuyos períodos cerrados caen en el rango.
@freezed
abstract class Consolidado with _$Consolidado {
  const factory Consolidado({
    @Default(0) double ventasBruto,
    @Default(0) double ventasNeto,
    @Default(0) double comprasTotal,
    @Default(0) double cmv,
    @Default(0) double gastosTotal,
    @Default(0) double ganancia,
  }) = _Consolidado;

  factory Consolidado.fromJson(Map<String, dynamic> json) =>
      _$ConsolidadoFromJson(json);
}

/// Una fila de `fn_consolidado_detalle(fecha_ini, fecha_fin)`: lo que aportó
/// cada sucursal al consolidado y con cuántos períodos. Las sucursales que no
/// aportaron ninguno vienen igual, con `periodos` en 0, para que la pantalla
/// pueda mostrar que quedaron afuera en vez de omitirlas.
@freezed
abstract class ConsolidadoSucursal with _$ConsolidadoSucursal {
  const factory ConsolidadoSucursal({
    required String sucursalId,
    required String sucursal,
    @Default(0) int orden,
    @Default(0) int periodos,
    @Default(0) double ventasBruto,
    @Default(0) double ventasNeto,
    @Default(0) double comprasTotal,
    @Default(0) double cmv,
    @Default(0) double gastosTotal,
    @Default(0) double ganancia,
  }) = _ConsolidadoSucursal;

  factory ConsolidadoSucursal.fromJson(Map<String, dynamic> json) =>
      _$ConsolidadoSucursalFromJson(json);
}
