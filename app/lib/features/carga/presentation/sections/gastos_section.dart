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

/// Cuadro de carga de gasto, siempre visible sobre la lista.
class _GastoForm extends ConsumerStatefulWidget {
  const _GastoForm({required this.periodo, required this.tipos});

  final Periodo periodo;
  final List<TipoGasto> tipos;

  @override
  ConsumerState<_GastoForm> createState() => _GastoFormState();
}

class _GastoFormState extends ConsumerState<_GastoForm> {
  final _formKey = GlobalKey<FormState>();
  final _monto = TextEditingController();
  late DateTime _fecha;
  String? _tipoGastoId;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final hoy = DateTime.now();
    _fecha = hoy.isAfter(widget.periodo.fechaFin) ? widget.periodo.fechaFin : hoy;
    _tipoGastoId = widget.tipos.first.id;
  }

  @override
  void dispose() {
    _monto.dispose();
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
    setState(() => _guardando = true);
    try {
      await ref.read(cargaRepositoryProvider).agregarGasto(
            periodoId: widget.periodo.id,
            sucursalId: widget.periodo.sucursalId,
            fecha: _fecha,
            tipoGastoId: _tipoGastoId!,
            monto: parseMonto(_monto.text)!,
          );
      ref.invalidate(gastosProvider(widget.periodo.id));
      if (mounted) {
        _monto.clear();
        setState(() => _guardando = false);
        mostrarMensaje(context, 'Gasto agregado');
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
    final existe = widget.tipos.any((t) => t.id == _tipoGastoId);
    final tipoSel = existe ? _tipoGastoId : widget.tipos.first.id;
    return CargaFormPanel(
      titulo: 'Agregar gasto',
      formKey: _formKey,
      guardando: _guardando,
      onGuardar: _guardar,
      campos: [
        SizedBox(
          width: 220,
          child: DropdownButtonFormField<String>(
            initialValue: tipoSel,
            isExpanded: true,
            decoration: const InputDecoration(
                labelText: 'Tipo de gasto', isDense: true),
            items: [
              for (final t in widget.tipos)
                DropdownMenuItem(value: t.id, child: Text(t.nombre)),
            ],
            onChanged: (v) => setState(() => _tipoGastoId = v),
            validator: (v) => v == null ? 'Elegí un tipo' : null,
          ),
        ),
        SizedBox(
          width: 160,
          child: TextFormField(
            controller: _monto,
            decoration: const InputDecoration(
                labelText: 'Monto', prefixText: r'$ ', isDense: true),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onFieldSubmitted: (_) => _guardar(),
            validator: (v) {
              final n = parseMonto(v ?? '');
              if (n == null) return 'Monto inválido';
              if (n < 0) return 'No puede ser negativo';
              return null;
            },
          ),
        ),
        FechaField(fecha: _fecha, onTap: _elegirFecha),
      ],
    );
  }
}
