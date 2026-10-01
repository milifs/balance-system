import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatters/formatters.dart';
import '../../../core/models/pesaje.dart';
import '../../../core/models/periodo.dart';
import '../../../core/models/sucursal.dart';
import '../../../core/theme/app_theme.dart';
import '../../carga/application/carga_providers.dart';
import '../../configuracion/application/configuracion_providers.dart';
import 'sections/pesaje_section.dart';

/// Módulo de Pesaje: elige sucursal + período + momento (apertura/cierre) y
/// registra los kilos pesados de cada corte.
class PesajePage extends ConsumerStatefulWidget {
  const PesajePage({super.key});

  @override
  ConsumerState<PesajePage> createState() => _PesajePageState();
}

class _PesajePageState extends ConsumerState<PesajePage> {
  String? _sucursalId;
  String? _periodoId;
  MomentoPesaje _momento = MomentoPesaje.cierre;

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
          momento: _momento,
          onCambioSucursal: (id) => setState(() {
            _sucursalId = id;
            _periodoId = null;
          }),
          onCambioPeriodo: (id) => setState(() => _periodoId = id),
          onCambioMomento: (m) => setState(() => _momento = m),
        );
      },
    );
  }

  Widget _error(String msg) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child:
              Text(msg, style: const TextStyle(color: AppColors.rojoNegativo)),
        ),
      );
}

class _ConSucursal extends ConsumerWidget {
  const _ConSucursal({
    required this.sucursales,
    required this.sucursalId,
    required this.periodoIdSeleccionado,
    required this.momento,
    required this.onCambioSucursal,
    required this.onCambioPeriodo,
    required this.onCambioMomento,
  });

  final List<Sucursal> sucursales;
  final String sucursalId;
  final String? periodoIdSeleccionado;
  final MomentoPesaje momento;
  final ValueChanged<String> onCambioSucursal;
  final ValueChanged<String> onCambioPeriodo;
  final ValueChanged<MomentoPesaje> onCambioMomento;

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
              momento: momento,
              onCambioSucursal: onCambioSucursal,
              onCambioPeriodo: onCambioPeriodo,
              onCambioMomento: onCambioMomento,
            ),
            const Divider(height: 1),
            Expanded(
              child: periodo == null
                  ? const _SinPeriodo()
                  : PesajeSection(
                      periodo: periodo,
                      momento: momento,
                      editable: periodo.estado == EstadoPeriodo.abierto,
                    ),
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
}

class _Encabezado extends StatelessWidget {
  const _Encabezado({
    required this.sucursales,
    required this.sucursalId,
    required this.periodos,
    required this.periodo,
    required this.momento,
    required this.onCambioSucursal,
    required this.onCambioPeriodo,
    required this.onCambioMomento,
  });

  final List<Sucursal> sucursales;
  final String sucursalId;
  final List<Periodo> periodos;
  final Periodo? periodo;
  final MomentoPesaje momento;
  final ValueChanged<String> onCambioSucursal;
  final ValueChanged<String> onCambioPeriodo;
  final ValueChanged<MomentoPesaje> onCambioMomento;

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
            width: 300,
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
          SegmentedButton<MomentoPesaje>(
            segments: const [
              ButtonSegment(
                value: MomentoPesaje.apertura,
                label: Text('Apertura'),
                icon: Icon(Icons.login, size: 16),
              ),
              ButtonSegment(
                value: MomentoPesaje.cierre,
                label: Text('Cierre'),
                icon: Icon(Icons.logout, size: 16),
              ),
            ],
            selected: {momento},
            onSelectionChanged: (s) => onCambioMomento(s.first),
          ),
          if (periodo != null) _EstadoChip(estado: periodo!.estado),
        ],
      ),
    );
  }

  static String _labelPeriodo(Periodo p) =>
      '${Fmt.fecha(p.fechaInicio)} – ${Fmt.fecha(p.fechaFin)}';
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

class _SinPeriodo extends StatelessWidget {
  const _SinPeriodo();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_note, size: 56, color: AppColors.rojo),
          SizedBox(height: 12),
          Text('Esta sucursal todavía no tiene períodos.',
              style: TextStyle(fontSize: 16, color: AppColors.grisTexto)),
          SizedBox(height: 8),
          Text('Creá el período desde el módulo de Carga.',
              style: TextStyle(color: AppColors.grisTexto)),
        ],
      ),
    );
  }
}
