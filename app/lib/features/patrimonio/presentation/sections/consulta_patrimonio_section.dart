import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/formatters/formatters.dart';
import '../../../../core/models/patrimonio.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../carga/presentation/widgets/carga_ui.dart';
import '../../application/patrimonio_providers.dart';
import '../patrimonio_pdf.dart';
import '../widgets/patrimonio_ui.dart';

/// Pestaña Consulta: los cuadros ya guardados, de la fecha más nueva a la
/// más vieja. Solo lectura — para corregir uno se vuelve a Carga con esa
/// fecha, que trae lo guardado y lo reemplaza al guardar.
class ConsultaPatrimonioSection extends ConsumerStatefulWidget {
  const ConsultaPatrimonioSection({super.key});

  @override
  ConsumerState<ConsultaPatrimonioSection> createState() =>
      _ConsultaPatrimonioSectionState();
}

class _ConsultaPatrimonioSectionState
    extends ConsumerState<ConsultaPatrimonioSection> {
  String? _seleccionadoId;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(patrimoniosProvider);

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Error al cargar los cuadros guardados: $e',
              style: const TextStyle(color: AppColors.rojoNegativo)),
        ),
      ),
      data: (cuadros) {
        if (cuadros.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'Todavía no hay cuadros guardados.\n'
                'Cargá uno en la pestaña Carga para verlo acá.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.grisTexto),
              ),
            ),
          );
        }

        final sel = _resolver(cuadros);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 320,
              child: _Lista(
                cuadros: cuadros,
                seleccionadoId: sel.id,
                onSeleccionar: (id) => setState(() => _seleccionadoId = id),
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: _Detalle(patrimonio: sel)),
          ],
        );
      },
    );
  }

  Patrimonio _resolver(List<Patrimonio> cuadros) {
    for (final p in cuadros) {
      if (p.id == _seleccionadoId) return p;
    }
    return cuadros.first;
  }
}

/// Las fechas guardadas, con el saldo de cada una para ver la evolución
/// sin tener que abrir uno por uno.
class _Lista extends StatelessWidget {
  const _Lista({
    required this.cuadros,
    required this.seleccionadoId,
    required this.onSeleccionar,
  });

  final List<Patrimonio> cuadros;
  final String? seleccionadoId;
  final ValueChanged<String> onSeleccionar;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: cuadros.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final p = cuadros[i];
        final seleccionado = p.id == seleccionadoId;
        final color =
            p.saldo < 0 ? AppColors.rojoNegativo : AppColors.verde;
        return ListTile(
          selected: seleccionado,
          selectedTileColor: AppColors.rojo.withValues(alpha: 0.08),
          title: Text(Fmt.fecha(p.fecha),
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(
            '${p.haber.length + p.debe.length} conceptos',
            style: const TextStyle(fontSize: 12, color: AppColors.grisTexto),
          ),
          trailing: Text(Fmt.moneda(p.saldo),
              style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          onTap: () => onSeleccionar(p.id),
        );
      },
    );
  }
}

class _Detalle extends ConsumerWidget {
  const _Detalle({required this.patrimonio});

  final Patrimonio patrimonio;

  Future<void> _exportar(BuildContext context) async {
    try {
      await exportarPatrimonioPdf(
        fecha: patrimonio.fecha,
        haber: patrimonio.haber,
        debe: patrimonio.debe,
      );
    } catch (e) {
      if (context.mounted) {
        mostrarMensaje(context, 'No se pudo exportar el PDF: $e', error: true);
      }
    }
  }

  Future<void> _eliminar(BuildContext context, WidgetRef ref) async {
    final ok = await confirmarBorrado(
        context, 'el cuadro del ${Fmt.fecha(patrimonio.fecha)}');
    if (!ok) return;
    try {
      await ref.read(patrimonioRepositoryProvider).eliminar(patrimonio.id);
      ref.invalidate(patrimoniosProvider);
    } catch (e) {
      if (context.mounted) {
        mostrarMensaje(context, 'No se pudo eliminar: $e', error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
          child: Wrap(
            spacing: 16,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('Patrimonio al ${Fmt.fecha(patrimonio.fecha)}',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.grisTexto)),
              ExportarPdfBoton(onExportar: () => _exportar(context)),
              OutlinedButton.icon(
                onPressed: () => _eliminar(context, ref),
                style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.rojoNegativo),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Eliminar'),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: LayoutBuilder(
            builder: (context, c) {
              final haber = _ColumnaLeida(
                lado: LadoPatrimonio.haber,
                items: patrimonio.haber,
                total: patrimonio.totalHaber,
              );
              final debe = _ColumnaLeida(
                lado: LadoPatrimonio.debe,
                items: patrimonio.debe,
                total: patrimonio.totalDebe,
              );
              if (c.maxWidth < 760) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SizedBox(height: 360, child: haber),
                      const SizedBox(height: 16),
                      SizedBox(height: 360, child: debe),
                    ],
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: haber),
                    const SizedBox(width: 16),
                    Expanded(child: debe),
                  ],
                ),
              );
            },
          ),
        ),
        SaldoBar(fecha: patrimonio.fecha, saldo: patrimonio.saldo),
      ],
    );
  }
}

class _ColumnaLeida extends StatelessWidget {
  const _ColumnaLeida({
    required this.lado,
    required this.items,
    required this.total,
  });

  final LadoPatrimonio lado;
  final List<PatrimonioItem> items;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ColumnaHeader(lado: lado),
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Text('Sin conceptos.',
                        style: TextStyle(color: AppColors.grisTexto)),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, i) => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          Expanded(child: Text(items[i].concepto)),
                          const SizedBox(width: 12),
                          Text(Fmt.moneda(items[i].monto),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
          ),
          ColumnaTotal(lado: lado, total: total),
        ],
      ),
    );
  }
}
