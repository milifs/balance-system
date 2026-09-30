import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/formatters/formatters.dart';
import '../../../../core/models/categoria.dart';
import '../../application/configuracion_providers.dart';
import '../widgets/section_scaffold.dart';

class CategoriasSection extends ConsumerWidget {
  const CategoriasSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(categoriasProvider);
    return SectionScaffold(
      titulo: 'Categorías y pieza base (rinde)',
      descripcion:
          'Cada categoría tiene su pieza base (Media Res, Media Cerdo, Caja de '
          'Pollo) con kg y \$/kg de compra, y el factor de incremento de precios.',
      child: listaAsync<Categoria>(
        value: value,
        builder: (items) => ListView(
          padding: const EdgeInsets.all(8),
          children: [
            for (final c in items)
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                elevation: 0,
                color: Colors.grey.shade50,
                child: ListTile(
                  title: Text(c.nombre,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pieza base: ${c.piezaBaseNombre ?? '—'}'),
                      Text(
                        'Kg: ${c.piezaBaseKg != null ? Fmt.kg(c.piezaBaseKg) : '—'}   ·   '
                        'Costo: ${c.piezaBaseCostoKg != null ? '${Fmt.moneda(c.piezaBaseCostoKg)}/kg' : '—'}',
                      ),
                      Text(
                        'Costo pieza: ${c.costoPiezaBase != null ? Fmt.moneda(c.costoPiezaBase) : '—'}   ·   '
                        'Factor: ${Fmt.pct((c.factorIncremento - 1) * 100)}',
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editar(context, ref, c),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _editar(BuildContext context, WidgetRef ref, Categoria c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _CategoriaDialog(categoria: c),
    );
    if (ok == true) ref.invalidate(categoriasProvider);
  }
}

class _CategoriaDialog extends ConsumerStatefulWidget {
  const _CategoriaDialog({required this.categoria});
  final Categoria categoria;

  @override
  ConsumerState<_CategoriaDialog> createState() => _CategoriaDialogState();
}

class _CategoriaDialogState extends ConsumerState<_CategoriaDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _piezaNombre;
  late final TextEditingController _piezaKg;
  late final TextEditingController _piezaCosto;
  late final TextEditingController _factorPct;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final c = widget.categoria;
    _piezaNombre = TextEditingController(text: c.piezaBaseNombre ?? '');
    _piezaKg = TextEditingController(text: c.piezaBaseKg?.toString() ?? '');
    _piezaCosto = TextEditingController(text: c.piezaBaseCostoKg?.toString() ?? '');
    _factorPct = TextEditingController(
        text: ((c.factorIncremento - 1) * 100).toStringAsFixed(2));
  }

  @override
  void dispose() {
    _piezaNombre.dispose();
    _piezaKg.dispose();
    _piezaCosto.dispose();
    _factorPct.dispose();
    super.dispose();
  }

  double? _num(TextEditingController c) =>
      c.text.trim().isEmpty ? null : double.tryParse(c.text.replaceAll(',', '.'));

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      final pct = _num(_factorPct) ?? 0;
      await ref.read(configuracionRepositoryProvider).updateCategoria(
            id: widget.categoria.id,
            piezaBaseNombre: _piezaNombre.text.trim().isEmpty
                ? null
                : _piezaNombre.text.trim(),
            piezaBaseKg: _num(_piezaKg),
            piezaBaseCostoKg: _num(_piezaCosto),
            factorIncremento: 1 + pct / 100,
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
      title: Text('Editar ${widget.categoria.nombre}'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _piezaNombre,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la pieza base',
                  hintText: 'Media Res / Media Cerdo / Caja de Pollo',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _piezaKg,
                decoration: const InputDecoration(labelText: 'Kg de la pieza', suffixText: 'kg'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _piezaCosto,
                decoration: const InputDecoration(labelText: 'Costo por kg', prefixText: r'$ '),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _factorPct,
                decoration: const InputDecoration(
                  labelText: 'Factor de incremento',
                  suffixText: '%',
                  helperText: 'Ej: 5 = +5 %',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
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
