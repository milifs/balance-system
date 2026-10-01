import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/formatters/formatters.dart';
import '../../../../core/models/categoria.dart';
import '../../../../core/models/corte.dart';
import '../../../../core/models/precio.dart';
import '../../../../core/theme/app_theme.dart';
import '../../application/precios_rinde_providers.dart';
import '../../data/precios_rinde_repository.dart';

/// Vista de una categoría: panel de precios (izq) + panel de rinde (der).
/// El rinde se recalcula en vivo con la columna "Nuevo precio".
class CategoriaPreciosView extends ConsumerStatefulWidget {
  const CategoriaPreciosView({
    super.key,
    required this.categoria,
    required this.cortes,
    required this.precios,
    required this.esAdmin,
  });

  final Categoria categoria;
  final List<Corte> cortes;
  final Map<String, Precio> precios;
  final bool esAdmin;

  @override
  ConsumerState<CategoriaPreciosView> createState() =>
      _CategoriaPreciosViewState();
}

class _CategoriaPreciosViewState extends ConsumerState<CategoriaPreciosView> {
  late final TextEditingController _incremento;
  late final Map<String, TextEditingController> _nuevo;
  final Map<String, double?> _calc = {};
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final pct = (widget.categoria.factorIncremento - 1) * 100;
    _incremento = TextEditingController(text: pct == 0 ? '' : _trim(pct));
    _nuevo = {
      for (final c in widget.cortes) c.id: TextEditingController(),
    };
    for (final ctrl in _nuevo.values) {
      ctrl.addListener(_recalcular);
    }
  }

  @override
  void dispose() {
    _incremento.dispose();
    for (final ctrl in _nuevo.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _recalcular() => setState(() {});

  // ---- Cálculo del precio "vivo" que alimenta el rinde ----
  double? _precioVivo(Corte c) {
    final ingresado = _parse(_nuevo[c.id]?.text ?? '');
    return ingresado ?? widget.precios[c.id]?.actual;
  }

  void _calcular() {
    final i = _parse(_incremento.text) ?? 0;
    final factor = 1 + i / 100;
    for (final c in widget.cortes) {
      final actual = widget.precios[c.id]?.actual;
      if (actual != null) {
        // Precios en pesos enteros.
        final calc = (actual * factor).roundToDouble();
        _calc[c.id] = calc;
        _nuevo[c.id]!.text = _trim(calc);
      }
    }
    setState(() {});
  }

  Future<void> _guardar() async {
    setState(() => _guardando = true);
    try {
      final rotaciones = <RotacionPrecio>[
        for (final c in widget.cortes)
          RotacionPrecio(
            corteId: c.id,
            // Si el campo quedó vacío, se mantiene el actual.
            nuevoActual:
                _parse(_nuevo[c.id]?.text ?? '') ?? widget.precios[c.id]?.actual,
            nuevoUltimo: widget.precios[c.id]?.actual,
            nuevoPenultimo: widget.precios[c.id]?.ultimo,
          ),
      ];
      await ref.read(preciosRindeRepositoryProvider).guardarPrecios(rotaciones);
      ref.invalidate(preciosProvider);
      if (mounted) {
        _calc.clear();
        _snack('Precios de ${widget.categoria.nombre} guardados.');
      }
    } catch (e) {
      if (mounted) _snack('No se pudo guardar: $e', error: true);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  void _snack(String texto, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(texto),
        backgroundColor: error ? AppColors.rojoNegativo : AppColors.verde,
      ));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cortes.isEmpty) {
      return const Center(child: Text('Esta categoría no tiene cortes activos.'));
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 3, child: _panelPrecios()),
          const SizedBox(width: 16),
          Expanded(flex: 2, child: _panelRinde()),
        ],
      ),
    );
  }

  // ============================ PANEL PRECIOS ============================
  Widget _panelPrecios() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Text('Lista de precios',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.grisTexto)),
                const Spacer(),
                if (widget.esAdmin) ...[
                  SizedBox(
                    width: 110,
                    child: TextField(
                      controller: _incremento,
                      textAlign: TextAlign.right,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      decoration: const InputDecoration(
                        labelText: 'Increm. %',
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: _calcular,
                    icon: const Icon(Icons.calculate_outlined, size: 18),
                    label: const Text('Calcular'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _guardando ? null : _guardar,
                    icon: _guardando
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.save_outlined, size: 18),
                    label: const Text('Guardar'),
                  ),
                ],
              ],
            ),
          ),
          _filaPrecio(
            corte: null,
            header: true,
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (final c in widget.cortes) _filaPrecio(corte: c),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filaPrecio({required Corte? corte, bool header = false}) {
    TextStyle? hs = header
        ? const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.grisTexto)
        : null;

    Widget cell(String text, int flex,
            {Alignment align = Alignment.centerRight}) =>
        Expanded(
          flex: flex,
          child: Align(
            alignment: align,
            child: Text(text, style: hs, overflow: TextOverflow.ellipsis),
          ),
        );

    if (header) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          children: [
            cell('Corte', 3, align: Alignment.centerLeft),
            cell('Penúlt.', 2),
            cell('Último', 2),
            cell('Actual', 2),
            cell('Calc.', 2),
            cell('Nuevo', 3),
          ],
        ),
      );
    }

    final c = corte!;
    final p = widget.precios[c.id];
    final calc = _calc[c.id];
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x11000000))),
      ),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Row(
        children: [
          cell(c.nombre, 3, align: Alignment.centerLeft),
          cell(_money(p?.penultimo), 2),
          cell(_money(p?.ultimo), 2),
          cell(_money(p?.actual), 2),
          cell(calc == null ? '—' : Fmt.moneda(calc), 2),
          Expanded(
            flex: 3,
            child: widget.esAdmin
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                    child: TextField(
                      controller: _nuevo[c.id],
                      textAlign: TextAlign.right,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      decoration: const InputDecoration(
                        isDense: true,
                        hintText: '—',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                    ),
                  )
                : Align(
                    alignment: Alignment.centerRight,
                    child: Text(_money(_precioVivo(c))),
                  ),
          ),
        ],
      ),
    );
  }

  // ============================ PANEL RINDE ============================
  Widget _panelRinde() {
    double kgTotal = 0;
    double ingreso = 0;
    for (final c in widget.cortes) {
      kgTotal += c.kgrRinde;
      ingreso += c.kgrRinde * (_precioVivo(c) ?? 0);
    }
    final costo = widget.categoria.costoPiezaBase;
    final resultado = costo == null ? null : ingreso - costo;
    final pct = (costo == null || costo == 0) ? null : resultado! / costo * 100;

    Widget hcell(String t, int flex, {Alignment a = Alignment.centerRight}) =>
        Expanded(
          flex: flex,
          child: Align(
            alignment: a,
            child: Text(t,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: AppColors.grisTexto)),
          ),
        );

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Text('Rinde',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.grisTexto)),
                const SizedBox(width: 8),
                if (widget.categoria.piezaBaseNombre != null)
                  Expanded(
                    child: Text(
                      '· ${widget.categoria.piezaBaseNombre}',
                      style: const TextStyle(color: AppColors.grisTexto),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                hcell('Corte', 4, a: Alignment.centerLeft),
                hcell('KGR', 2),
                hcell('Precio', 3),
                hcell('Total', 3),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (final c in widget.cortes)
                    _filaRinde(c),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          _resumenRinde(
            kgTotal: kgTotal,
            ingreso: ingreso,
            costo: costo,
            resultado: resultado,
            pct: pct,
          ),
        ],
      ),
    );
  }

  Widget _filaRinde(Corte c) {
    final precio = _precioVivo(c);
    final total = c.kgrRinde * (precio ?? 0);
    Widget cell(String t, int flex,
            {Alignment a = Alignment.centerRight}) =>
        Expanded(
          flex: flex,
          child: Align(
            alignment: a,
            child: Text(t, overflow: TextOverflow.ellipsis),
          ),
        );
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x11000000))),
      ),
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Row(
        children: [
          cell(c.nombre, 4, a: Alignment.centerLeft),
          cell(Fmt.kg(c.kgrRinde), 2),
          cell(_money(precio), 3),
          cell(Fmt.moneda(total), 3),
        ],
      ),
    );
  }

  Widget _resumenRinde({
    required double kgTotal,
    required double ingreso,
    required double? costo,
    required double? resultado,
    required double? pct,
  }) {
    final positivo = (resultado ?? 0) >= 0;
    final colorRes = positivo ? AppColors.verde : AppColors.rojoNegativo;

    Widget fila(String label, String value, {Color? color, bool bold = false}) =>
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: TextStyle(
                      color: AppColors.grisTexto,
                      fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
              Text(value,
                  style: TextStyle(
                      color: color,
                      fontWeight: bold ? FontWeight.bold : FontWeight.w500)),
            ],
          ),
        );

    return Container(
      color: AppColors.crema,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        children: [
          fila('Kg Rinde total', Fmt.kg(kgTotal)),
          fila('Ingreso del despiece', Fmt.moneda(ingreso)),
          fila('Costo pieza base',
              costo == null ? 'Sin pieza base' : Fmt.moneda(costo)),
          const Divider(),
          fila('Resultado del rinde',
              resultado == null ? '—' : Fmt.moneda(resultado),
              color: resultado == null ? null : colorRes, bold: true),
          fila('% de rinde', pct == null ? '—' : Fmt.pct(pct.roundToDouble()),
              color: pct == null ? null : colorRes, bold: true),
        ],
      ),
    );
  }

  // ---- helpers ----
  String _money(double? v) => v == null ? '—' : Fmt.moneda(v);
}

/// Convierte texto es_AR/US a double. Acepta "1.382,26", "1382.26", "1382,26".
double? _parse(String s) {
  s = s.trim().replaceAll(' ', '');
  if (s.isEmpty) return null;
  if (s.contains(',') && s.contains('.')) {
    s = s.replaceAll('.', '').replaceAll(',', '.');
  } else if (s.contains(',')) {
    s = s.replaceAll(',', '.');
  }
  return double.tryParse(s);
}

/// Formatea un double para prefijar campos editables (sin separadores de miles).
String _trim(double v) {
  if (v == v.roundToDouble()) return v.toInt().toString();
  return v.toStringAsFixed(2);
}
