import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/soporte.dart';

/// Abre una URL. **Tiene que llamarse directo desde el `onPressed`**, sin
/// ningún `await` en el medio: si entre el toque y el launch hay una ida a la
/// red, el navegador bloquea la ventana nueva en silencio porque ya salió del
/// gesto del usuario. Por eso no es `async`.
///
/// No usa `canLaunchUrl`: en web da falsos negativos y aborta el launch sin
/// avisar.
void abrirLink(BuildContext context, Uri uri, {required String siFalla}) {
  final messenger = ScaffoldMessenger.of(context);
  void avisar() {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(siFalla),
        backgroundColor: AppColors.rojoNegativo,
      ));
  }

  launchUrl(uri, mode: LaunchMode.externalApplication).then(
    (abrio) {
      if (!abrio) avisar();
    },
    onError: (_) => avisar(),
  );
}

/// Etiqueta de color del estado de un reclamo.
class EstadoChip extends StatelessWidget {
  const EstadoChip(this.estado, {super.key});

  final EstadoSoporte estado;

  @override
  Widget build(BuildContext context) {
    final color = switch (estado) {
      EstadoSoporte.abierto => AppColors.rojoNegativo,
      EstadoSoporte.enRevision => const Color(0xFFE08A00),
      EstadoSoporte.resuelto => AppColors.verde,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        estado.singular,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// Marca de "no puede seguir trabajando".
class BloqueanteChip extends StatelessWidget {
  const BloqueanteChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.rojo,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.priority_high, size: 13, color: Colors.white),
          SizedBox(width: 2),
          Text(
            'No puede trabajar',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Estado de error de cualquier consulta a `soportes`.
///
/// Pregunta explícitamente por la migración porque es el fallo esperable: hasta
/// que la tabla exista, toda consulta falla con un error de PostgREST que no
/// dice nada útil.
class SoporteError extends StatelessWidget {
  const SoporteError(this.error, {super.key, this.onReintentar});

  final Object error;
  final VoidCallback? onReintentar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 40, color: AppColors.rojoNegativo),
            const SizedBox(height: 12),
            const Text(
              'No se pudieron leer los reclamos.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.rojoNegativo,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '¿Se corrió la migración de Soporte '
              '(supabase/migrations/20261007020000_soporte.sql)? '
              'Hasta que exista la tabla "soportes" esta pantalla no funciona.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.grisTexto),
            ),
            const SizedBox(height: 12),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            if (onReintentar != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onReintentar,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Fila `etiqueta: valor` del contexto de un reclamo.
class DatoContexto extends StatelessWidget {
  const DatoContexto(this.etiqueta, this.valor, {super.key});

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              etiqueta,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(fontSize: 13, color: AppColors.grisTexto),
            ),
          ),
        ],
      ),
    );
  }
}
