import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/supabase/supabase_providers.dart';
import '../data/auth_repository.dart';
import '../domain/app_profile.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseProvider));
});

/// Perfil del usuario autenticado. Se recalcula cuando cambia la sesión.
final currentProfileProvider = FutureProvider<AppProfile?>((ref) async {
  // Reacciona a login / logout.
  ref.watch(authStateProvider);
  final repo = ref.watch(authRepositoryProvider);
  if (repo.currentSession == null) return null;
  return repo.fetchProfile();
});
