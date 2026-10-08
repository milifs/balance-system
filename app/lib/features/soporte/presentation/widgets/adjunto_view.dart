import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../application/soporte_providers.dart';
import 'soporte_ui.dart';

/// Captura de pantalla de un reclamo.
///
/// El link se firma al abrir la pantalla, así cuando el usuario toca "Abrir la
/// foto" la URL ya está resuelta y el launch sale limpio del gesto.
///
/// El botón "Abrir la foto" está SIEMPRE, no solo cuando falla la preview: las
/// fotos sacadas con iPhone llegan en HEIC y el navegador no las renderiza,
/// pero el archivo está bien y se puede abrir aparte.
class AdjuntoView extends ConsumerWidget {
  const AdjuntoView({super.key, required this.path});

  final String path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final link = ref.watch(linkAdjuntoProvider(path));

    return link.when(
      loading: () => const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Text(
        'No se pudo generar el link de la captura: $e',
        style: const TextStyle(color: AppColors.rojoNegativo, fontSize: 13),
      ),
      data: (url) {
        if (url == null) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                url,
                height: 260,
                fit: BoxFit.contain,
                alignment: Alignment.centerLeft,
                errorBuilder: (_, _, _) => Container(
                  height: 100,
                  width: double.infinity,
                  alignment: Alignment.center,
                  color: const Color(0x11000000),
                  padding: const EdgeInsets.all(12),
                  child: const Text(
                    'No se puede previsualizar este formato.\n'
                    'Abrila con el botón de abajo.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.grisTexto, fontSize: 13),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => abrirLink(
                context,
                Uri.parse(url),
                siFalla: 'No se pudo abrir la foto.',
              ),
              icon: const Icon(Icons.open_in_new, size: 18),
              label: const Text('Abrir la foto'),
            ),
          ],
        );
      },
    );
  }
}
