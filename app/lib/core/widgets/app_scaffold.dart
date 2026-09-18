import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/application/auth_providers.dart';
import '../../auth/domain/app_profile.dart';
import '../router/modules.dart';
import '../theme/app_theme.dart';

/// Layout principal: NavigationRail con los módulos permitidos + AppBar.
class AppScaffold extends ConsumerWidget {
  const AppScaffold({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider).asData?.value;
    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final visibles = modulosPara(profile.rol);
    final selectedIndex = visibles.indexWhere((m) => location.startsWith(m.ruta));
    final tituloModulo = selectedIndex >= 0 ? visibles[selectedIndex].label : '';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Don Chacho', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 12),
            Text('· $tituloModulo',
                style: const TextStyle(fontWeight: FontWeight.w400)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: Text(
                _rolLabel(profile),
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            extended: MediaQuery.of(context).size.width > 1100,
            minWidth: 72,
            selectedIndex: selectedIndex >= 0 ? selectedIndex : 0,
            onDestinationSelected: (i) => context.go(visibles[i].ruta),
            leading: const SizedBox(height: 8),
            destinations: [
              for (final m in visibles)
                NavigationRailDestination(
                  icon: Icon(m.icono),
                  label: Text(m.label),
                ),
            ],
          ),
          const VerticalDivider(width: 1, color: Color(0x11000000)),
          Expanded(
            child: Container(
              color: AppColors.crema,
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  String _rolLabel(AppProfile p) => p.esAdmin ? 'Administrador' : 'Cajera';
}
