import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/application/auth_providers.dart';
import '../../../core/models/categoria.dart';
import '../../../core/models/corte.dart';
import '../../../core/models/precio.dart';
import '../../../core/theme/app_theme.dart';
import '../../configuracion/application/configuracion_providers.dart';
import '../application/precios_rinde_providers.dart';
import 'widgets/categoria_precios_view.dart';

/// Lista de Precios + Rinde: dos paneles lado a lado, con tabs por categoría.
class PreciosRindePage extends ConsumerWidget {
  const PreciosRindePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriasAsync = ref.watch(categoriasProvider);
    final cortesAsync = ref.watch(cortesProvider);
    final preciosAsync = ref.watch(preciosProvider);
    final esAdmin =
        ref.watch(currentProfileProvider).asData?.value?.esAdmin ?? false;

    // Espera a que las tres cargas estén listas.
    if (categoriasAsync.isLoading ||
        cortesAsync.isLoading ||
        preciosAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final error =
        categoriasAsync.error ?? cortesAsync.error ?? preciosAsync.error;
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Error al cargar: $error',
              style: const TextStyle(color: AppColors.rojoNegativo)),
        ),
      );
    }

    final categorias = [...categoriasAsync.requireValue]
      ..sort((a, b) => a.orden.compareTo(b.orden));
    final cortes = cortesAsync.requireValue;
    final precios = {
      for (final p in preciosAsync.requireValue) p.corteId: p,
    };

    if (categorias.isEmpty) {
      return const Center(child: Text('No hay categorías configuradas.'));
    }

    return DefaultTabController(
      length: categorias.length,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: AppColors.crema,
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: [for (final c in categorias) Tab(text: c.nombre)],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                for (final c in categorias)
                  _TabContenido(
                    categoria: c,
                    cortes: cortes
                        .where((co) => co.categoriaId == c.id && co.activo)
                        .toList()
                      ..sort((a, b) => a.orden.compareTo(b.orden)),
                    precios: precios,
                    esAdmin: esAdmin,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabContenido extends StatelessWidget {
  const _TabContenido({
    required this.categoria,
    required this.cortes,
    required this.precios,
    required this.esAdmin,
  });

  final Categoria categoria;
  final List<Corte> cortes;
  final Map<String, Precio> precios;
  final bool esAdmin;

  @override
  Widget build(BuildContext context) {
    return CategoriaPreciosView(
      // key por categoría: al cambiar de tab se reinicia el estado local.
      key: ValueKey(categoria.id),
      categoria: categoria,
      cortes: cortes,
      precios: precios,
      esAdmin: esAdmin,
    );
  }
}
