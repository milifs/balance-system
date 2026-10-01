import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/compra.dart';
import '../../../core/models/gasto.dart';
import '../../../core/models/periodo.dart';
import '../../../core/models/venta.dart';

/// Acceso a los datos del Módulo de Carga: períodos y los registros
/// individuales de ventas, compras y gastos.
///
/// La RLS decide qué sucursales ve/escribe cada usuario (hoy la cajera opera
/// todas las sucursales; el admin siempre puede todo).
class CargaRepository {
  CargaRepository(this._db);

  final SupabaseClient _db;

  static String _fecha(DateTime d) =>
      d.toIso8601String().split('T').first; // yyyy-MM-dd

  // ---------------- Períodos ----------------
  Future<List<Periodo>> listPeriodos(String sucursalId) async {
    final rows = await _db
        .from('periodos')
        .select()
        .eq('sucursal_id', sucursalId)
        .order('fecha_inicio', ascending: false);
    return rows.map(Periodo.fromJson).toList();
  }

  Future<Periodo> crearPeriodo({
    required String sucursalId,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    double? stockInicialManual,
  }) async {
    final row = await _db
        .from('periodos')
        .insert({
          'sucursal_id': sucursalId,
          'fecha_inicio': _fecha(fechaInicio),
          'fecha_fin': _fecha(fechaFin),
          'estado': 'abierto',
          'stock_inicial_manual': stockInicialManual,
        })
        .select()
        .single();
    return Periodo.fromJson(row);
  }

  Future<void> actualizarPeriodo({
    required String id,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    double? stockInicialManual,
  }) async {
    await _db.from('periodos').update({
      'fecha_inicio': _fecha(fechaInicio),
      'fecha_fin': _fecha(fechaFin),
      'stock_inicial_manual': stockInicialManual,
    }).eq('id', id);
  }

  // ---------------- Ventas ----------------
  Future<List<Venta>> listVentas(String periodoId) async {
    final rows = await _db
        .from('ventas')
        .select()
        .eq('periodo_id', periodoId)
        .order('fecha', ascending: false)
        .order('creado_at', ascending: false);
    return rows.map(Venta.fromJson).toList();
  }

  Future<void> agregarVenta({
    required String periodoId,
    required String sucursalId,
    required DateTime fecha,
    required String medioPagoId,
    required double monto,
  }) async {
    await _db.from('ventas').insert({
      'periodo_id': periodoId,
      'sucursal_id': sucursalId,
      'fecha': _fecha(fecha),
      'medio_pago_id': medioPagoId,
      'monto': monto,
    });
  }

  Future<void> eliminarVenta(String id) async {
    await _db.from('ventas').delete().eq('id', id);
  }

  // ---------------- Compras ----------------
  Future<List<Compra>> listCompras(String periodoId) async {
    final rows = await _db
        .from('compras')
        .select()
        .eq('periodo_id', periodoId)
        .order('fecha', ascending: false)
        .order('creado_at', ascending: false);
    return rows.map(Compra.fromJson).toList();
  }

  Future<void> agregarCompra({
    required String periodoId,
    required String sucursalId,
    required DateTime fecha,
    required TipoCompra tipoCompra,
    required double monto,
    String? proveedor,
  }) async {
    await _db.from('compras').insert({
      'periodo_id': periodoId,
      'sucursal_id': sucursalId,
      'fecha': _fecha(fecha),
      'tipo_compra': tipoCompra.label,
      'monto': monto,
      'proveedor': proveedor,
    });
  }

  Future<void> eliminarCompra(String id) async {
    await _db.from('compras').delete().eq('id', id);
  }

  // ---------------- Gastos ----------------
  Future<List<Gasto>> listGastos(String periodoId) async {
    final rows = await _db
        .from('gastos')
        .select()
        .eq('periodo_id', periodoId)
        .order('fecha', ascending: false)
        .order('creado_at', ascending: false);
    return rows.map(Gasto.fromJson).toList();
  }

  Future<void> agregarGasto({
    required String periodoId,
    required String sucursalId,
    required DateTime fecha,
    required String tipoGastoId,
    required double monto,
  }) async {
    await _db.from('gastos').insert({
      'periodo_id': periodoId,
      'sucursal_id': sucursalId,
      'fecha': _fecha(fecha),
      'tipo_gasto_id': tipoGastoId,
      'monto': monto,
    });
  }

  Future<void> eliminarGasto(String id) async {
    await _db.from('gastos').delete().eq('id', id);
  }
}
