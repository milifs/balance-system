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

/// Cuadro de carga de ventas, siempre visible sobre la lista: una fila fija
/// por cada medio de pago activo (orden alfabético, sin combo). El usuario
/// solo tipea los montos y guarda todo junto con una fecha compartida.
class _VentaForm extends ConsumerStatefulWidget {
  const _VentaForm({required this.periodo, required this.medios});

  final Periodo periodo;
  final List<MedioPago> medios;

  @override
  ConsumerState<_VentaForm> createState() => _VentaFormState();
}

class _VentaFormState extends ConsumerState<_VentaForm> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _fecha;
  Map<String, TextEditingController> _montos = {};
  List<MedioPago> _ordenados = [];

  @override
  void initState() {
    super.initState();
    final hoy = DateTime.now();
    _fecha = hoy.isAfter(widget.periodo.fechaFin) ? widget.periodo.fechaFin : hoy;
    _ordenar();
  }

  @override
  void didUpdateWidget(_VentaForm old) {
    super.didUpdateWidget(old);
    final idsViejos = old.medios.map((m) => m.id).toSet();
    final idsNuevos = widget.medios.map((m) => m.id).toSet();
    if (idsViejos != idsNuevos) _ordenar();
  }

  void _ordenar() {
    for (final c in _montos.values) {
      c.dispose();
    }
    _ordenados = [...widget.medios]
      ..sort((a, b) =>
          a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));
    _montos = {
      for (final m in _ordenados) m.id: TextEditingController(),
    };
  }

  @override
  void dispose() {
    for (final c in _montos.values) {
      c.dispose();
    }
    super.dispose();
  }

  bool _guardando = false;

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
      await ref.read(cargaRepositoryProvider).agregarVentas(
            periodoId: widget.periodo.id,
            sucursalId: widget.periodo.sucursalId,
            fecha: _fecha,
            montosPorMedioPago: montos,
          );
      ref.invalidate(ventasProvider(widget.periodo.id));
      if (mounted) {
        for (final c in _montos.values) {
          c.clear();
        }
        setState(() => _guardando = false);
        mostrarMensaje(context,
            montos.length == 1 ? 'Venta agregada' : '${montos.length} ventas agregadas');
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
      titulo: 'Agregar ventas',
      formKey: _formKey,
      fecha: _fecha,
      onFecha: _elegirFecha,
      guardando: _guardando,
      onGuardar: _guardar,
      filas: [
        for (final m in _ordenados)
          CargaGridRow(
            etiqueta: m.nombre,
            subtitulo: m.retencionPct > 0
                ? 'Retención ${Fmt.pct(m.retencionPct)}'
                : null,
            controller: _montos[m.id]!,
          ),
      ],
    );
  }
}
