import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/periodo.dart';

/// Acceso al historial de balances: los períodos ya cerrados de todas las
/// sucursales. Es solo lectura — el cálculo de cada balance se reutiliza vía
/// `fn_balance_periodo` (ver `balanceRepositoryProvider`).
class HistorialRepository {
  HistorialRepository(this._db);

  final SupabaseClient _db;

  /// Períodos cerrados de todas las sucursales, más recientes primero.
  Future<List<Periodo>> listCerrados() async {
    final rows = await _db
        .from('periodos')
        .select()
        .eq('estado', 'cerrado')
        .order('fecha_fin', ascending: false);
    return rows.map(Periodo.fromJson).toList();
  }
}
