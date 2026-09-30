import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/sucursal.dart';
import '../../application/configuracion_providers.dart';
import '../widgets/section_scaffold.dart';

class SucursalesSection extends ConsumerWidget {
  const SucursalesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(sucursalesProvider);
    return SectionScaffold(
      titulo: 'Sucursales',
      descripcion: 'Las 4 carnicerías Don Chacho. El orden define su ubicación en las pestañas.',
      textoAgregar: 'Nueva sucursal',
      onAgregar: () => _editar(context, ref),
      child: listaAsync<Sucursal>(
        value: value,
        builder: (items) => ListView(
          children: [
            for (final s in items)
              ListTile(
                leading: CircleAvatar(child: Text('${s.orden}')),
                title: Text(s.nombre),
                subtitle: Text(s.activo ? 'Activa' : 'Inactiva'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editar(context, ref, sucursal: s),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _editar(BuildContext context, WidgetRef ref,
      {Sucursal? sucursal}) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _SucursalDialog(sucursal: sucursal),
    );
    if (ok == true) ref.invalidate(sucursalesProvider);
  }
}

class _SucursalDialog extends ConsumerStatefulWidget {
  const _SucursalDialog({this.sucursal});
  final Sucursal? sucursal;

  @override
  ConsumerState<_SucursalDialog> createState() => _SucursalDialogState();
}

class _SucursalDialogState extends ConsumerState<_SucursalDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _orden;
  late bool _activo;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final s = widget.sucursal;
    _nombre = TextEditingController(text: s?.nombre ?? '');
    _orden = TextEditingController(text: (s?.orden ?? 0).toString());
    _activo = s?.activo ?? true;
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
      await ref.read(configuracionRepositoryProvider).upsertSucursal(
            id: widget.sucursal?.id,
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
      title: Text(widget.sucursal == null ? 'Nueva sucursal' : 'Editar sucursal'),
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
                title: const Text('Activa'),
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
