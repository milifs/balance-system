import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/balance.dart';

/// Acceso a los cálculos de balance. Las fórmulas viven en Postgres
/// (`fn_balance_periodo`, `fn_consolidado`): el cliente solo las invoca.
/// El cierre/reapertura de un período cambia `periodos.estado`.
class BalanceRepository {
  BalanceRepository(this._db);

  final SupabaseClient _db;

  static String _fecha(DateTime d) =>
      d.toIso8601String().split('T').first; // yyyy-MM-dd

  /// Balance de una sucursal para un período.
  Future<BalancePeriodo> balancePeriodo(String periodoId) async {
    final res = await _db.rpc<dynamic>(
      'fn_balance_periodo',
      params: {'p_periodo': periodoId},
    );
    final rows = (res as List).cast<Map<String, dynamic>>();
    return rows.isEmpty
        ? const BalancePeriodo()
        : BalancePeriodo.fromJson(rows.first);
  }

  /// Consolidado de las 4 sucursales para un rango (solo períodos cerrados).
  Future<Consolidado> consolidado(DateTime ini, DateTime fin) async {
    final res = await _db.rpc<dynamic>(
      'fn_consolidado',
      params: {'p_ini': _fecha(ini), 'p_fin': _fecha(fin)},
    );
    final rows = (res as List).cast<Map<String, dynamic>>();
    return rows.isEmpty ? const Consolidado() : Consolidado.fromJson(rows.first);
  }

  /// Cierra el período (pasa a solo lectura y entra al historial).
  Future<void> cerrarPeriodo(String id) async {
    await _db.from('periodos').update({'estado': 'cerrado'}).eq('id', id);
  }

  /// Reabre un período cerrado (vuelve a ser editable).
  Future<void> reabrirPeriodo(String id) async {
    await _db.from('periodos').update({'estado': 'abierto'}).eq('id', id);
  }
}
