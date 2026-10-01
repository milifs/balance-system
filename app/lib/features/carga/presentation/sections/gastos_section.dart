import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/formatters/formatters.dart';
import '../../../../core/models/gasto.dart';
import '../../../../core/models/periodo.dart';
import '../../../../core/models/tipo_gasto.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../configuracion/application/configuracion_providers.dart';
import '../../application/carga_providers.dart';
import '../widgets/carga_ui.dart';

/// Gastos operativos del período.
class GastosSection extends ConsumerWidget {
  const GastosSection(
      {super.key, required this.periodo, required this.editable});

  final Periodo periodo;
  final bool editable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gastosAsync = ref.watch(gastosProvider(periodo.id));
    final tiposAsync = ref.watch(tiposGastoProvider);

    final tipos = {
      for (final t in tiposAsync.asData?.value ?? const <TipoGasto>[])
        t.id: t,
    };
    final activos = tipos.values.where((t) => t.activo).toList();

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Gastos del período',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.grisTexto)),
          ),
        ),
        if (editable)
          activos.isEmpty
              ? const Padding(
                  padding: EdgeInsets.fromLTRB(20, 4, 20, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'No hay tipos de gasto activos. Configurá al menos uno '
                      'para cargar gastos.',
                      style: TextStyle(color: AppColors.grisTexto),
                    ),
                  ),
                )
              : _GastoForm(periodo: periodo, tipos: activos),
        Expanded(
          child: cargaListaAsync<Gasto>(
            value: gastosAsync,
            builder: (items) => ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final g = items[i];
                final tipo = tipos[g.tipoGastoId];
                return ListTile(
                  leading:
                      const Icon(Icons.receipt_long, color: AppColors.rojo),
                  title: Text(tipo?.nombre ?? 'Gasto'),
                  subtitle: Text(Fmt.fecha(g.fecha)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(Fmt.moneda(g.monto),
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      if (editable)
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Eliminar',
                          onPressed: () => _eliminar(context, ref, g, tipo),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        Builder(builder: (_) {
          final total = (gastosAsync.asData?.value ?? const <Gasto>[])
              .fold<double>(0, (s, g) => s + g.monto);
          return TotalFooter(etiqueta: 'Total gastos', total: total);
        }),
      ],
    );
  }

  Future<void> _eliminar(
      BuildContext context, WidgetRef ref, Gasto g, TipoGasto? tipo) async {
    final ok = await confirmarBorrado(
        context, 'el gasto de ${Fmt.moneda(g.monto)} (${tipo?.nombre ?? '—'})');
    if (!ok) return;
    try {
      await ref.read(cargaRepositoryProvider).eliminarGasto(g.id);
      ref.invalidate(gastosProvider(periodo.id));
    } catch (e) {
      if (context.mounted) {
        mostrarMensaje(context, 'No se pudo eliminar: $e', error: true);
      }
    }
  }
}

/// Cuadro de carga de gastos, siempre visible sobre la lista: una fila fija
/// por cada tipo de gasto activo (orden alfabético, sin combo). El usuario
/// solo tipea los montos y guarda todo junto con una fecha compartida.
class _GastoForm extends ConsumerStatefulWidget {
  const _GastoForm({required this.periodo, required this.tipos});

  final Periodo periodo;
  final List<TipoGasto> tipos;

  @override
  ConsumerState<_GastoForm> createState() => _GastoFormState();
}

class _GastoFormState extends ConsumerState<_GastoForm> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _fecha;
  Map<String, TextEditingController> _montos = {};
  List<TipoGasto> _ordenados = [];
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final hoy = DateTime.now();
    _fecha = hoy.isAfter(widget.periodo.fechaFin) ? widget.periodo.fechaFin : hoy;
    _ordenar();
  }

  @override
  void didUpdateWidget(_GastoForm old) {
    super.didUpdateWidget(old);
    final idsViejos = old.tipos.map((t) => t.id).toSet();
    final idsNuevos = widget.tipos.map((t) => t.id).toSet();
    if (idsViejos != idsNuevos) _ordenar();
  }

  void _ordenar() {
    for (final c in _montos.values) {
      c.dispose();
    }
    _ordenados = [...widget.tipos]
      ..sort((a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));
    _montos = {
      for (final t in _ordenados) t.id: TextEditingController(),
    };
  }

  @override
  void dispose() {
    for (final c in _montos.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _fecha = picked);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final montos = <String, double>{
      for (final e in _montos.entries)
        if (parseMonto(e.value.text) != null && parseMonto(e.value.text)! > 0)
          e.key: parseMonto(e.value.text)!,
    };
    if (montos.isEmpty) {
      mostrarMensaje(context, 'Ingresá al menos un monto.', error: true);
      return;
    }
    setState(() => _guardando = true);
    try {
      await ref.read(cargaRepositoryProvider).agregarGastos(
            periodoId: widget.periodo.id,
            sucursalId: widget.periodo.sucursalId,
            fecha: _fecha,
            montosPorTipoGasto: montos,
          );
      ref.invalidate(gastosProvider(widget.periodo.id));
      if (mounted) {
        for (final c in _montos.values) {
          c.clear();
        }
        setState(() => _guardando = false);
        mostrarMensaje(context,
            montos.length == 1 ? 'Gasto agregado' : '${montos.length} gastos agregados');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _guardando = false);
        mostrarMensaje(context, 'No se pudo guardar: $e', error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CargaGridPanel(
      titulo: 'Agregar gastos',
      formKey: _formKey,
      fecha: _fecha,
      onFecha: _elegirFecha,
      guardando: _guardando,
      onGuardar: _guardar,
      filas: [
        for (final t in _ordenados)
          CargaGridRow(etiqueta: t.nombre, controller: _montos[t.id]!),
      ],
    );
  }
}
