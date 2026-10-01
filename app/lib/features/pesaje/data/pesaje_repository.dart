import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/pesaje.dart';
import '../../../core/models/pesaje_item.dart';

/// Pesaje con sus pesos individuales ya cargados (join anidado de PostgREST).
class PesajeConItems {
  const PesajeConItems({required this.pesaje, required this.items});

  final Pesaje pesaje;
  final List<PesajeItem> items;

  double get totalKg => items.fold(0, (s, i) => s + i.kg);
}

/// Acceso a los datos del Módulo de Pesaje.
///
/// Un pesaje agrupa los pesos (pesaje_items) de un corte en una sucursal,
/// dentro de un período y momento (apertura/cierre). La RLS decide qué
/// sucursales ve/escribe cada usuario.
class PesajeRepository {
  PesajeRepository(this._db);

  final SupabaseClient _db;

  static String _fecha(DateTime d) =>
      d.toIso8601String().split('T').first; // yyyy-MM-dd

  static String _momento(MomentoPesaje m) =>
      m == MomentoPesaje.apertura ? 'apertura' : 'cierre';

  /// Pesajes (con items) de un período y momento.
  Future<List<PesajeConItems>> getPesajes({
    required String periodoId,
    required MomentoPesaje momento,
  }) async {
    final rows = await _db
        .from('pesajes')
        .select('*, pesaje_items(*)')
        .eq('periodo_id', periodoId)
        .eq('momento', _momento(momento));
    return rows.map((row) {
      final itemsJson = (row['pesaje_items'] as List?) ?? const [];
      final items = itemsJson
          .map((e) => PesajeItem.fromJson(e as Map<String, dynamic>))
          .toList();
      return PesajeConItems(pesaje: Pesaje.fromJson(row), items: items);
    }).toList();
  }

  /// Crea la sesión de pesaje de un corte (sin items todavía).
  Future<Pesaje> crearPesaje({
    required String corteId,
    required String sucursalId,
    required String periodoId,
    required MomentoPesaje momento,
    required DateTime fecha,
    double? precioSnapshot,
  }) async {
    final row = await _db
        .from('pesajes')
        .insert({
          'corte_id': corteId,
          'sucursal_id': sucursalId,
          'periodo_id': periodoId,
          'momento': _momento(momento),
          'fecha': _fecha(fecha),
          'precio_snapshot': precioSnapshot,
        })
        .select()
        .single();
    return Pesaje.fromJson(row);
  }

  /// Pesos individuales de un pesaje (orden de carga).
  Future<List<PesajeItem>> listItems(String pesajeId) async {
    final rows = await _db
        .from('pesaje_items')
        .select()
        .eq('pesaje_id', pesajeId)
        .order('creado_at');
    return rows.map(PesajeItem.fromJson).toList();
  }

  /// Agrega un peso individual a un pesaje existente.
  Future<void> agregarItem({
    required String pesajeId,
    required double kg,
    String? origen,
  }) async {
    await _db.from('pesaje_items').insert({
      'pesaje_id': pesajeId,
      'kg': kg,
      'origen': origen,
    });
  }

  Future<void> eliminarItem(String itemId) async {
    await _db.from('pesaje_items').delete().eq('id', itemId);
  }

  /// Elimina la sesión de pesaje completa (borra sus items en cascada).
  Future<void> eliminarPesaje(String pesajeId) async {
    await _db.from('pesajes').delete().eq('id', pesajeId);
  }
}
