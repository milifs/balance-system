import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/formatters/formatters.dart';
import '../../../../core/models/compra.dart';
import '../../../../core/models/periodo.dart';
import '../../../../core/models/tipo_compra.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../configuracion/application/configuracion_providers.dart';
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
    final tiposAsync = ref.watch(tiposCompraProvider);
    final activos = (tiposAsync.asData?.value ?? const <TipoCompra>[])
        .where((t) => t.activo)
        .toList();

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
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (editable)
                  activos.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.fromLTRB(20, 4, 20, 8),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'No hay tipos de compra activos. Configurá al '
                              'menos uno para cargar compras.',
                              style: TextStyle(color: AppColors.grisTexto),
                            ),
                          ),
                        )
                      : _CompraForm(periodo: periodo, tipos: activos),
                cargaListaAsync<Compra>(
                  value: comprasAsync,
                  builder: (items) => ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final c = items[i];
                      final prov = (c.proveedor ?? '').trim();
                      return ListTile(
                        leading: const Icon(Icons.local_shipping,
                            color: AppColors.rojo),
                        title: Text(c.tipoCompra),
                        subtitle: Text(
                          '${Fmt.fecha(c.fecha)}${prov.isEmpty ? '' : ' · $prov'}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(Fmt.moneda(c.monto),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
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
              ],
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
        'la compra de ${c.tipoCompra} por ${Fmt.moneda(c.monto)}');
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
/// por cada tipo de compra activo (orden alfabético, sin combo). El usuario
/// tipea el monto (y opcionalmente el proveedor) y guarda todo junto con una
/// fecha compartida.
class _CompraForm extends ConsumerStatefulWidget {
  const _CompraForm({required this.periodo, required this.tipos});

  final Periodo periodo;
  final List<TipoCompra> tipos;

  @override
  ConsumerState<_CompraForm> createState() => _CompraFormState();
}

class _CompraFormState extends ConsumerState<_CompraForm> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _fecha;
  List<TipoCompra> _ordenados = [];
  Map<String, TextEditingController> _montos = {};
  Map<String, TextEditingController> _proveedores = {};
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _fecha = fechaDentroDelPeriodo(widget.periodo, DateTime.now());
    _ordenar();
  }

  @override
  void didUpdateWidget(_CompraForm old) {
    super.didUpdateWidget(old);
    final idsViejos = old.tipos.map((t) => t.id).toSet();
    final idsNuevos = widget.tipos.map((t) => t.id).toSet();
    if (idsViejos != idsNuevos) _ordenar();
  }

  void _ordenar() {
    for (final c in _montos.values) {
      c.dispose();
    }
    for (final c in _proveedores.values) {
      c.dispose();
    }
    _ordenados = [...widget.tipos]
      ..sort((a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));
    _montos = {
      for (final t in _ordenados) t.id: TextEditingController(),
    };
    _proveedores = {
      for (final t in _ordenados) t.id: TextEditingController(),
    };
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
      firstDate: widget.periodo.fechaInicio,
      lastDate: widget.periodo.fechaFin,
    );
    if (picked != null) setState(() => _fecha = picked);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final filas = <FilaCompra>[
      for (final t in _ordenados)
        if (parseMonto(_montos[t.id]!.text) != null &&
            parseMonto(_montos[t.id]!.text)! > 0)
          FilaCompra(
            tipo: t.nombre,
            monto: parseMonto(_montos[t.id]!.text)!,
            proveedor: _proveedores[t.id]!.text.trim().isEmpty
                ? null
                : _proveedores[t.id]!.text.trim(),
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
        for (final t in _ordenados)
          CargaGridRow(
            etiqueta: t.nombre,
            controller: _montos[t.id]!,
            extra: TextFormField(
              controller: _proveedores[t.id]!,
              decoration: const InputDecoration(
                  labelText: 'Proveedor (opcional)', isDense: true),
            ),
          ),
      ],
    );
  }
}
