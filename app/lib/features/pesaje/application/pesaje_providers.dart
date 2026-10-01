import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/pesaje.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../data/pesaje_repository.dart';

final pesajeRepositoryProvider = Provider<PesajeRepository>((ref) {
  return PesajeRepository(ref.watch(supabaseProvider));
});

/// Argumentos del provider de pesajes: período + momento (apertura/cierre).
typedef PesajeQuery = ({String periodoId, MomentoPesaje momento});

/// Pesajes (con items) de un período y momento.
final pesajesProvider =
    FutureProvider.family<List<PesajeConItems>, PesajeQuery>((ref, q) {
  return ref
      .watch(pesajeRepositoryProvider)
      .getPesajes(periodoId: q.periodoId, momento: q.momento);
});
