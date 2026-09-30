import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';

/// Encabezado + contenedor estándar de una sección de Configuración.
class SectionScaffold extends StatelessWidget {
  const SectionScaffold({
    super.key,
    required this.titulo,
    required this.descripcion,
    required this.child,
    this.onAgregar,
    this.textoAgregar = 'Agregar',
  });

  final String titulo;
  final String descripcion;
  final Widget child;
  final VoidCallback? onAgregar;
  final String textoAgregar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.grisTexto,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(descripcion,
                        style: const TextStyle(color: AppColors.grisTexto)),
                  ],
                ),
              ),
              if (onAgregar != null)
                FilledButton.icon(
                  onPressed: onAgregar,
                  icon: const Icon(Icons.add),
                  label: Text(textoAgregar),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(child: Card(child: child)),
        ],
      ),
    );
  }
}

/// Muestra un mensaje de éxito/error abajo.
void mostrarMensaje(BuildContext context, String texto, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(texto),
      backgroundColor: error ? AppColors.rojoNegativo : AppColors.verde,
    ));
}

/// Estado de carga/error/vacío estándar para un AsyncValue de lista.
Widget listaAsync<T>({
  required AsyncValue<List<T>> value,
  required Widget Function(List<T> items) builder,
  String vacio = 'No hay registros.',
}) {
  return value.when(
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (e, _) => Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text('Error al cargar: $e',
            style: const TextStyle(color: AppColors.rojoNegativo)),
      ),
    ),
    data: (items) => items.isEmpty ? Center(child: Text(vacio)) : builder(items),
  );
}
