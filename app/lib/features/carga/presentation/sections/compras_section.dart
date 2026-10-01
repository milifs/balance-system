import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/formatters/formatters.dart';
import '../../../../core/models/compra.dart';
import '../../../../core/models/periodo.dart';
import '../../../../core/theme/app_theme.dart';
import '../../application/carga_providers.dart';
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

/// Cuadro de carga de compra, siempre visible sobre la lista.
class _CompraForm extends ConsumerStatefulWidget {
  const _CompraForm({required this.periodo});

  final Periodo periodo;

  @override
  ConsumerState<_CompraForm> createState() => _CompraFormState();
}

class _CompraFormState extends ConsumerState<_CompraForm> {
  final _formKey = GlobalKey<FormState>();
  final _monto = TextEditingController();
  final _proveedor = TextEditingController();
  late DateTime _fecha;
  TipoCompra _tipo = TipoCompra.carne;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final hoy = DateTime.now();
    _fecha = hoy.isAfter(widget.periodo.fechaFin) ? widget.periodo.fechaFin : hoy;
  }

  @override
  void dispose() {
    _monto.dispose();
    _proveedor.dispose();
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
      final prov = _proveedor.text.trim();
      await ref.read(cargaRepositoryProvider).agregarCompra(
            periodoId: widget.periodo.id,
            sucursalId: widget.periodo.sucursalId,
            fecha: _fecha,
            tipoCompra: _tipo,
            monto: parseMonto(_monto.text)!,
            proveedor: prov.isEmpty ? null : prov,
          );
      ref.invalidate(comprasProvider(widget.periodo.id));
      if (mounted) {
        _monto.clear();
        _proveedor.clear();
        setState(() => _guardando = false);
        mostrarMensaje(context, 'Compra agregada');
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
    return CargaFormPanel(
      titulo: 'Agregar compra',
      formKey: _formKey,
      guardando: _guardando,
      onGuardar: _guardar,
      campos: [
        SizedBox(
          width: 180,
          child: DropdownButtonFormField<TipoCompra>(
            initialValue: _tipo,
            isExpanded: true,
            decoration: const InputDecoration(
                labelText: 'Tipo de compra', isDense: true),
            items: [
              for (final t in TipoCompra.values)
                DropdownMenuItem(value: t, child: Text(t.label)),
            ],
            onChanged: (v) => setState(() => _tipo = v ?? _tipo),
          ),
        ),
        SizedBox(
          width: 160,
          child: TextFormField(
            controller: _monto,
            decoration: const InputDecoration(
                labelText: 'Monto', prefixText: r'$ ', isDense: true),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) {
              final n = parseMonto(v ?? '');
              if (n == null) return 'Monto inválido';
              if (n < 0) return 'No puede ser negativo';
              return null;
            },
          ),
        ),
        SizedBox(
          width: 200,
          child: TextFormField(
            controller: _proveedor,
            decoration: const InputDecoration(
                labelText: 'Proveedor (opcional)', isDense: true),
            onFieldSubmitted: (_) => _guardar(),
          ),
        ),
        FechaField(fecha: _fecha, onTap: _elegirFecha),
      ],
    );
  }
}
