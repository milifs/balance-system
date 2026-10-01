import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/precio.dart';

/// Rotación de precios de un corte al guardar una nueva lista:
/// `nuevo → actual`, `actual → último`, `último → penúltimo`.
class RotacionPrecio {
  const RotacionPrecio({
    required this.corteId,
    required this.nuevoActual,
    required this.nuevoUltimo,
    required this.nuevoPenultimo,
  });

  final String corteId;
  final double? nuevoActual;
  final double? nuevoUltimo;
  final double? nuevoPenultimo;
}

/// Acceso a la tabla `precios` (un registro por corte).
class PreciosRindeRepository {
  PreciosRindeRepository(this._db);

  final SupabaseClient _db;

  Future<List<Precio>> listPrecios() async {
    final rows = await _db.from('precios').select();
    return rows.map(Precio.fromJson).toList();
  }

  /// Guarda la nueva lista de una categoría rotando los precios.
  /// Un solo `upsert` (conflicto por `corte_id`, que es único). Solo el admin
  /// puede escribir (RLS `admin modifica precios`).
  Future<void> guardarPrecios(List<RotacionPrecio> rotaciones) async {
    if (rotaciones.isEmpty) return;
    final now = DateTime.now().toUtc().toIso8601String();
    final payload = [
      for (final r in rotaciones)
        {
          'corte_id': r.corteId,
          'precio_actual': r.nuevoActual,
          'precio_ultimo': r.nuevoUltimo,
          'precio_penultimo': r.nuevoPenultimo,
          'actualizado_at': now,
        },
    ];
    await _db.from('precios').upsert(payload, onConflict: 'corte_id');
  }
}
