import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/categoria.dart';
import '../../../core/models/corte.dart';
import '../../../core/models/medio_pago.dart';
import '../../../core/models/sucursal.dart';
import '../../../core/models/tipo_gasto.dart';

/// Acceso a los catálogos que se administran en Configuración.
class ConfiguracionRepository {
  ConfiguracionRepository(this._db);

  final SupabaseClient _db;

  // ---------------- Sucursales ----------------
  Future<List<Sucursal>> listSucursales() async {
    final rows = await _db.from('sucursales').select().order('orden');
    return rows.map(Sucursal.fromJson).toList();
  }

  Future<void> upsertSucursal({
    String? id,
    required String nombre,
    required int orden,
    required bool activo,
  }) async {
    final data = {'nombre': nombre, 'orden': orden, 'activo': activo};
    if (id == null) {
      await _db.from('sucursales').insert(data);
    } else {
      await _db.from('sucursales').update(data).eq('id', id);
    }
  }

  // ---------------- Categorías (pieza base + factor) ----------------
  Future<List<Categoria>> listCategorias() async {
    final rows = await _db.from('categorias').select().order('orden');
    return rows.map(Categoria.fromJson).toList();
  }

  Future<void> updateCategoria({
    required String id,
    String? piezaBaseNombre,
    double? piezaBaseKg,
    double? piezaBaseCostoKg,
    required double factorIncremento,
  }) async {
    await _db.from('categorias').update({
      'pieza_base_nombre': piezaBaseNombre,
      'pieza_base_kg': piezaBaseKg,
      'pieza_base_costo_kg': piezaBaseCostoKg,
      'factor_incremento': factorIncremento,
    }).eq('id', id);
  }

  // ---------------- Cortes ----------------
  Future<List<Corte>> listCortes() async {
    final rows = await _db.from('cortes').select().order('orden');
    return rows.map(Corte.fromJson).toList();
  }

  /// No toca `kgr_rinde`: se edita desde Lista de Precios, al lado del precio.
  Future<void> upsertCorte({
    String? id,
    required String categoriaId,
    required String nombre,
    required bool activo,
    required int orden,
  }) async {
    final data = {
      'categoria_id': categoriaId,
      'nombre': nombre,
      'activo': activo,
      'orden': orden,
    };
    if (id == null) {
      await _db.from('cortes').insert(data);
    } else {
      await _db.from('cortes').update(data).eq('id', id);
    }
  }

  // ---------------- Medios de pago ----------------
  Future<List<MedioPago>> listMediosPago() async {
    final rows = await _db.from('medios_pago').select().order('orden');
    return rows.map(MedioPago.fromJson).toList();
  }

  Future<void> upsertMedioPago({
    String? id,
    required String nombre,
    required double retencionPct,
    required int orden,
    required bool activo,
  }) async {
    final data = {
      'nombre': nombre,
      'retencion_pct': retencionPct,
      'orden': orden,
      'activo': activo,
    };
    if (id == null) {
      await _db.from('medios_pago').insert(data);
    } else {
      await _db.from('medios_pago').update(data).eq('id', id);
    }
  }

  // ---------------- Tipos de gasto ----------------
  Future<List<TipoGasto>> listTiposGasto() async {
    final rows = await _db.from('tipos_gasto').select().order('orden');
    return rows.map(TipoGasto.fromJson).toList();
  }

  Future<void> upsertTipoGasto({
    String? id,
    required String nombre,
    required int orden,
    required bool activo,
  }) async {
    final data = {'nombre': nombre, 'orden': orden, 'activo': activo};
    if (id == null) {
      await _db.from('tipos_gasto').insert(data);
    } else {
      await _db.from('tipos_gasto').update(data).eq('id', id);
    }
  }
}
