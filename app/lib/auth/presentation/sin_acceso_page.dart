import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/modules.dart';
import '../../core/theme/app_theme.dart';
import '../application/auth_providers.dart';

/// La cajera entró pero el admin no le dejó ningún módulo habilitado.
class SinAccesoPage extends ConsumerWidget {
  const SinAccesoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.crema,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline, size: 48, color: AppColors.rojo),
                  const SizedBox(height: 16),
                  const Text(
                    'Sin módulos habilitados',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.rojo,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'El administrador todavía no te habilitó ningún módulo. '
                    'Pedile que los active en Configuración.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.grisTexto),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => ref.read(authRepositoryProvider).signOut(),
                    child: const Text('Cerrar sesión'),
                  ),
                  const SizedBox(height: 8),
                  // Esta es la salida de la trampa: quedarse sin módulos es
                  // justamente el problema que hay que poder reportar.
                  TextButton.icon(
                    onPressed: () => context.go(rutaSoporte),
                    icon: const Icon(Icons.support_agent, size: 18),
                    label: const Text('Reportar un problema'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
