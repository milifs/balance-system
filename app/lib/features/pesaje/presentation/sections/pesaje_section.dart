import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/formatters/formatters.dart';
import '../../../../core/models/corte.dart';
import '../../../../core/models/periodo.dart';
import '../../../../core/models/pesaje.dart';
import '../../../../core/models/precio.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../configuracion/application/configuracion_providers.dart';
import '../../../precios_rinde/application/precios_rinde_providers.dart';
import '../../application/pesaje_providers.dart';
import '../../data/pesaje_repository.dart';
import '../widgets/pesaje_corte_dialog.dart';

/// Lista de cortes (agrupados por categoría) con los kilos pesados y su
/// valorización, para un período + momento dado.
class PesajeSection extends ConsumerWidget {
  const PesajeSection({
    super.key,
    required this.periodo,
    required this.momento,
    required this.editable,
  });

  final Periodo periodo;
  final MomentoPesaje momento;
  final bool editable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cortesAsync = ref.watch(cortesProvider);
    final categoriasAsync = ref.watch(categoriasProvider);
    final preciosAsync = ref.watch(preciosProvider);
    final query = (periodoId: periodo.id, momento: momento);
    final pesajesAsync = ref.watch(pesajesProvider(query));

    // Un solo estado de carga/error combinado.
    final loading = cortesAsync.isLoading ||
        categoriasAsync.isLoading ||
        preciosAsync.isLoading ||
        pesajesAsync.isLoading;
    if (loading) return const Center(child: CircularProgressIndicator());

    final error = cortesAsync.error ??
        categoriasAsync.error ??
        preciosAsync.error ??
        pesajesAsync.error;
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Error al cargar: $error',
              style: const TextStyle(color: AppColors.rojoNegativo)),
        ),
      );
    }

    final cortes =
        cortesAsync.asData!.value.where((c) => c.activo).toList();
    final categorias = categoriasAsync.asData!.value;
    final precios = {
      for (final p in preciosAsync.asData!.value) p.corteId: p,
    };
    final pesajes = {
      for (final pc in pesajesAsync.asData!.value) pc.pesaje.corteId: pc,
    };

    // Agrupar cortes por categoría, respetando el orden de cada una.
    final catsOrdenadas = [...categorias]
      ..sort((a, b) => a.orden.compareTo(b.orden));

    double totalKg = 0;
    double totalValor = 0;
    final filas = <Widget>[];

    for (final cat in catsOrdenadas) {
      final delaCat = cortes.where((c) => c.categoriaId == cat.id).toList()
        ..sort((a, b) => a.orden.compareTo(b.orden));
      if (delaCat.isEmpty) continue;

      filas.add(_CategoriaHeader(nombre: cat.nombre));
      for (final corte in delaCat) {
        final pc = pesajes[corte.id];
        final kg = pc?.totalKg ?? 0;
        final precio = _precioCorte(corte, precios[corte.id]);
        final valor = precio == null ? null : kg * precio;
        totalKg += kg;
        if (valor != null) totalValor += valor;

        filas.add(_CorteTile(
          corte: corte,
          kg: kg,
          itemsCount: pc?.items.length ?? 0,
          valor: valor,
          editable: editable,
          onTap: () => _editarCorte(context, ref, corte, pc, precio, query),
        ));
      }
    }

    return Column(
      children: [
        if (!editable)
          Container(
            width: double.infinity,
            color: AppColors.grisTexto.withValues(alpha: 0.06),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: const Text(
              'Período cerrado: solo lectura.',
              style: TextStyle(color: AppColors.grisTexto),
            ),
          ),
        Expanded(
          child: filas.isEmpty
              ? const Center(
                  child: Text('No hay cortes configurados.',
                      style: TextStyle(color: AppColors.grisTexto)))
              : ListView.separated(
                  itemCount: filas.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, i) => filas[i],
                ),
        ),
        _PesajeFooter(totalKg: totalKg, totalValor: totalValor),
      ],
    );
  }

  /// Precio unitario a usar: el vigente en la Lista de Precios.
  static double? _precioCorte(Corte corte, Precio? precio) => precio?.actual;

  Future<void> _editarCorte(
    BuildContext context,
    WidgetRef ref,
    Corte corte,
    PesajeConItems? pc,
    double? precioVigente,
    PesajeQuery query,
  ) async {
    final fecha =
        momento == MomentoPesaje.apertura ? periodo.fechaInicio : periodo.fechaFin;
    final cambios = await showDialog<bool>(
      context: context,
      builder: (_) => PesajeCorteDialog(
        corte: corte,
        pesajeConItems: pc,
        periodo: periodo,
        momento: momento,
        fecha: fecha,
        precioVigente: precioVigente,
        editable: editable,
      ),
    );
    if (cambios == true) ref.invalidate(pesajesProvider(query));
  }
}

class _CategoriaHeader extends StatelessWidget {
  const _CategoriaHeader({required this.nombre});

  final String nombre;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.crema,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Text(nombre,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: AppColors.grisTexto)),
    );
  }
}

class _CorteTile extends StatelessWidget {
  const _CorteTile({
    required this.corte,
    required this.kg,
    required this.itemsCount,
    required this.valor,
    required this.editable,
    required this.onTap,
  });

  final Corte corte;
  final double kg;
  final int itemsCount;
  final double? valor;
  final bool editable;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tieneKg = kg > 0;
    return ListTile(
      leading: Icon(
        tieneKg ? Icons.scale : Icons.scale_outlined,
        color: tieneKg ? AppColors.verde : AppColors.grisTexto,
      ),
      title: Text(corte.nombre),
      subtitle: Text(
        tieneKg
            ? '${Fmt.kg(kg)} · $itemsCount ${itemsCount == 1 ? 'pesada' : 'pesadas'}'
            : 'Sin pesar',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            valor == null ? '—' : Fmt.moneda(valor),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          Icon(editable ? Icons.chevron_right : Icons.visibility_outlined,
              color: AppColors.grisTexto),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _PesajeFooter extends StatelessWidget {
  const _PesajeFooter({required this.totalKg, required this.totalValor});

  final double totalKg;
  final double totalValor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: AppColors.crema,
        border: Border(top: BorderSide(color: Color(0x22000000))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Total: ${Fmt.kg(totalKg)}',
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: AppColors.grisTexto)),
          Text(Fmt.moneda(totalValor),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.rojo,
              )),
        ],
      ),
    );
  }
}
