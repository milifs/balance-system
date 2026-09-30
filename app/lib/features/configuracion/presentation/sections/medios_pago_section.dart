import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/formatters/formatters.dart';
import '../../../../core/models/medio_pago.dart';
import '../../application/configuracion_providers.dart';
import '../widgets/section_scaffold.dart';

class MediosPagoSection extends ConsumerWidget {
  const MediosPagoSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(mediosPagoProvider);
    return SectionScaffold(
      titulo: 'Medios de pago',
      descripcion:
          'Retención por medio: efectivo 0 %, crédito/débito 12 %, transferencia '
          'provisorio. La retención se aplica al calcular la venta neta.',
      textoAgregar: 'Nuevo medio',
      onAgregar: () => _editar(context, ref),
      child: listaAsync<MedioPago>(
        value: value,
        builder: (items) => ListView(
          children: [
            for (final m in items)
              ListTile(
                leading: Icon(
                  m.activo ? Icons.check_circle : Icons.remove_circle_outline,
                  color: m.activo ? null : Colors.grey,
                ),
                title: Text(m.nombre),
                subtitle: Text('Retención: ${Fmt.pct(m.retencionPct)}'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editar(context, ref, medio: m),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _editar(BuildContext context, WidgetRef ref,
      {MedioPago? medio}) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _MedioPagoDialog(medio: medio),
    );
    if (ok == true) ref.invalidate(mediosPagoProvider);
  }
}

class _MedioPagoDialog extends ConsumerStatefulWidget {
  const _MedioPagoDialog({this.medio});
  final MedioPago? medio;

  @override
  ConsumerState<_MedioPagoDialog> createState() => _MedioPagoDialogState();
}

class _MedioPagoDialogState extends ConsumerState<_MedioPagoDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _retencion;
  late final TextEditingController _orden;
  late bool _activo;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final m = widget.medio;
    _nombre = TextEditingController(text: m?.nombre ?? '');
    _retencion = TextEditingController(text: (m?.retencionPct ?? 0).toString());
    _orden = TextEditingController(text: (m?.orden ?? 0).toString());
    _activo = m?.activo ?? true;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _retencion.dispose();
    _orden.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      await ref.read(configuracionRepositoryProvider).upsertMedioPago(
            id: widget.medio?.id,
            nombre: _nombre.text.trim(),
            retencionPct: double.parse(_retencion.text.replaceAll(',', '.')),
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
      title: Text(widget.medio == null ? 'Nuevo medio de pago' : 'Editar medio de pago'),
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
                controller: _retencion,
                decoration: const InputDecoration(
                  labelText: 'Retención %',
                  suffixText: '%',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  final n = double.tryParse((v ?? '').replaceAll(',', '.'));
                  if (n == null || n < 0 || n > 100) return '0 a 100';
                  return null;
                },
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
