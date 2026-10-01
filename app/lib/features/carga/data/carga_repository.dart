import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/compra.dart';
import '../../../core/models/gasto.dart';
import '../../../core/models/periodo.dart';
import '../../../core/models/venta.dart';

/// Una fila del "cuadro" de compras: tipo de carne fijo + monto + proveedor
/// opcional. Se usa para cargar varias filas de una sola vez.
class FilaCompra {
  const FilaCompra({required this.tipo, required this.monto, this.proveedor});

  final TipoCompra tipo;
  final double monto;
  final String? proveedor;
}

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

  /// Carga en un solo insert los montos no vacíos del "cuadro" de ventas
  /// (una fila fija por medio de pago, sin combo). `montosPorMedioPago`
  /// mapea `medio_pago_id -> monto`.
  Future<void> agregarVentas({
    required String periodoId,
    required String sucursalId,
    required DateTime fecha,
    required Map<String, double> montosPorMedioPago,
  }) async {
    if (montosPorMedioPago.isEmpty) return;
    final f = _fecha(fecha);
    await _db.from('ventas').insert([
      for (final e in montosPorMedioPago.entries)
        {
          'periodo_id': periodoId,
          'sucursal_id': sucursalId,
          'fecha': f,
          'medio_pago_id': e.key,
          'monto': e.value,
        },
    ]);
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

  /// Carga en un solo insert las filas no vacías del "cuadro" de compras
  /// (una fila fija por tipo de carne, sin combo).
  Future<void> agregarCompras({
    required String periodoId,
    required String sucursalId,
    required DateTime fecha,
    required List<FilaCompra> filas,
  }) async {
    if (filas.isEmpty) return;
    final f = _fecha(fecha);
    await _db.from('compras').insert([
      for (final r in filas)
        {
          'periodo_id': periodoId,
          'sucursal_id': sucursalId,
          'fecha': f,
          'tipo_compra': r.tipo.label,
          'monto': r.monto,
          'proveedor': r.proveedor,
        },
    ]);
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

  /// Carga en un solo insert los montos no vacíos del "cuadro" de gastos
  /// (una fila fija por tipo de gasto, sin combo). `montosPorTipoGasto`
  /// mapea `tipo_gasto_id -> monto`.
  Future<void> agregarGastos({
    required String periodoId,
    required String sucursalId,
    required DateTime fecha,
    required Map<String, double> montosPorTipoGasto,
  }) async {
    if (montosPorTipoGasto.isEmpty) return;
    final f = _fecha(fecha);
    await _db.from('gastos').insert([
      for (final e in montosPorTipoGasto.entries)
        {
          'periodo_id': periodoId,
          'sucursal_id': sucursalId,
          'fecha': f,
          'tipo_gasto_id': e.key,
          'monto': e.value,
        },
    ]);
  }

  Future<void> eliminarGasto(String id) async {
    await _db.from('gastos').delete().eq('id', id);
  }
}
