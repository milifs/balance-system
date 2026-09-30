import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/categoria.dart';
import '../../../core/models/corte.dart';
import '../../../core/models/medio_pago.dart';
import '../../../core/models/sucursal.dart';
import '../../../core/models/tipo_gasto.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../data/configuracion_repository.dart';

final configuracionRepositoryProvider = Provider<ConfiguracionRepository>((ref) {
  return ConfiguracionRepository(ref.watch(supabaseProvider));
});

final sucursalesProvider = FutureProvider<List<Sucursal>>((ref) {
  return ref.watch(configuracionRepositoryProvider).listSucursales();
});

final categoriasProvider = FutureProvider<List<Categoria>>((ref) {
  return ref.watch(configuracionRepositoryProvider).listCategorias();
});

final cortesProvider = FutureProvider<List<Corte>>((ref) {
  return ref.watch(configuracionRepositoryProvider).listCortes();
});

final mediosPagoProvider = FutureProvider<List<MedioPago>>((ref) {
  return ref.watch(configuracionRepositoryProvider).listMediosPago();
});

final tiposGastoProvider = FutureProvider<List<TipoGasto>>((ref) {
  return ref.watch(configuracionRepositoryProvider).listTiposGasto();
});
