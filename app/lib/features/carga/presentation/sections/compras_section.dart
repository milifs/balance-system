import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/formatters/formatters.dart';
import '../../../../core/models/compra.dart';
import '../../../../core/models/periodo.dart';
import '../../../../core/theme/app_theme.dart';
import '../../application/carga_providers.dart';
import '../../data/carga_repository.dart';
import '../widgets/carga_ui.dart';

/// Compras a proveedores del período.
class ComprasSection extends ConsumerWidget {
  const ComprasSection(
      {super.key, required this.periodo, required this.editable});

  final Periodo periodo;
  final bool editable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comprasAsync = ref.watch(comprasProvider(periodo.id));

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Compras a proveedores',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.grisTexto)),
          ),
        ),
        if (editable) _CompraForm(periodo: periodo),
        Expanded(
          child: cargaListaAsync<Compra>(
            value: comprasAsync,
            builder: (items) => ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final c = items[i];
                final prov = (c.proveedor ?? '').trim();
                return ListTile(
                  leading:
                      const Icon(Icons.local_shipping, color: AppColors.rojo),
                  title: Text(c.tipoCompra.label),
                  subtitle: Text(
                    '${Fmt.fecha(c.fecha)}${prov.isEmpty ? '' : ' · $prov'}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(Fmt.moneda(c.monto),
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      if (editable)
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Eliminar',
                          onPressed: () => _eliminar(context, ref, c),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        Builder(builder: (_) {
          final total = (comprasAsync.asData?.value ?? const <Compra>[])
              .fold<double>(0, (s, c) => s + c.monto);
          return TotalFooter(etiqueta: 'Total compras', total: total);
        }),
      ],
    );
  }

  Future<void> _eliminar(
      BuildContext context, WidgetRef ref, Compra c) async {
    final ok = await confirmarBorrado(context,
        'la compra de ${c.tipoCompra.label} por ${Fmt.moneda(c.monto)}');
    if (!ok) return;
    try {
      await ref.read(cargaRepositoryProvider).eliminarCompra(c.id);
      ref.invalidate(comprasProvider(periodo.id));
    } catch (e) {
      if (context.mounted) {
        mostrarMensaje(context, 'No se pudo eliminar: $e', error: true);
      }
    }
  }
}

/// Cuadro de carga de compras, siempre visible sobre la lista: una fila fija
/// por cada tipo de carne (orden alfabético: Carne, Cerdo, Pollo — sin
/// combo). El usuario tipea el monto (y opcionalmente el proveedor) y
/// guarda todo junto con una fecha compartida.
class _CompraForm extends ConsumerStatefulWidget {
  const _CompraForm({required this.periodo});

  final Periodo periodo;

  @override
  ConsumerState<_CompraForm> createState() => _CompraFormState();
}

class _CompraFormState extends ConsumerState<_CompraForm> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _fecha;
  bool _guardando = false;

  static final _tipos = [...TipoCompra.values]
    ..sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));

  final Map<TipoCompra, TextEditingController> _montos = {
    for (final t in _tipos) t: TextEditingController(),
  };
  final Map<TipoCompra, TextEditingController> _proveedores = {
    for (final t in _tipos) t: TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    final hoy = DateTime.now();
    _fecha = hoy.isAfter(widget.periodo.fechaFin) ? widget.periodo.fechaFin : hoy;
  }

  @override
  void dispose() {
    for (final c in _montos.values) {
      c.dispose();
    }
    for (final c in _proveedores.values) {
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
    final filas = <FilaCompra>[
      for (final t in _tipos)
        if (parseMonto(_montos[t]!.text) != null && parseMonto(_montos[t]!.text)! > 0)
          FilaCompra(
            tipo: t,
            monto: parseMonto(_montos[t]!.text)!,
            proveedor: _proveedores[t]!.text.trim().isEmpty
                ? null
                : _proveedores[t]!.text.trim(),
          ),
    ];
    if (filas.isEmpty) {
      mostrarMensaje(context, 'Ingresá al menos un monto.', error: true);
      return;
    }
    setState(() => _guardando = true);
    try {
      await ref.read(cargaRepositoryProvider).agregarCompras(
            periodoId: widget.periodo.id,
            sucursalId: widget.periodo.sucursalId,
            fecha: _fecha,
            filas: filas,
          );
      ref.invalidate(comprasProvider(widget.periodo.id));
      if (mounted) {
        for (final c in _montos.values) {
          c.clear();
        }
        for (final c in _proveedores.values) {
          c.clear();
        }
        setState(() => _guardando = false);
        mostrarMensaje(context,
            filas.length == 1 ? 'Compra agregada' : '${filas.length} compras agregadas');
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
      titulo: 'Agregar compras',
      formKey: _formKey,
      fecha: _fecha,
      onFecha: _elegirFecha,
      guardando: _guardando,
      onGuardar: _guardar,
      filas: [
        for (final t in _tipos)
          CargaGridRow(
            etiqueta: t.label,
            controller: _montos[t]!,
            extra: TextFormField(
              controller: _proveedores[t]!,
              decoration: const InputDecoration(
                  labelText: 'Proveedor (opcional)', isDense: true),
            ),
          ),
      ],
    );
  }
}
