import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/application/auth_providers.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../data/soporte_repository.dart';
import '../domain/soporte.dart';

final soporteRepositoryProvider = Provider<SoporteRepository>((ref) {
  return SoporteRepository(ref.watch(supabaseProvider));
});

/// Con qué nombre queda registrado el usuario actual: es lo que se guarda en
/// `reportado_por` al crear un reclamo y en `resuelto_por` al cerrarlo.
///
/// La tabla identifica a la persona por texto, así que el valor se calcula en
/// un solo lugar: el mismo que se escribe al crear el reclamo es el que filtra
/// "Tus reclamos". Si se calcularan distinto, la persona no vería sus propios
/// reclamos.
final identidadUsuarioProvider = Provider<String?>((ref) {
  final profile = ref.watch(currentProfileProvider).asData?.value;
  if (profile == null) return null;
  if (profile.nombre.trim().isNotEmpty) return profile.nombre.trim();
  return ref.watch(authRepositoryProvider).currentUser?.email ??
      'Sin identificar';
});

/// Los últimos 5 reclamos del usuario, con su estado y la respuesta.
final misReclamosProvider = FutureProvider<List<Soporte>>((ref) async {
  final quien = ref.watch(identidadUsuarioProvider);
  if (quien == null) return const [];
  return ref.watch(soporteRepositoryProvider).misUltimos(quien);
});

/// Todos los reclamos, para la bandeja. Los tres tabs y sus contadores salen
/// de acá, así un solo refresh actualiza todo.
final soportesProvider = FutureProvider<List<Soporte>>((ref) {
  return ref.watch(soporteRepositoryProvider).listTodos();
});

/// Link firmado de una captura. Family por path: se firma cuando se necesita
/// y queda cacheado mientras la pantalla esté abierta.
final linkAdjuntoProvider =
    FutureProvider.family<String?, String>((ref, path) {
  return ref.watch(soporteRepositoryProvider).linkAdjunto(path);
});
