import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/application/auth_providers.dart';
import '../../auth/presentation/login_page.dart';
import '../../auth/presentation/nueva_password_page.dart';
import '../../auth/presentation/sin_acceso_page.dart';
import '../../auth/presentation/splash_page.dart';
import '../../features/balance/presentation/balance_page.dart';
import '../../features/carga/presentation/carga_page.dart';
import '../../features/configuracion/presentation/configuracion_page.dart';
import '../../features/historial/presentation/historial_page.dart';
import '../../features/pesaje/presentation/pesaje_page.dart';
import '../../features/precios_rinde/presentation/precios_rinde_page.dart';
import '../permisos/permisos_providers.dart';
import '../widgets/app_scaffold.dart';
import 'modules.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/carga',
    refreshListenable: _AuthRefresh(ref),
    redirect: (context, state) {
      final profileAsync = ref.read(currentProfileProvider);
      final loc = state.matchedLocation;

      // Llegó por un link de recuperación: hay sesión, pero no puede usar la
      // app hasta elegir contraseña nueva.
      if (ref.read(recuperandoPasswordProvider)) {
        return loc == '/nueva-password' ? null : '/nueva-password';
      }

      // Perfil todavía cargando → splash.
      if (profileAsync.isLoading) {
        return loc == '/splash' ? null : '/splash';
      }

      final profile = profileAsync.asData?.value;
      final logueado = profile != null;

      // Sin sesión → login.
      if (!logueado) {
        return loc == '/login' ? null : '/login';
      }

      // Los permisos de la cajera los define el admin y viven en la base.
      final permisosAsync = ref.read(permisosCajeraProvider);
      if (!profile.esAdmin && permisosAsync.isLoading) {
        return loc == '/splash' ? null : '/splash';
      }
      // Si no se pudieron leer, la cajera se queda afuera (falla cerrado).
      final permisos = permisosAsync.asData?.value ?? const <String, bool>{};
      final visibles = modulosPara(profile.rol, permisos);

      // El admin le apagó todos los módulos a la cajera.
      if (visibles.isEmpty) {
        return loc == '/sin-acceso' ? null : '/sin-acceso';
      }

      final inicio = visibles.first.ruta;
      if (loc == '/login' || loc == '/splash' || loc == '/sin-acceso') {
        return inicio;
      }

      // Guard: módulo que este usuario no tiene habilitado.
      final modulo = modulos.where((m) => loc.startsWith(m.ruta)).firstOrNull;
      if (modulo != null && !visibles.contains(modulo)) {
        return inicio;
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashPage()),
      GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
      GoRoute(path: '/nueva-password', builder: (_, _) => const NuevaPasswordPage()),
      GoRoute(path: '/sin-acceso', builder: (_, _) => const SinAccesoPage()),
      ShellRoute(
        builder: (context, state, child) =>
            AppScaffold(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(path: '/carga', builder: (_, _) => const CargaPage()),
          GoRoute(path: '/precios-rinde', builder: (_, _) => const PreciosRindePage()),
          GoRoute(path: '/pesaje', builder: (_, _) => const PesajePage()),
          GoRoute(path: '/balance', builder: (_, _) => const BalancePage()),
          GoRoute(path: '/historial', builder: (_, _) => const HistorialPage()),
          GoRoute(path: '/configuracion', builder: (_, _) => const ConfiguracionPage()),
        ],
      ),
    ],
  );
});

/// Hace que go_router reevalúe el `redirect` cuando cambia sesión/perfil.
class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh(Ref ref) {
    ref.listen(currentProfileProvider, (_, _) => notifyListeners());
    ref.listen(recuperandoPasswordProvider, (_, _) => notifyListeners());
    ref.listen(permisosCajeraProvider, (_, _) => notifyListeners());
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
