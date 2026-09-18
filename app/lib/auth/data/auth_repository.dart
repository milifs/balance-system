import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/app_profile.dart';

/// Acceso a autenticación y al perfil del usuario en Supabase.
class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  Session? get currentSession => _client.auth.currentSession;
  User? get currentUser => _client.auth.currentUser;

  Future<void> signIn({required String email, required String password}) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() => _client.auth.signOut();

  /// Trae el perfil (rol + sucursal) del usuario autenticado.
  Future<AppProfile?> fetchProfile() async {
    final user = currentUser;
    if (user == null) return null;
    final data = await _client
        .from('profiles')
        .select('id, nombre, rol, sucursal_id')
        .eq('id', user.id)
        .maybeSingle();
    if (data == null) return null;
    return AppProfile.fromJson(data);
  }
}
