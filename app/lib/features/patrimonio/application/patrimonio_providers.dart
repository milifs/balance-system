import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/patrimonio.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../data/patrimonio_repository.dart';

final patrimonioRepositoryProvider = Provider<PatrimonioRepository>((ref) {
  return PatrimonioRepository(ref.watch(supabaseProvider));
});

/// Todas las fotos de patrimonio, de la más nueva a la más vieja.
/// Lo usa Consulta; Carga lo invalida después de guardar.
final patrimoniosProvider = FutureProvider<List<Patrimonio>>((ref) {
  return ref.watch(patrimonioRepositoryProvider).listPatrimonios();
});
