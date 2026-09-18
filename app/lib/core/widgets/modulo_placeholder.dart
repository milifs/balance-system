import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Contenido provisorio de un módulo aún no implementado (fase F1).
class ModuloPlaceholder extends StatelessWidget {
  const ModuloPlaceholder({
    super.key,
    required this.titulo,
    required this.icono,
    required this.descripcion,
    this.fase,
  });

  final String titulo;
  final IconData icono;
  final String descripcion;
  final String? fase;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icono, size: 56, color: AppColors.rojo),
                const SizedBox(height: 16),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.grisTexto,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  descripcion,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.grisTexto, height: 1.4),
                ),
                if (fase != null) ...[
                  const SizedBox(height: 16),
                  Chip(
                    label: Text('Próximamente · $fase'),
                    backgroundColor: AppColors.rojo.withValues(alpha: 0.08),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
