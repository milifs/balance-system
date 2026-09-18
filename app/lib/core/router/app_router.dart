import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/application/auth_providers.dart';
import '../../auth/presentation/login_page.dart';
import '../../auth/presentation/splash_page.dart';
import '../../features/balance/presentation/balance_page.dart';
import '../../features/carga/presentation/carga_page.dart';
import '../../features/configuracion/presentation/configuracion_page.dart';
import '../../features/historial/presentation/historial_page.dart';
import '../../features/pesaje/presentation/pesaje_page.dart';
import '../../features/precios_rinde/presentation/precios_rinde_page.dart';
import '../widgets/app_scaffold.dart';
import 'modules.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/carga',
    refreshListenable: _AuthRefresh(ref),
    redirect: (context, state) {
      final profileAsync = ref.read(currentProfileProvider);
      final loc = state.matchedLocation;

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

      // Logueado pero en login/splash → mandar al inicio.
      if (loc == '/login' || loc == '/splash') {
        return rutaInicioAdmin;
      }

      // Guard por rol: la cajera no entra a módulos soloAdmin.
      final modulo = modulos.where((m) => loc.startsWith(m.ruta)).firstOrNull;
      if (modulo != null && !modulo.visiblePara(profile.rol)) {
        return rutaInicioCajera;
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashPage()),
      GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
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
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
