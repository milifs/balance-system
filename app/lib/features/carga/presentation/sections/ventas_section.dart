import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/formatters/formatters.dart';
import '../../../../core/models/medio_pago.dart';
import '../../../../core/models/periodo.dart';
import '../../../../core/models/venta.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../configuracion/application/configuracion_providers.dart';
import '../../application/carga_providers.dart';
import '../widgets/carga_ui.dart';

/// Ventas del período por medio de pago.
class VentasSection extends ConsumerWidget {
  const VentasSection({super.key, required this.periodo, required this.editable});

  final Periodo periodo;
  final bool editable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ventasAsync = ref.watch(ventasProvider(periodo.id));
    final mediosAsync = ref.watch(mediosPagoProvider);

    final medios = {
      for (final m in mediosAsync.asData?.value ?? const <MedioPago>[])
        m.id: m,
    };
    final activos = medios.values.where((m) => m.activo).toList();

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Ventas por medio de pago',
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
                      'No hay medios de pago activos. Configurá al menos uno '
                      'para cargar ventas.',
                      style: TextStyle(color: AppColors.grisTexto),
                    ),
                  ),
                )
              : _VentaForm(periodo: periodo, medios: activos),
        Expanded(
          child: cargaListaAsync<Venta>(
            value: ventasAsync,
            builder: (items) => ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final v = items[i];
                final medio = medios[v.medioPagoId];
                final bruto = v.monto;
                final ret = medio?.retencionPct ?? 0;
                final neto = bruto * (1 - ret / 100);
                return ListTile(
                  leading: const Icon(Icons.point_of_sale, color: AppColors.rojo),
                  title: Text(medio?.nombre ?? 'Medio desconocido'),
                  subtitle: Text(
                    '${Fmt.fecha(v.fecha)}'
                    '${ret > 0 ? ' · retención ${Fmt.pct(ret)} → neto ${Fmt.moneda(neto)}' : ''}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(Fmt.moneda(bruto),
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      if (editable)
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Eliminar',
                          onPressed: () => _eliminar(context, ref, v, medio),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        Builder(builder: (_) {
          final total = (ventasAsync.asData?.value ?? const <Venta>[])
              .fold<double>(0, (s, v) => s + v.monto);
          return TotalFooter(etiqueta: 'Total ventas (bruto)', total: total);
        }),
      ],
    );
  }

  Future<void> _eliminar(
      BuildContext context, WidgetRef ref, Venta v, MedioPago? medio) async {
    final ok = await confirmarBorrado(
        context, 'la venta de ${Fmt.moneda(v.monto)} (${medio?.nombre ?? '—'})');
    if (!ok) return;
    try {
      await ref.read(cargaRepositoryProvider).eliminarVenta(v.id);
      ref.invalidate(ventasProvider(periodo.id));
    } catch (e) {
      if (context.mounted) {
        mostrarMensaje(context, 'No se pudo eliminar: $e', error: true);
      }
    }
  }
}

/// Cuadro de carga de venta, siempre visible sobre la lista.
class _VentaForm extends ConsumerStatefulWidget {
  const _VentaForm({required this.periodo, required this.medios});

  final Periodo periodo;
  final List<MedioPago> medios;

  @override
  ConsumerState<_VentaForm> createState() => _VentaFormState();
}

class _VentaFormState extends ConsumerState<_VentaForm> {
  final _formKey = GlobalKey<FormState>();
  final _monto = TextEditingController();
  late DateTime _fecha;
  String? _medioPagoId;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final hoy = DateTime.now();
    _fecha = hoy.isAfter(widget.periodo.fechaFin) ? widget.periodo.fechaFin : hoy;
    _medioPagoId = widget.medios.first.id;
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
      await ref.read(cargaRepositoryProvider).agregarVenta(
            periodoId: widget.periodo.id,
            sucursalId: widget.periodo.sucursalId,
            fecha: _fecha,
            medioPagoId: _medioPagoId!,
            monto: parseMonto(_monto.text)!,
          );
      ref.invalidate(ventasProvider(widget.periodo.id));
      if (mounted) {
        _monto.clear();
        setState(() => _guardando = false);
        mostrarMensaje(context, 'Venta agregada');
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
    final existe = widget.medios.any((m) => m.id == _medioPagoId);
    final medioSel = existe ? _medioPagoId : widget.medios.first.id;
    return CargaFormPanel(
      titulo: 'Agregar venta',
      formKey: _formKey,
      guardando: _guardando,
      onGuardar: _guardar,
      campos: [
        SizedBox(
          width: 220,
          child: DropdownButtonFormField<String>(
            initialValue: medioSel,
            isExpanded: true,
            decoration: const InputDecoration(
                labelText: 'Medio de pago', isDense: true),
            items: [
              for (final m in widget.medios)
                DropdownMenuItem(
                  value: m.id,
                  child: Text(m.retencionPct > 0
                      ? '${m.nombre} (ret. ${Fmt.pct(m.retencionPct)})'
                      : m.nombre),
                ),
            ],
            onChanged: (v) => setState(() => _medioPagoId = v),
            validator: (v) => v == null ? 'Elegí un medio' : null,
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
