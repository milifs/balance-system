import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/tipo_gasto.dart';
import '../../application/configuracion_providers.dart';
import '../widgets/section_scaffold.dart';

class TiposGastoSection extends ConsumerWidget {
  const TiposGastoSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(tiposGastoProvider);
    return SectionScaffold(
      titulo: 'Tipos de gasto',
      descripcion:
          'Categorías de gasto que se itemizan en el balance (rentas, contador, '
          'sueldos, servicios, etc.).',
      textoAgregar: 'Nuevo tipo',
      onAgregar: () => _editar(context, ref),
      child: listaAsync<TipoGasto>(
        value: value,
        builder: (items) => ListView(
          children: [
            for (final t in items)
              ListTile(
                leading: Icon(
                  t.activo ? Icons.check_circle : Icons.remove_circle_outline,
                  color: t.activo ? null : Colors.grey,
                ),
                title: Text(t.nombre),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editar(context, ref, tipo: t),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _editar(BuildContext context, WidgetRef ref,
      {TipoGasto? tipo}) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _TipoGastoDialog(tipo: tipo),
    );
    if (ok == true) ref.invalidate(tiposGastoProvider);
  }
}

class _TipoGastoDialog extends ConsumerStatefulWidget {
  const _TipoGastoDialog({this.tipo});
  final TipoGasto? tipo;

  @override
  ConsumerState<_TipoGastoDialog> createState() => _TipoGastoDialogState();
}

class _TipoGastoDialogState extends ConsumerState<_TipoGastoDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _orden;
  late bool _activo;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final t = widget.tipo;
    _nombre = TextEditingController(text: t?.nombre ?? '');
    _orden = TextEditingController(text: (t?.orden ?? 0).toString());
    _activo = t?.activo ?? true;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _orden.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      await ref.read(configuracionRepositoryProvider).upsertTipoGasto(
            id: widget.tipo?.id,
            nombre: _nombre.text.trim(),
            orden: int.tryParse(_orden.text) ?? 0,
            activo: _activo,
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
      title: Text(widget.tipo == null ? 'Nuevo tipo de gasto' : 'Editar tipo de gasto'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombre,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _orden,
                decoration: const InputDecoration(labelText: 'Orden'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
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
