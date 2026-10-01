import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/formatters/formatters.dart';
import '../../../../core/models/corte.dart';
import '../../../../core/models/periodo.dart';
import '../../../../core/models/pesaje.dart';
import '../../../../core/models/pesaje_item.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../carga/presentation/widgets/carga_ui.dart';
import '../../application/pesaje_providers.dart';
import '../../data/pesaje_repository.dart';

/// Diálogo para registrar los pesos (bateas/cámaras) de un corte en un
/// momento del período. Crea la sesión de pesaje al agregar la primera pesada
/// y la elimina si se borran todas.
class PesajeCorteDialog extends ConsumerStatefulWidget {
  const PesajeCorteDialog({
    super.key,
    required this.corte,
    required this.pesajeConItems,
    required this.periodo,
    required this.momento,
    required this.fecha,
    required this.precioVigente,
    required this.editable,
  });

  final Corte corte;
  final PesajeConItems? pesajeConItems;
  final Periodo periodo;
  final MomentoPesaje momento;
  final DateTime fecha;
  final double? precioVigente;
  final bool editable;

  @override
  ConsumerState<PesajeCorteDialog> createState() => _PesajeCorteDialogState();
}

class _PesajeCorteDialogState extends ConsumerState<PesajeCorteDialog> {
  final _kg = TextEditingController();
  final _origen = TextEditingController();
  final _kgFocus = FocusNode();

  String? _pesajeId;
  late List<PesajeItem> _items;
  bool _cambios = false;
  bool _ocupado = false;

  @override
  void initState() {
    super.initState();
    _pesajeId = widget.pesajeConItems?.pesaje.id;
    _items = [...?widget.pesajeConItems?.items];
  }

  @override
  void dispose() {
    _kg.dispose();
    _origen.dispose();
    _kgFocus.dispose();
    super.dispose();
  }

  PesajeRepository get _repo => ref.read(pesajeRepositoryProvider);

  double get _totalKg => _items.fold(0, (s, i) => s + i.kg);

  Future<void> _agregar() async {
    final kg = parseMonto(_kg.text);
    if (kg == null || kg < 0) {
      mostrarMensaje(context, 'Peso inválido', error: true);
      return;
    }
    setState(() => _ocupado = true);
    try {
      // Crear la sesión de pesaje si todavía no existe.
      if (_pesajeId == null) {
        final pesaje = await _repo.crearPesaje(
          corteId: widget.corte.id,
          sucursalId: widget.periodo.sucursalId,
          periodoId: widget.periodo.id,
          momento: widget.momento,
          fecha: widget.fecha,
          precioSnapshot: widget.precioVigente,
        );
        _pesajeId = pesaje.id;
      }
      final origen = _origen.text.trim();
      await _repo.agregarItem(
        pesajeId: _pesajeId!,
        kg: kg,
        origen: origen.isEmpty ? null : origen,
      );
      final items = await _repo.listItems(_pesajeId!);
      if (!mounted) return;
      setState(() {
        _items = items;
        _cambios = true;
        _ocupado = false;
      });
      _kg.clear();
      _origen.clear();
      _kgFocus.requestFocus();
    } catch (e) {
      if (mounted) {
        setState(() => _ocupado = false);
        mostrarMensaje(context, 'No se pudo agregar: $e', error: true);
      }
    }
  }

  Future<void> _eliminar(PesajeItem item) async {
    setState(() => _ocupado = true);
    try {
      await _repo.eliminarItem(item.id);
      var items = await _repo.listItems(_pesajeId!);
      // Si fue la última pesada, borrar la sesión vacía.
      if (items.isEmpty) {
        await _repo.eliminarPesaje(_pesajeId!);
        _pesajeId = null;
        items = const [];
      }
      if (!mounted) return;
      setState(() {
        _items = items;
        _cambios = true;
        _ocupado = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _ocupado = false);
        mostrarMensaje(context, 'No se pudo eliminar: $e', error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final precio = widget.precioVigente;
    final valor = precio == null ? null : _totalKg * precio;

    return AlertDialog(
      title: Text('${widget.corte.nombre} · ${widget.momento.label}'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Lista de pesadas.
            if (_items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('Todavía no hay pesadas cargadas.',
                    style: TextStyle(color: AppColors.grisTexto)),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final it = _items[i];
                    final origen = (it.origen ?? '').trim();
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(Fmt.kg(it.kg)),
                      subtitle: origen.isEmpty ? null : Text(origen),
                      trailing: widget.editable
                          ? IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20),
                              tooltip: 'Eliminar pesada',
                              onPressed: _ocupado ? null : () => _eliminar(it),
                            )
                          : null,
                    );
                  },
                ),
              ),
            const Divider(),
            // Total.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total: ${Fmt.kg(_totalKg)}',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(valor == null ? '—' : Fmt.moneda(valor),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: AppColors.rojo)),
              ],
            ),
            // Alta de pesada.
            if (widget.editable) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _kg,
                      focusNode: _kgFocus,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Kg',
                        isDense: true,
                        suffixText: 'kg',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      onSubmitted: (_) => _ocupado ? null : _agregar(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _origen,
                      decoration: const InputDecoration(
                        labelText: 'Origen (opcional)',
                        isDense: true,
                        hintText: 'batea, cámara…',
                      ),
                      onSubmitted: (_) => _ocupado ? null : _agregar(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _ocupado ? null : _agregar,
                    icon: _ocupado
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.add),
                    tooltip: 'Agregar pesada',
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_cambios),
          child: const Text('Listo'),
        ),
      ],
    );
  }
}
