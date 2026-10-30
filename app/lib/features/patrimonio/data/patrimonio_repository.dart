import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/patrimonio.dart';

/// Acceso a las fotos de patrimonio (`patrimonios` + `patrimonio_items`).
///
/// Todo el módulo es solo del admin: la RLS de las dos tablas pide
/// `is_admin()` para leer y para escribir.
class PatrimonioRepository {
  PatrimonioRepository(this._db);

  final SupabaseClient _db;

  static String _fecha(DateTime d) =>
      d.toIso8601String().split('T').first; // yyyy-MM-dd

  /// Todas las fotos con sus filas, de la más nueva a la más vieja.
  ///
  /// Trae los items en el mismo viaje (`patrimonio_items(*)`): son dos
  /// columnas de un cuadro, nunca van a ser miles de filas, y Consulta
  /// necesita el total de cada foto para listarlas.
  Future<List<Patrimonio>> listPatrimonios() async {
    final rows = await _db
        .from('patrimonios')
        .select('id, fecha, patrimonio_items(lado, orden, concepto, monto)')
        .order('fecha', ascending: false);
    return rows.map(Patrimonio.fromJson).toList();
  }

  /// La foto de una fecha, o `null` si todavía no se cargó ninguna.
  Future<Patrimonio?> porFecha(DateTime fecha) async {
    final row = await _db
        .from('patrimonios')
        .select('id, fecha, patrimonio_items(lado, orden, concepto, monto)')
        .eq('fecha', _fecha(fecha))
        .maybeSingle();
    return row == null ? null : Patrimonio.fromJson(row);
  }

  /// Guarda el cuadro entero de una fecha y devuelve el id de la foto.
  ///
  /// Va por RPC y no por inserts sueltos para que el reemplazo (borrar las
  /// filas viejas + escribir las nuevas) pase todo junto: si se cortara en
  /// el medio, la foto quedaría vacía. Guardar dos veces la misma fecha
  /// pisa la foto anterior, no la duplica.
  Future<String> guardar({
    required DateTime fecha,
    required List<PatrimonioItem> items,
  }) async {
    final id = await _db.rpc('guardar_patrimonio', params: {
      'p_fecha': _fecha(fecha),
      'p_items': [for (final i in items) i.toJson()],
    });
    return id as String;
  }

  /// Borra una foto completa (las filas se van con el `on delete cascade`).
  Future<void> eliminar(String id) async {
    await _db.from('patrimonios').delete().eq('id', id);
  }
}
