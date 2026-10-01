import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatters/formatters.dart';
import '../../../core/models/periodo.dart';
import '../../../core/models/sucursal.dart';
import '../../../core/theme/app_theme.dart';
import '../../configuracion/application/configuracion_providers.dart';
import '../application/carga_providers.dart';
import 'carga_pdf.dart';
import 'sections/compras_section.dart';
import 'sections/gastos_section.dart';
import 'sections/ventas_section.dart';
import 'widgets/carga_ui.dart';
import 'widgets/periodo_dialog.dart';

/// Módulo de Carga: elige sucursal + período y carga ventas, compras y gastos.
class CargaPage extends ConsumerStatefulWidget {
  const CargaPage({super.key});

  @override
  ConsumerState<CargaPage> createState() => _CargaPageState();
}

class _CargaPageState extends ConsumerState<CargaPage> {
  String? _sucursalId;
  String? _periodoId;

  @override
  Widget build(BuildContext context) {
    final sucursalesAsync = ref.watch(sucursalesProvider);

    return sucursalesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _error('Error al cargar sucursales: $e'),
      data: (sucursales) {
        final activas = sucursales.where((s) => s.activo).toList();
        if (activas.isEmpty) {
          return const Center(child: Text('No hay sucursales configuradas.'));
        }
        final sucursalId = _sucursalId ?? activas.first.id;
        return _ConSucursal(
          sucursales: activas,
          sucursalId: sucursalId,
          periodoIdSeleccionado: _periodoId,
          onCambioSucursal: (id) => setState(() {
            _sucursalId = id;
            _periodoId = null; // resetea el período al cambiar de sucursal
          }),
          onCambioPeriodo: (id) => setState(() => _periodoId = id),
          onPeriodoCreado: (id) => setState(() => _periodoId = id),
        );
      },
    );
  }

  Widget _error(String msg) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(msg,
              style: const TextStyle(color: AppColors.rojoNegativo)),
        ),
      );
}

/// Ya resuelta la sucursal, resuelve el período y arma la pantalla.
class _ConSucursal extends ConsumerWidget {
  const _ConSucursal({
    required this.sucursales,
    required this.sucursalId,
    required this.periodoIdSeleccionado,
    required this.onCambioSucursal,
    required this.onCambioPeriodo,
    required this.onPeriodoCreado,
  });

  final List<Sucursal> sucursales;
  final String sucursalId;
  final String? periodoIdSeleccionado;
  final ValueChanged<String> onCambioSucursal;
  final ValueChanged<String> onCambioPeriodo;
  final ValueChanged<String> onPeriodoCreado;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final periodosAsync = ref.watch(periodosProvider(sucursalId));

    return periodosAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Error al cargar períodos: $e',
              style: const TextStyle(color: AppColors.rojoNegativo)),
        ),
      ),
      data: (periodos) {
        final periodo = _resolverPeriodo(periodos);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Encabezado(
              sucursales: sucursales,
              sucursalId: sucursalId,
              periodos: periodos,
              periodo: periodo,
              onCambioSucursal: onCambioSucursal,
              onCambioPeriodo: onCambioPeriodo,
              onNuevoPeriodo: () => _nuevoPeriodo(context, ref),
              onEditarPeriodo:
                  periodo == null ? null : () => _editarPeriodo(context, ref, periodo),
            ),
            const Divider(height: 1),
            Expanded(
              child: periodo == null
                  ? _SinPeriodo(onNuevo: () => _nuevoPeriodo(context, ref))
                  : _Secciones(periodo: periodo),
            ),
          ],
        );
      },
    );
  }

  Periodo? _resolverPeriodo(List<Periodo> periodos) {
    if (periodos.isEmpty) return null;
    for (final p in periodos) {
      if (p.id == periodoIdSeleccionado) return p;
    }
    return periodos.first;
  }

  Future<void> _nuevoPeriodo(BuildContext context, WidgetRef ref) async {
    final id = await showDialog<String>(
      context: context,
      builder: (_) => PeriodoDialog(sucursalId: sucursalId),
    );
    if (id != null) {
      ref.invalidate(periodosProvider(sucursalId));
      onPeriodoCreado(id);
    }
  }

  Future<void> _editarPeriodo(
      BuildContext context, WidgetRef ref, Periodo periodo) async {
    final id = await showDialog<String>(
      context: context,
      builder: (_) => PeriodoDialog(sucursalId: sucursalId, periodo: periodo),
    );
    if (id != null) ref.invalidate(periodosProvider(sucursalId));
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado({
    required this.sucursales,
    required this.sucursalId,
    required this.periodos,
    required this.periodo,
    required this.onCambioSucursal,
    required this.onCambioPeriodo,
    required this.onNuevoPeriodo,
    required this.onEditarPeriodo,
  });

  final List<Sucursal> sucursales;
  final String sucursalId;
  final List<Periodo> periodos;
  final Periodo? periodo;
  final ValueChanged<String> onCambioSucursal;
  final ValueChanged<String> onCambioPeriodo;
  final VoidCallback onNuevoPeriodo;
  final VoidCallback? onEditarPeriodo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 220,
            child: DropdownButtonFormField<String>(
              initialValue: sucursalId,
              decoration: const InputDecoration(
                labelText: 'Sucursal',
                isDense: true,
              ),
              items: [
                for (final s in sucursales)
                  DropdownMenuItem(value: s.id, child: Text(s.nombre)),
              ],
              onChanged: (v) {
                if (v != null) onCambioSucursal(v);
              },
            ),
          ),
          SizedBox(
            width: 320,
            child: DropdownButtonFormField<String>(
              initialValue: periodo?.id,
              decoration: const InputDecoration(
                labelText: 'Período',
                isDense: true,
              ),
              hint: const Text('Sin períodos'),
              items: [
                for (final p in periodos)
                  DropdownMenuItem(value: p.id, child: Text(_labelPeriodo(p))),
              ],
              onChanged: periodos.isEmpty
                  ? null
                  : (v) {
                      if (v != null) onCambioPeriodo(v);
                    },
            ),
          ),
          if (periodo != null) _EstadoChip(estado: periodo!.estado),
          if (periodo != null)
            _ExportarPdfBoton(
              sucursal: sucursales.firstWhere((s) => s.id == sucursalId),
              periodo: periodo!,
            ),
          if (onEditarPeriodo != null)
            OutlinedButton.icon(
              onPressed: onEditarPeriodo,
              icon: const Icon(Icons.edit_calendar, size: 18),
              label: const Text('Editar período'),
            ),
          FilledButton.icon(
            onPressed: onNuevoPeriodo,
            icon: const Icon(Icons.add),
            label: const Text('Nuevo período'),
          ),
        ],
      ),
    );
  }

  static String _labelPeriodo(Periodo p) =>
      '${Fmt.fecha(p.fechaInicio)} – ${Fmt.fecha(p.fechaFin)}';
}

/// Botón que arma el PDF con todo lo cargado del período y lo descarga.
class _ExportarPdfBoton extends ConsumerStatefulWidget {
  const _ExportarPdfBoton({required this.sucursal, required this.periodo});

  final Sucursal sucursal;
  final Periodo periodo;

  @override
  ConsumerState<_ExportarPdfBoton> createState() => _ExportarPdfBotonState();
}

class _ExportarPdfBotonState extends ConsumerState<_ExportarPdfBoton> {
  bool _generando = false;

  Future<void> _exportar() async {
    setState(() => _generando = true);
    try {
      final id = widget.periodo.id;
      final ventas = await ref.read(ventasProvider(id).future);
      final compras = await ref.read(comprasProvider(id).future);
      final gastos = await ref.read(gastosProvider(id).future);
      final medios = await ref.read(mediosPagoProvider.future);
      final tipos = await ref.read(tiposGastoProvider.future);

      await exportarCargaPdf(
        sucursal: widget.sucursal,
        periodo: widget.periodo,
        ventas: ventas,
        medios: {for (final m in medios) m.id: m},
        compras: compras,
        tipos: {for (final t in tipos) t.id: t},
        gastos: gastos,
      );
    } catch (e) {
      if (mounted) {
        mostrarMensaje(context, 'No se pudo exportar el PDF: $e', error: true);
      }
    } finally {
      if (mounted) setState(() => _generando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _generando ? null : _exportar,
      icon: _generando
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.picture_as_pdf, size: 18),
      label: const Text('Exportar PDF'),
    );
  }
}

class _EstadoChip extends StatelessWidget {
  const _EstadoChip({required this.estado});

  final EstadoPeriodo estado;

  @override
  Widget build(BuildContext context) {
    final abierto = estado == EstadoPeriodo.abierto;
    final color = abierto ? AppColors.verde : AppColors.grisTexto;
    return Chip(
      avatar: Icon(abierto ? Icons.lock_open : Icons.lock,
          size: 16, color: color),
      label: Text(abierto ? 'Abierto' : 'Cerrado',
          style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      backgroundColor: color.withValues(alpha: 0.10),
      side: BorderSide(color: color.withValues(alpha: 0.30)),
    );
  }
}

class _Secciones extends StatelessWidget {
  const _Secciones({required this.periodo});

  final Periodo periodo;

  @override
  Widget build(BuildContext context) {
    final editable = periodo.estado == EstadoPeriodo.abierto;
    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!editable)
            Container(
              width: double.infinity,
              color: AppColors.grisTexto.withValues(alpha: 0.06),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: const Text(
                'Período cerrado: solo lectura. No se pueden agregar ni '
                'eliminar registros.',
                style: TextStyle(color: AppColors.grisTexto),
              ),
            ),
          const Material(
            color: AppColors.crema,
            child: TabBar(
              tabs: [
                Tab(text: 'Ventas'),
                Tab(text: 'Compras'),
                Tab(text: 'Gastos'),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                margin: EdgeInsets.zero,
                child: TabBarView(
                  children: [
                    VentasSection(periodo: periodo, editable: editable),
                    ComprasSection(periodo: periodo, editable: editable),
                    GastosSection(periodo: periodo, editable: editable),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SinPeriodo extends StatelessWidget {
  const _SinPeriodo({required this.onNuevo});

  final VoidCallback onNuevo;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.event_note, size: 56, color: AppColors.rojo),
          const SizedBox(height: 12),
          const Text('Esta sucursal todavía no tiene períodos.',
              style: TextStyle(fontSize: 16, color: AppColors.grisTexto)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onNuevo,
            icon: const Icon(Icons.add),
            label: const Text('Crear primer período'),
          ),
        ],
      ),
    );
  }
}
