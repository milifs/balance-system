import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/balance.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../data/balance_repository.dart';

final balanceRepositoryProvider = Provider<BalanceRepository>((ref) {
  return BalanceRepository(ref.watch(supabaseProvider));
});

/// Balance de un período (una sucursal), calculado en Postgres.
final balancePeriodoProvider =
    FutureProvider.family<BalancePeriodo, String>((ref, periodoId) {
  return ref.watch(balanceRepositoryProvider).balancePeriodo(periodoId);
});

/// Clave del consolidado: rango de fechas (desde/hasta).
typedef RangoFechas = ({DateTime ini, DateTime fin});

/// Consolidado de las 4 sucursales para un rango de fechas.
final consolidadoProvider =
    FutureProvider.family<Consolidado, RangoFechas>((ref, rango) {
  return ref.watch(balanceRepositoryProvider).consolidado(rango.ini, rango.fin);
});

/// Qué aportó cada sucursal a ese consolidado (las que no aportaron nada
/// vienen con `periodos` en 0).
final consolidadoDetalleProvider =
    FutureProvider.family<List<ConsolidadoSucursal>, RangoFechas>((ref, rango) {
  return ref
      .watch(balanceRepositoryProvider)
      .consolidadoDetalle(rango.ini, rango.fin);
});
