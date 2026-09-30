import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/formatters/formatters.dart';
import '../../../../core/models/categoria.dart';
import '../../../../core/models/corte.dart';
import '../../application/configuracion_providers.dart';
import '../widgets/section_scaffold.dart';

class CortesSection extends ConsumerWidget {
  const CortesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cortesValue = ref.watch(cortesProvider);
    final categoriasValue = ref.watch(categoriasProvider);

    final categorias = categoriasValue.asData?.value ?? const <Categoria>[];

    return SectionScaffold(
      titulo: 'Cortes',
      descripcion:
          'Cortes por categoría con su KGR (kilos de rinde). Los cortes '
          'individuales se valorizan a precio de venta; las piezas enteras, a '
          'costo manual.',
      textoAgregar: 'Nuevo corte',
      onAgregar: categorias.isEmpty
          ? null
          : () => _editar(context, ref, categorias),
      child: listaAsync<Corte>(
        value: cortesValue,
        builder: (cortes) {
          return ListView(
            children: [
              for (final cat in categorias)
                _grupoCategoria(context, ref, cat, cortes, categorias),
            ],
          );
        },
      ),
    );
  }

  Widget _grupoCategoria(BuildContext context, WidgetRef ref, Categoria cat,
      List<Corte> todos, List<Categoria> categorias) {
    final delGrupo = todos.where((c) => c.categoriaId == cat.id).toList();
    return ExpansionTile(
      initiallyExpanded: true,
      title: Text('${cat.nombre}  (${delGrupo.length})',
          style: const TextStyle(fontWeight: FontWeight.bold)),
      children: [
        for (final c in delGrupo)
          ListTile(
            dense: true,
            leading: Icon(
              c.valorizaA == ValorizaA.costo ? Icons.inventory_2 : Icons.sell,
              size: 20,
              color: c.activo ? null : Colors.grey,
            ),
            title: Text(c.nombre),
            subtitle: Text(
              'KGR: ${Fmt.kg(c.kgrRinde)}   ·   '
              '${c.valorizaA == ValorizaA.costo ? 'Costo' : 'Venta'}'
              '${c.costoManual != null ? ' (${Fmt.moneda(c.costoManual)})' : ''}'
              '${c.activo ? '' : '   ·   inactivo'}',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _editar(context, ref, categorias, corte: c),
            ),
          ),
      ],
    );
  }

  Future<void> _editar(
    BuildContext context,
    WidgetRef ref,
    List<Categoria> categorias, {
    Corte? corte,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _CorteDialog(categorias: categorias, corte: corte),
    );
    if (ok == true) ref.invalidate(cortesProvider);
  }
}

class _CorteDialog extends ConsumerStatefulWidget {
  const _CorteDialog({required this.categorias, this.corte});
  final List<Categoria> categorias;
  final Corte? corte;

  @override
  ConsumerState<_CorteDialog> createState() => _CorteDialogState();
}

class _CorteDialogState extends ConsumerState<_CorteDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _kgr;
  late final TextEditingController _costo;
  late final TextEditingController _orden;
  late String _categoriaId;
  late ValorizaA _valorizaA;
  late bool _activo;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final c = widget.corte;
    _nombre = TextEditingController(text: c?.nombre ?? '');
    _kgr = TextEditingController(text: (c?.kgrRinde ?? 0).toString());
    _costo = TextEditingController(text: c?.costoManual?.toString() ?? '');
    _orden = TextEditingController(text: (c?.orden ?? 0).toString());
    _categoriaId = c?.categoriaId ?? widget.categorias.first.id;
    _valorizaA = c?.valorizaA ?? ValorizaA.venta;
    _activo = c?.activo ?? true;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _kgr.dispose();
    _costo.dispose();
    _orden.dispose();
    super.dispose();
  }

  double? _num(TextEditingController c) =>
      c.text.trim().isEmpty ? null : double.tryParse(c.text.replaceAll(',', '.'));

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      await ref.read(configuracionRepositoryProvider).upsertCorte(
            id: widget.corte?.id,
            categoriaId: _categoriaId,
            nombre: _nombre.text.trim(),
            kgrRinde: _num(_kgr) ?? 0,
            valorizaA: _valorizaA,
            costoManual: _valorizaA == ValorizaA.costo ? _num(_costo) : null,
            activo: _activo,
            orden: int.tryParse(_orden.text) ?? 0,
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => _guardando = false);
        mostrarMensaje(context, 'No se pudo guardar: $e', error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.corte == null ? 'Nuevo corte' : 'Editar corte'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _categoriaId,
                  decoration: const InputDecoration(labelText: 'Categoría'),
                  items: [
                    for (final cat in widget.categorias)
                      DropdownMenuItem(value: cat.id, child: Text(cat.nombre)),
                  ],
                  onChanged: (v) => setState(() => _categoriaId = v!),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nombre,
                  decoration: const InputDecoration(labelText: 'Nombre del corte'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _kgr,
                  decoration: const InputDecoration(labelText: 'KGR (kilos de rinde)', suffixText: 'kg'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<ValorizaA>(
                  initialValue: _valorizaA,
                  decoration: const InputDecoration(labelText: 'Se valoriza a'),
                  items: const [
                    DropdownMenuItem(value: ValorizaA.venta, child: Text('Precio de venta (corte individual)')),
                    DropdownMenuItem(value: ValorizaA.costo, child: Text('Costo manual (pieza entera)')),
                  ],
                  onChanged: (v) => setState(() => _valorizaA = v!),
                ),
                if (_valorizaA == ValorizaA.costo) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _costo,
                    decoration: const InputDecoration(labelText: 'Costo manual', prefixText: r'$ '),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ],
                const SizedBox(height: 12),
                TextFormField(
                  controller: _orden,
                  decoration: const InputDecoration(labelText: 'Orden'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 4),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Activo'),
                  value: _activo,
                  onChanged: (v) => setState(() => _activo = v),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _guardando ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _guardando ? null : _guardar,
          child: _guardando
              ? const SizedBox(
                  height: 18, width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Guardar'),
        ),
      ],
    );
  }
}
