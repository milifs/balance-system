import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/formatters/formatters.dart';
import '../../../../core/models/periodo.dart';
import '../../application/carga_providers.dart';
import 'carga_ui.dart';

/// Alta/edición de un período de una sucursal.
///
/// Devuelve el id del período creado/editado al cerrarse con éxito (o null si
/// se cancela).
class PeriodoDialog extends ConsumerStatefulWidget {
  const PeriodoDialog({super.key, required this.sucursalId, this.periodo});

  final String sucursalId;
  final Periodo? periodo;

  @override
  ConsumerState<PeriodoDialog> createState() => _PeriodoDialogState();
}

class _PeriodoDialogState extends ConsumerState<PeriodoDialog> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _inicio;
  late DateTime _fin;
  late final TextEditingController _stockInicial;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final p = widget.periodo;
    final hoy = DateTime.now();
    _inicio = p?.fechaInicio ?? DateTime(hoy.year, hoy.month, 1);
    _fin = p?.fechaFin ?? hoy;
    _stockInicial = TextEditingController(
      text: p?.stockInicialManual == null
          ? ''
          : _trim(p!.stockInicialManual!),
    );
  }

  @override
  void dispose() {
    _stockInicial.dispose();
    super.dispose();
  }

  static String _trim(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  Future<void> _elegirFecha({required bool esInicio}) async {
    final actual = esInicio ? _inicio : _fin;
    final picked = await showDatePicker(
      context: context,
      initialDate: actual,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (esInicio) {
          _inicio = picked;
        } else {
          _fin = picked;
        }
      });
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fin.isBefore(_inicio)) {
      mostrarMensaje(context, 'La fecha de cierre no puede ser anterior al inicio.',
          error: true);
      return;
    }
    final stock =
        _stockInicial.text.trim().isEmpty ? null : parseMonto(_stockInicial.text);
    setState(() => _guardando = true);
    try {
      final repo = ref.read(cargaRepositoryProvider);
      String periodoId;
      if (widget.periodo == null) {
        final creado = await repo.crearPeriodo(
          sucursalId: widget.sucursalId,
          fechaInicio: _inicio,
          fechaFin: _fin,
          stockInicialManual: stock,
        );
        periodoId = creado.id;
      } else {
        await repo.actualizarPeriodo(
          id: widget.periodo!.id,
          fechaInicio: _inicio,
          fechaFin: _fin,
          stockInicialManual: stock,
        );
        periodoId = widget.periodo!.id;
      }
      if (mounted) Navigator.of(context).pop(periodoId);
    } catch (e) {
      if (mounted) {
        setState(() => _guardando = false);
        mostrarMensaje(context, 'No se pudo guardar el período: $e', error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final esNuevo = widget.periodo == null;
    return AlertDialog(
      title: Text(esNuevo ? 'Nuevo período' : 'Editar período'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _FechaField(
                label: 'Fecha de inicio (pesaje anterior)',
                fecha: _inicio,
                onTap: () => _elegirFecha(esInicio: true),
              ),
              const SizedBox(height: 12),
              _FechaField(
                label: 'Fecha de cierre (pesaje actual)',
                fecha: _fin,
                onTap: () => _elegirFecha(esInicio: false),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stockInicial,
                decoration: const InputDecoration(
                  labelText: 'Stock inicial de apertura (opcional)',
                  helperText: 'Solo el primer período, si no hay pesaje previo.',
                  prefixText: r'$ ',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  return parseMonto(v) == null ? 'Monto inválido' : null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _guardando ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _guardando ? null : _guardar,
          child: _guardando
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Text('Guardar'),
        ),
      ],
    );
  }
}

class _FechaField extends StatelessWidget {
  const _FechaField({
    required this.label,
    required this.fecha,
    required this.onTap,
  });

  final String label;
  final DateTime fecha;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today, size: 18),
        ),
        child: Text(Fmt.fecha(fecha)),
      ),
    );
  }
}
