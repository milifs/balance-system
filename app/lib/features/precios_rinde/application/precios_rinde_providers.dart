import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/precio.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../data/precios_rinde_repository.dart';

final preciosRindeRepositoryProvider =
    Provider<PreciosRindeRepository>((ref) {
  return PreciosRindeRepository(ref.watch(supabaseProvider));
});

/// Precios actuales de todos los cortes (indexables por corteId en la UI).
final preciosProvider = FutureProvider<List<Precio>>((ref) {
  return ref.watch(preciosRindeRepositoryProvider).listPrecios();
});
