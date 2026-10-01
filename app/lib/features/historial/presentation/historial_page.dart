import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatters/formatters.dart';
import '../../../core/models/gasto.dart';
import '../../../core/models/medio_pago.dart';
import '../../../core/models/periodo.dart';
import '../../../core/models/sucursal.dart';
import '../../../core/models/tipo_gasto.dart';
import '../../../core/models/venta.dart';
import '../../../core/theme/app_theme.dart';
import '../../balance/application/balance_providers.dart';
import '../../carga/application/carga_providers.dart';
import '../../configuracion/application/configuracion_providers.dart';
import '../application/historial_providers.dart';

/// Módulo Historial (solo admin): lista de todos los períodos CERRADOS de las
/// 4 sucursales y permite consultar el balance de cualquiera de ellos.
/// Es solo lectura — reutiliza `fn_balance_periodo` vía `balancePeriodoProvider`.
class HistorialPage extends ConsumerStatefulWidget {
  const HistorialPage({super.key});

  @override
  ConsumerState<HistorialPage> createState() => _HistorialPageState();
}

class _HistorialPageState extends ConsumerState<HistorialPage> {
  String? _sucursalFiltro; // null = todas
  String? _periodoSel;

  @override
  Widget build(BuildContext context) {
    final cerradosAsync = ref.watch(periodosCerradosProvider);
    final sucursales =
        ref.watch(sucursalesProvider).asData?.value ?? const <Sucursal>[];
    final sucById = {for (final s in sucursales) s.id: s};

    return cerradosAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _error('Error al cargar el historial: $e'),
      data: (cerrados) {
        if (cerrados.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'Todavía no hay períodos cerrados.\n'
                'Cerrá un período desde el módulo Balance para verlo acá.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.grisTexto),
              ),
            ),
          );
        }

        final filtrados = _sucursalFiltro == null
            ? cerrados
            : cerrados.where((p) => p.sucursalId == _sucursalFiltro).toList();

        final seleccionado = _resolver(filtrados);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _BarraFiltro(
              sucursales: sucursales,
              sucursalId: _sucursalFiltro,
              total: filtrados.length,
              onCambio: (v) => setState(() {
                _sucursalFiltro = v;
                _periodoSel = null;
              }),
            ),
            const Divider(height: 1),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 340,
                    child: _ListaCerrados(
                      periodos: filtrados,
                      sucById: sucById,
                      seleccionadoId: seleccionado?.id,
                      onSeleccionar: (id) => setState(() => _periodoSel = id),
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(
                    child: seleccionado == null
                        ? const Center(
                            child: Text(
                              'Elegí un período de la lista.',
                              style: TextStyle(color: AppColors.grisTexto),
                            ),
                          )
                        : _DetalleHistorial(
                            periodo: seleccionado,
                            sucursal: sucById[seleccionado.sucursalId],
                          ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Periodo? _resolver(List<Periodo> periodos) {
    if (periodos.isEmpty) return null;
    for (final p in periodos) {
      if (p.id == _periodoSel) return p;
    }
    return periodos.first;
  }

  Widget _error(String msg) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child:
              Text(msg, style: const TextStyle(color: AppColors.rojoNegativo)),
        ),
      );
}

// =====================================================================
//  Barra de filtro por sucursal
// =====================================================================

class _BarraFiltro extends StatelessWidget {
  const _BarraFiltro({
    required this.sucursales,
    required this.sucursalId,
    required this.total,
    required this.onCambio,
  });

  final List<Sucursal> sucursales;
  final String? sucursalId;
  final int total;
  final ValueChanged<String?> onCambio;

  @override
  Widget build(BuildContext context) {
    final activas = sucursales.where((s) => s.activo).toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 260,
            child: DropdownButtonFormField<String?>(
              initialValue: sucursalId,
              decoration: const InputDecoration(
                  labelText: 'Sucursal', isDense: true),
              items: [
                const DropdownMenuItem<String?>(
                    value: null, child: Text('Todas las sucursales')),
                for (final s in activas)
                  DropdownMenuItem<String?>(value: s.id, child: Text(s.nombre)),
              ],
              onChanged: onCambio,
            ),
          ),
          Text(
            '$total período${total == 1 ? '' : 's'} cerrado${total == 1 ? '' : 's'}',
            style: const TextStyle(color: AppColors.grisTexto, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
//  Lista de períodos cerrados
// =====================================================================

class _ListaCerrados extends StatelessWidget {
  const _ListaCerrados({
    required this.periodos,
    required this.sucById,
    required this.seleccionadoId,
    required this.onSeleccionar,
  });

  final List<Periodo> periodos;
  final Map<String, Sucursal> sucById;
  final String? seleccionadoId;
  final ValueChanged<String> onSeleccionar;

  @override
  Widget build(BuildContext context) {
    if (periodos.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Sin períodos para esta sucursal.',
              style: TextStyle(color: AppColors.grisTexto)),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: periodos.length,
      separatorBuilder: (_, _) => const Divider(height: 1, indent: 16, endIndent: 16),
      itemBuilder: (_, i) {
        final p = periodos[i];
        final sel = p.id == seleccionadoId;
        final suc = sucById[p.sucursalId];
        return Material(
          color: sel ? AppColors.verde.withValues(alpha: 0.10) : null,
          child: ListTile(
            selected: sel,
            selectedTileColor: AppColors.verde.withValues(alpha: 0.10),
            leading: Icon(Icons.lock,
                size: 18,
                color: sel ? AppColors.verde : AppColors.grisTexto),
            title: Text(
              suc?.nombre ?? 'Sucursal',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${Fmt.fecha(p.fechaInicio)} – ${Fmt.fecha(p.fechaFin)}',
              style: const TextStyle(fontSize: 12.5),
            ),
            onTap: () => onSeleccionar(p.id),
          ),
        );
      },
    );
  }
}

// =====================================================================
//  Detalle del balance (solo lectura)
// =====================================================================

class _DetalleHistorial extends ConsumerWidget {
  const _DetalleHistorial({required this.periodo, required this.sucursal});

  final Periodo periodo;
  final Sucursal? sucursal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(balancePeriodoProvider(periodo.id));
    final ventas =
        ref.watch(ventasProvider(periodo.id)).asData?.value ?? const <Venta>[];
    final gastos =
        ref.watch(gastosProvider(periodo.id)).asData?.value ?? const <Gasto>[];
    final medios =
        ref.watch(mediosPagoProvider).asData?.value ?? const <MedioPago>[];
    final tipos =
        ref.watch(tiposGastoProvider).asData?.value ?? const <TipoGasto>[];

    return balanceAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Error al calcular el balance: $e',
              style: const TextStyle(color: AppColors.rojoNegativo)),
        ),
      ),
      data: (b) {
        final mediosById = {for (final m in medios) m.id: m};
        final tiposById = {for (final t in tipos) t.id: t};

        final brutoPorMedio = <String, double>{};
        for (final v in ventas) {
          brutoPorMedio[v.medioPagoId] =
              (brutoPorMedio[v.medioPagoId] ?? 0) + v.monto;
        }
        final filasMedio = brutoPorMedio.entries.toList()
          ..sort((a, b) => (mediosById[a.key]?.orden ?? 0)
              .compareTo(mediosById[b.key]?.orden ?? 0));

        final porTipo = <String, double>{};
        for (final g in gastos) {
          porTipo[g.tipoGastoId] = (porTipo[g.tipoGastoId] ?? 0) + g.monto;
        }
        final filasGasto = porTipo.entries.toList()
          ..sort((a, b) => (tiposById[a.key]?.orden ?? 0)
              .compareTo(tiposById[b.key]?.orden ?? 0));

        final gananciaPositiva = b.ganancia >= 0;
        final colorGanancia =
            gananciaPositiva ? AppColors.verde : AppColors.rojoNegativo;

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sucursal?.nombre ?? 'Sucursal',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.grisTexto),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${Fmt.fecha(periodo.fechaInicio)} – '
                        '${Fmt.fecha(periodo.fechaFin)}',
                        style: const TextStyle(
                            color: AppColors.grisTexto, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const Chip(
                  avatar: Icon(Icons.lock, size: 16, color: AppColors.grisTexto),
                  label: Text('Cerrado',
                      style: TextStyle(
                          color: AppColors.grisTexto,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Column(
                  children: [
                    const _FilaHeader(),
                    const Divider(),
                    for (final e in filasMedio)
                      Builder(builder: (_) {
                        final m = mediosById[e.key];
                        final ret = m?.retencionPct ?? 0;
                        final neto = e.value * (1 - ret / 100);
                        return _Fila(
                          label: m?.nombre ?? 'Medio desconocido',
                          bruto: Fmt.moneda(e.value),
                          neto: Fmt.moneda(neto),
                          indent: true,
                        );
                      }),
                    _Fila(
                      label: 'Total ventas',
                      bruto: Fmt.moneda(b.ventasBruto),
                      neto: Fmt.moneda(b.ventasNeto),
                      bold: true,
                    ),
                    const Divider(),
                    _Fila(
                        label: 'Compras proveedores',
                        bruto: Fmt.moneda(b.comprasTotal)),
                    _Fila(
                        label: 'Stock inicial',
                        bruto: Fmt.moneda(b.stockInicial)),
                    _Fila(
                        label: 'Stock final',
                        bruto: Fmt.moneda(b.stockFinal)),
                    _Fila(
                      label: 'CMV (stock inicial + compras − stock final)',
                      bruto: Fmt.moneda(b.cmv),
                      bold: true,
                    ),
                    const Divider(),
                    for (final e in filasGasto)
                      _Fila(
                        label: tiposById[e.key]?.nombre ?? 'Gasto',
                        bruto: Fmt.moneda(e.value),
                        indent: true,
                      ),
                    _Fila(
                      label: 'Total gastos',
                      bruto: Fmt.moneda(b.gastosTotal),
                      bold: true,
                    ),
                    const Divider(thickness: 1.2),
                    _Fila(
                      label: 'Ganancia (ventas netas − CMV − gastos)',
                      neto: Fmt.moneda(b.ganancia),
                      bold: true,
                      valueColor: colorGanancia,
                    ),
                    _Fila(
                      label: 'Utilidad neta %',
                      neto: Fmt.pct(b.utilidadNetaPct),
                      bold: true,
                      valueColor: colorGanancia,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FilaHeader extends StatelessWidget {
  const _FilaHeader();

  @override
  Widget build(BuildContext context) {
    const estilo = TextStyle(
        fontWeight: FontWeight.bold, color: AppColors.grisTexto, fontSize: 13);
    return const Row(
      children: [
        Expanded(child: Text('Concepto', style: estilo)),
        SizedBox(
            width: 150,
            child: Text('Bruto', style: estilo, textAlign: TextAlign.right)),
        SizedBox(
            width: 150,
            child: Text('Neto', style: estilo, textAlign: TextAlign.right)),
      ],
    );
  }
}

class _Fila extends StatelessWidget {
  const _Fila({
    required this.label,
    this.bruto,
    this.neto,
    this.bold = false,
    this.indent = false,
    this.valueColor,
  });

  final String label;
  final String? bruto;
  final String? neto;
  final bool bold;
  final bool indent;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final peso = bold ? FontWeight.bold : FontWeight.normal;
    final estiloLabel = TextStyle(
        fontWeight: peso,
        color: AppColors.grisTexto,
        fontSize: bold ? 14.5 : 14);
    final estiloValor = TextStyle(
        fontWeight: peso,
        color: valueColor ?? AppColors.grisTexto,
        fontSize: 14);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: indent ? 20 : 0),
              child: Text(label, style: estiloLabel),
            ),
          ),
          SizedBox(
            width: 150,
            child:
                Text(bruto ?? '', style: estiloValor, textAlign: TextAlign.right),
          ),
          SizedBox(
            width: 150,
            child:
                Text(neto ?? '', style: estiloValor, textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}
