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
import '../../carga/application/carga_providers.dart';
import '../../configuracion/application/configuracion_providers.dart';
import '../application/balance_providers.dart';

/// Módulo de Balance (solo admin): resultado por sucursal en un período
/// (bruto/neto, CMV, ganancia, utilidad %) y consolidado de las 4 sucursales.
class BalancePage extends ConsumerStatefulWidget {
  const BalancePage({super.key});

  @override
  ConsumerState<BalancePage> createState() => _BalancePageState();
}

class _BalancePageState extends ConsumerState<BalancePage> {
  String? _sucursalId;
  String? _periodoId;
  late DateTime _consolIni;
  late DateTime _consolFin;

  @override
  void initState() {
    super.initState();
    final hoy = DateTime.now();
    _consolIni = DateTime(hoy.year, hoy.month, 1);
    _consolFin = hoy;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Material(
            color: AppColors.crema,
            child: TabBar(
              tabs: [
                Tab(text: 'Por sucursal'),
                Tab(text: 'Consolidado'),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: TabBarView(
              children: [
                _PorSucursalTab(
                  sucursalId: _sucursalId,
                  periodoId: _periodoId,
                  onCambioSucursal: (id) => setState(() {
                    _sucursalId = id;
                    _periodoId = null;
                  }),
                  onCambioPeriodo: (id) => setState(() => _periodoId = id),
                ),
                _ConsolidadoTab(
                  ini: _consolIni,
                  fin: _consolFin,
                  onCambioRango: (i, f) => setState(() {
                    _consolIni = i;
                    _consolFin = f;
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
//  TAB 1 — Balance por sucursal
// =====================================================================

class _PorSucursalTab extends ConsumerWidget {
  const _PorSucursalTab({
    required this.sucursalId,
    required this.periodoId,
    required this.onCambioSucursal,
    required this.onCambioPeriodo,
  });

  final String? sucursalId;
  final String? periodoId;
  final ValueChanged<String> onCambioSucursal;
  final ValueChanged<String> onCambioPeriodo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sucursalesAsync = ref.watch(sucursalesProvider);

    return sucursalesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _error('Error al cargar sucursales: $e'),
      data: (sucursales) {
        final activas = sucursales.where((s) => s.activo).toList();
        if (activas.isEmpty) {
          return const Center(child: Text('No hay sucursales configuradas.'));
        }
        final sucId = sucursalId ?? activas.first.id;
        final periodosAsync = ref.watch(periodosProvider(sucId));

        return periodosAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _error('Error al cargar períodos: $e'),
          data: (periodos) {
            final periodo = _resolver(periodos);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Encabezado(
                  sucursales: activas,
                  sucursalId: sucId,
                  periodos: periodos,
                  periodo: periodo,
                  onCambioSucursal: onCambioSucursal,
                  onCambioPeriodo: onCambioPeriodo,
                ),
                const Divider(height: 1),
                Expanded(
                  child: periodo == null
                      ? const Center(
                          child: Text(
                            'Esta sucursal no tiene períodos para balancear.',
                            style: TextStyle(color: AppColors.grisTexto),
                          ),
                        )
                      : _BalanceDetalle(periodo: periodo),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Periodo? _resolver(List<Periodo> periodos) {
    if (periodos.isEmpty) return null;
    for (final p in periodos) {
      if (p.id == periodoId) return p;
    }
    return periodos.first;
  }

  Widget _error(String msg) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(msg,
              style: const TextStyle(color: AppColors.rojoNegativo)),
        ),
      );
}

class _Encabezado extends StatelessWidget {
  const _Encabezado({
    required this.sucursales,
    required this.sucursalId,
    required this.periodos,
    required this.periodo,
    required this.onCambioSucursal,
    required this.onCambioPeriodo,
  });

  final List<Sucursal> sucursales;
  final String sucursalId;
  final List<Periodo> periodos;
  final Periodo? periodo;
  final ValueChanged<String> onCambioSucursal;
  final ValueChanged<String> onCambioPeriodo;

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
              decoration:
                  const InputDecoration(labelText: 'Sucursal', isDense: true),
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
              decoration:
                  const InputDecoration(labelText: 'Período', isDense: true),
              hint: const Text('Sin períodos'),
              items: [
                for (final p in periodos)
                  DropdownMenuItem(value: p.id, child: Text(_label(p))),
              ],
              onChanged: periodos.isEmpty
                  ? null
                  : (v) {
                      if (v != null) onCambioPeriodo(v);
                    },
            ),
          ),
          if (periodo != null) _EstadoChip(estado: periodo!.estado),
        ],
      ),
    );
  }

  static String _label(Periodo p) =>
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
      avatar: Icon(abierto ? Icons.lock_open : Icons.lock, size: 16, color: color),
      label: Text(abierto ? 'Abierto' : 'Cerrado',
          style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      backgroundColor: color.withValues(alpha: 0.10),
      side: BorderSide(color: color.withValues(alpha: 0.30)),
    );
  }
}

/// Detalle del balance de un período: tabla bruto/neto + cierre.
class _BalanceDetalle extends ConsumerWidget {
  const _BalanceDetalle({required this.periodo});

  final Periodo periodo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(balancePeriodoProvider(periodo.id));
    final ventas = ref.watch(ventasProvider(periodo.id)).asData?.value ??
        const <Venta>[];
    final gastos = ref.watch(gastosProvider(periodo.id)).asData?.value ??
        const <Gasto>[];
    final medios = ref.watch(mediosPagoProvider).asData?.value ??
        const <MedioPago>[];
    final tipos = ref.watch(tiposGastoProvider).asData?.value ??
        const <TipoGasto>[];

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

        // Ventas agrupadas por medio (bruto + neto).
        final brutoPorMedio = <String, double>{};
        for (final v in ventas) {
          brutoPorMedio[v.medioPagoId] =
              (brutoPorMedio[v.medioPagoId] ?? 0) + v.monto;
        }
        final filasMedio = brutoPorMedio.entries.toList()
          ..sort((a, b) => (mediosById[a.key]?.orden ?? 0)
              .compareTo(mediosById[b.key]?.orden ?? 0));

        // Gastos agrupados por tipo.
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
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Column(
                  children: [
                    const _FilaHeader(),
                    const Divider(),

                    // --- Ventas por medio ---
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

                    // --- Compras y stock ---
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

                    // --- Gastos ---
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

                    // --- Resultado ---
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
            const SizedBox(height: 16),
            _AccionCierre(periodo: periodo),
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
        fontWeight: peso, color: valueColor ?? AppColors.grisTexto, fontSize: 14);
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
            child: Text(bruto ?? '', style: estiloValor, textAlign: TextAlign.right),
          ),
          SizedBox(
            width: 150,
            child: Text(neto ?? '', style: estiloValor, textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}

class _AccionCierre extends ConsumerStatefulWidget {
  const _AccionCierre({required this.periodo});

  final Periodo periodo;

  @override
  ConsumerState<_AccionCierre> createState() => _AccionCierreState();
}

class _AccionCierreState extends ConsumerState<_AccionCierre> {
  bool _procesando = false;

  Future<void> _cambiar({required bool cerrar}) async {
    final p = widget.periodo;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(cerrar ? 'Cerrar período' : 'Reabrir período'),
        content: Text(cerrar
            ? 'Al cerrar, el período pasa a solo lectura y queda en el '
                'historial. Podés reabrirlo después. ¿Cerrar?'
            : 'El período volverá a ser editable. ¿Reabrir?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: cerrar
                ? null
                : FilledButton.styleFrom(backgroundColor: AppColors.grisTexto),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(cerrar ? 'Cerrar período' : 'Reabrir'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => _procesando = true);
    try {
      final repo = ref.read(balanceRepositoryProvider);
      if (cerrar) {
        await repo.cerrarPeriodo(p.id);
      } else {
        await repo.reabrirPeriodo(p.id);
      }
      ref.invalidate(periodosProvider(p.sucursalId));
      ref.invalidate(balancePeriodoProvider(p.id));
      if (mounted) {
        setState(() => _procesando = false);
        _snack(cerrar ? 'Período cerrado' : 'Período reabierto');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _procesando = false);
        _snack('No se pudo: $e', error: true);
      }
    }
  }

  void _snack(String texto, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(texto),
        backgroundColor: error ? AppColors.rojoNegativo : AppColors.verde,
      ));
  }

  @override
  Widget build(BuildContext context) {
    final abierto = widget.periodo.estado == EstadoPeriodo.abierto;
    return Align(
      alignment: Alignment.centerRight,
      child: abierto
          ? FilledButton.icon(
              onPressed: _procesando ? null : () => _cambiar(cerrar: true),
              icon: _procesando
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.lock),
              label: const Text('Cerrar período'),
            )
          : OutlinedButton.icon(
              onPressed: _procesando ? null : () => _cambiar(cerrar: false),
              icon: const Icon(Icons.lock_open),
              label: const Text('Reabrir período'),
            ),
    );
  }
}

// =====================================================================
//  TAB 2 — Consolidado
// =====================================================================

class _ConsolidadoTab extends ConsumerWidget {
  const _ConsolidadoTab({
    required this.ini,
    required this.fin,
    required this.onCambioRango,
  });

  final DateTime ini;
  final DateTime fin;
  final void Function(DateTime ini, DateTime fin) onCambioRango;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consolidadoAsync =
        ref.watch(consolidadoProvider((ini: ini, fin: fin)));

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _FechaBoton(
              label: 'Desde',
              fecha: ini,
              onTap: () => _elegir(context, ini, (d) => onCambioRango(d, fin)),
            ),
            _FechaBoton(
              label: 'Hasta',
              fecha: fin,
              onTap: () => _elegir(context, fin, (d) => onCambioRango(ini, d)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Suma de los períodos CERRADOS de las 4 sucursales cuya fecha de '
          'fin cae en el rango.',
          style: TextStyle(color: AppColors.grisTexto, fontSize: 13),
        ),
        const SizedBox(height: 16),
        consolidadoAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Text('Error al consolidar: $e',
              style: const TextStyle(color: AppColors.rojoNegativo)),
          data: (c) {
            final positiva = c.ganancia >= 0;
            final color = positiva ? AppColors.verde : AppColors.rojoNegativo;
            final utilidad =
                c.ventasNeto == 0 ? 0.0 : c.ganancia / c.ventasNeto * 100;
            return Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Column(
                  children: [
                    _FilaConsol(label: 'Ventas brutas', valor: Fmt.moneda(c.ventasBruto)),
                    _FilaConsol(label: 'Ventas netas', valor: Fmt.moneda(c.ventasNeto)),
                    _FilaConsol(label: 'Compras proveedores', valor: Fmt.moneda(c.comprasTotal)),
                    _FilaConsol(label: 'CMV', valor: Fmt.moneda(c.cmv)),
                    _FilaConsol(label: 'Gastos', valor: Fmt.moneda(c.gastosTotal)),
                    const Divider(thickness: 1.2),
                    _FilaConsol(
                        label: 'Ganancia consolidada',
                        valor: Fmt.moneda(c.ganancia),
                        bold: true,
                        color: color),
                    _FilaConsol(
                        label: 'Utilidad neta %',
                        valor: Fmt.pct(utilidad),
                        bold: true,
                        color: color),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _elegir(BuildContext context, DateTime inicial,
      ValueChanged<DateTime> onPick) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) onPick(picked);
  }
}

class _FechaBoton extends StatelessWidget {
  const _FechaBoton(
      {required this.label, required this.fecha, required this.onTap});

  final String label;
  final DateTime fecha;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            isDense: true,
            suffixIcon: const Icon(Icons.calendar_today, size: 18),
          ),
          child: Text(Fmt.fecha(fecha)),
        ),
      ),
    );
  }
}

class _FilaConsol extends StatelessWidget {
  const _FilaConsol({
    required this.label,
    required this.valor,
    this.bold = false,
    this.color,
  });

  final String label;
  final String valor;
  final bool bold;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final peso = bold ? FontWeight.bold : FontWeight.normal;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontWeight: peso,
                    color: AppColors.grisTexto,
                    fontSize: bold ? 14.5 : 14)),
          ),
          SizedBox(
            width: 170,
            child: Text(valor,
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontWeight: peso,
                    color: color ?? AppColors.grisTexto,
                    fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
