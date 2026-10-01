import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/formatters/formatters.dart';
import '../../../../core/theme/app_theme.dart';

/// Muestra un SnackBar de éxito/error.
void mostrarMensaje(BuildContext context, String texto, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(texto),
      backgroundColor: error ? AppColors.rojoNegativo : AppColors.verde,
    ));
}

/// Estado de carga/error/vacío estándar para un AsyncValue de lista.
Widget cargaListaAsync<T>({
  required AsyncValue<List<T>> value,
  required Widget Function(List<T> items) builder,
  String vacio = 'Sin registros en este período.',
}) {
  return value.when(
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (e, _) => Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text('Error al cargar: $e',
            style: const TextStyle(color: AppColors.rojoNegativo)),
      ),
    ),
    data: (items) => items.isEmpty
        ? Center(
            child: Text(vacio,
                style: const TextStyle(color: AppColors.grisTexto)))
        : builder(items),
  );
}

/// Pie de sección con el total en $ (destacado).
class TotalFooter extends StatelessWidget {
  const TotalFooter({super.key, required this.etiqueta, required this.total});

  final String etiqueta;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: AppColors.crema,
        border: Border(top: BorderSide(color: Color(0x22000000))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(etiqueta,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: AppColors.grisTexto)),
          Text(Fmt.moneda(total),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.rojo,
              )),
        ],
      ),
    );
  }
}

/// Confirmación de borrado. Devuelve true si el usuario confirma.
Future<bool> confirmarBorrado(BuildContext context, String descripcion) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Eliminar registro'),
      content: Text('¿Eliminar $descripcion? Esta acción no se puede deshacer.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.rojoNegativo),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );
  return ok ?? false;
}

/// Campo de fecha reutilizable: abre el date picker al tocarlo.
class FechaField extends StatelessWidget {
  const FechaField({
    super.key,
    required this.fecha,
    required this.onTap,
    this.width = 150,
  });

  final DateTime fecha;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: const InputDecoration(
            labelText: 'Fecha',
            isDense: true,
            suffixIcon: Icon(Icons.calendar_today, size: 18),
          ),
          child: Text(Fmt.fecha(fecha)),
        ),
      ),
    );
  }
}

/// Cuadro siempre visible para cargar un registro nuevo (reemplaza el diálogo).
/// Muestra los campos editables en línea y un botón Guardar al final.
class CargaFormPanel extends StatelessWidget {
  const CargaFormPanel({
    super.key,
    required this.titulo,
    required this.formKey,
    required this.campos,
    required this.onGuardar,
    required this.guardando,
  });

  final String titulo;
  final GlobalKey<FormState> formKey;
  final List<Widget> campos;
  final VoidCallback onGuardar;
  final bool guardando;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.crema,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x22000000)),
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: AppColors.grisTexto)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.start,
              children: [
                ...campos,
                SizedBox(
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: guardando ? null : onGuardar,
                    icon: guardando
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.add),
                    label: const Text('Guardar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Cuadro siempre visible con una fila fija por cada medio de pago / tipo de
/// compra / tipo de gasto (sin combo): el usuario solo tipea el monto al
/// lado de la etiqueta que ya está precargada, en el mismo orden siempre
/// (alfabético). Una fecha compartida arriba y un botón "Guardar" que crea
/// un registro por cada fila con monto.
class CargaGridPanel extends StatelessWidget {
  const CargaGridPanel({
    super.key,
    required this.titulo,
    required this.formKey,
    required this.fecha,
    required this.onFecha,
    required this.filas,
    required this.onGuardar,
    required this.guardando,
  });

  final String titulo;
  final GlobalKey<FormState> formKey;
  final DateTime fecha;
  final VoidCallback onFecha;
  final List<Widget> filas;
  final VoidCallback onGuardar;
  final bool guardando;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.crema,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x22000000)),
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(titulo,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.grisTexto)),
                const Spacer(),
                FechaField(fecha: fecha, onTap: onFecha, width: 150),
              ],
            ),
            const SizedBox(height: 12),
            ...filas,
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: guardando ? null : onGuardar,
                icon: guardando
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save_outlined, size: 18),
                label: const Text('Guardar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fila de `CargaGridPanel`: etiqueta fija a la izquierda + campo de monto a
/// la derecha, con un campo extra opcional (ej. proveedor en compras).
class CargaGridRow extends StatelessWidget {
  const CargaGridRow({
    super.key,
    required this.etiqueta,
    required this.controller,
    this.subtitulo,
    this.extra,
  });

  final String etiqueta;
  final TextEditingController controller;
  final String? subtitulo;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(etiqueta, style: const TextStyle(fontWeight: FontWeight.w500)),
                if (subtitulo != null)
                  Text(subtitulo!,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.grisTexto)),
              ],
            ),
          ),
          SizedBox(
            width: 160,
            child: TextFormField(
              controller: controller,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                  prefixText: r'$ ', isDense: true, hintText: '0'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                final n = parseMonto(v);
                if (n == null) return 'Monto inválido';
                if (n < 0) return 'No puede ser negativo';
                return null;
              },
            ),
          ),
          if (extra != null) ...[
            const SizedBox(width: 12),
            SizedBox(width: 180, child: extra!),
          ],
        ],
      ),
    );
  }
}

/// Parseo de montos aceptando formato es_AR ("1.234,56") o US ("1234.56").
double? parseMonto(String raw) {
  var s = raw.trim();
  if (s.isEmpty) return null;
  s = s.replaceAll(' ', '').replaceAll(r'$', '');
  final tieneComa = s.contains(',');
  final tienePunto = s.contains('.');
  if (tieneComa && tienePunto) {
    // El último separador es el decimal.
    if (s.lastIndexOf(',') > s.lastIndexOf('.')) {
      s = s.replaceAll('.', '').replaceAll(',', '.');
    } else {
      s = s.replaceAll(',', '');
    }
  } else if (tieneComa) {
    s = s.replaceAll(',', '.');
  }
  return double.tryParse(s);
}
