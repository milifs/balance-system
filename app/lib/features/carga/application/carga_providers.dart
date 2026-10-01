import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/compra.dart';
import '../../../core/models/gasto.dart';
import '../../../core/models/periodo.dart';
import '../../../core/models/venta.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../data/carga_repository.dart';

final cargaRepositoryProvider = Provider<CargaRepository>((ref) {
  return CargaRepository(ref.watch(supabaseProvider));
});

/// Períodos de una sucursal (más recientes primero).
final periodosProvider =
    FutureProvider.family<List<Periodo>, String>((ref, sucursalId) {
  return ref.watch(cargaRepositoryProvider).listPeriodos(sucursalId);
});

/// Ventas de un período.
final ventasProvider =
    FutureProvider.family<List<Venta>, String>((ref, periodoId) {
  return ref.watch(cargaRepositoryProvider).listVentas(periodoId);
});

/// Compras de un período.
final comprasProvider =
    FutureProvider.family<List<Compra>, String>((ref, periodoId) {
  return ref.watch(cargaRepositoryProvider).listCompras(periodoId);
});

/// Gastos de un período.
final gastosProvider =
    FutureProvider.family<List<Gasto>, String>((ref, periodoId) {
  return ref.watch(cargaRepositoryProvider).listGastos(periodoId);
});
