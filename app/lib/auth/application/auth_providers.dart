import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase/supabase_providers.dart';
import '../data/auth_repository.dart';
import '../domain/app_profile.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseProvider));
});

/// `true` mientras el usuario entró por un link de recuperación y todavía no
/// eligió contraseña nueva. El router lo usa para retenerlo en esa pantalla.
final recuperandoPasswordProvider = NotifierProvider<RecuperandoPassword, bool>(
  RecuperandoPassword.new,
);

class RecuperandoPassword extends Notifier<bool> {
  @override
  bool build() {
    // El evento puede emitirse durante `Supabase.initialize()`, antes de que
    // exista este provider; `onAuthStateChange` lo reemite al suscribirse.
    ref.listen(authStateProvider, fireImmediately: true, (_, next) {
      switch (next.asData?.value.event) {
        case AuthChangeEvent.passwordRecovery:
          state = true;
        case AuthChangeEvent.signedOut:
          state = false;
        case _:
          break;
      }
    });
    return false;
  }

  void completado() => state = false;
}

/// Mensaje del último error llegado por link (p. ej. recuperación vencida).
final authLinkErrorProvider = Provider<String?>((ref) {
  final error = ref.watch(authStateProvider).error;
  return error is AuthException ? error.message : null;
});

/// Perfil del usuario autenticado. Se recalcula cuando cambia la sesión.
final currentProfileProvider = FutureProvider<AppProfile?>((ref) async {
  // Reacciona a login / logout.
  ref.watch(authStateProvider);
  final repo = ref.watch(authRepositoryProvider);
  if (repo.currentSession == null) return null;
  return repo.fetchProfile();
});
