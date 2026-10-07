import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../supabase/supabase_providers.dart';

/// Qué módulos tiene habilitados la cajera. Vive en `core` y no en el feature
/// de Configuración porque lo consumen también el router y el menú lateral.
class PermisosRepository {
  PermisosRepository(this._db);

  final SupabaseClient _db;

  Future<Map<String, bool>> listPermisosCajera() async {
    final rows = await _db.from('permisos_cajera').select();
    return {
      for (final r in rows) r['ruta'] as String: r['habilitado'] as bool,
    };
  }

  Future<void> setPermisoCajera({
    required String ruta,
    required bool habilitado,
  }) async {
    await _db
        .from('permisos_cajera')
        .update({'habilitado': habilitado}).eq('ruta', ruta);
  }
}

final permisosRepositoryProvider = Provider<PermisosRepository>((ref) {
  return PermisosRepository(ref.watch(supabaseProvider));
});

final permisosCajeraProvider = FutureProvider<Map<String, bool>>((ref) {
  return ref.watch(permisosRepositoryProvider).listPermisosCajera();
});
