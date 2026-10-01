import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/periodo.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../data/historial_repository.dart';

final historialRepositoryProvider = Provider<HistorialRepository>((ref) {
  return HistorialRepository(ref.watch(supabaseProvider));
});

/// Todos los períodos cerrados (de las 4 sucursales), más recientes primero.
final periodosCerradosProvider = FutureProvider<List<Periodo>>((ref) {
  return ref.watch(historialRepositoryProvider).listCerrados();
});
