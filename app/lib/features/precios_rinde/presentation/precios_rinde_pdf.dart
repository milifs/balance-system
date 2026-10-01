import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/formatters/formatters.dart';
import '../../../core/models/categoria.dart';
import '../../../core/models/corte.dart';
import '../../../core/models/precio.dart';

/// Colores de marca replicados para el PDF (los `AppColors` son `dart:ui`
/// y acá necesitamos `PdfColor`). Mismos valores que `carga_pdf.dart`.
const _rojo = PdfColor.fromInt(0xFF8B1E1E);
const _crema = PdfColor.fromInt(0xFFF7F3EE);
const _gris = PdfColor.fromInt(0xFF2B2B2B);
const _grisClaro = PdfColor.fromInt(0xFF777777);

final _emision = DateFormat('dd/MM/yyyy HH:mm', 'es_AR');

/// Genera el PDF con la lista de precios vigente (Penúlt./Último/Actual) y el
/// rinde de cada categoría, y dispara la descarga/compartir en el navegador.
/// Usa el precio `actual` guardado (no valores editados sin guardar en la UI).
Future<void> exportarPreciosRindePdf({
  required List<Categoria> categorias,
  required List<Corte> cortes,
  required Map<String, Precio> precios,
}) async {
  final doc = _construir(categorias: categorias, cortes: cortes, precios: precios);
  await Printing.sharePdf(
    bytes: await doc.save(),
    filename: 'lista_precios_rinde_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf',
  );
}

pw.Document _construir({
  required List<Categoria> categorias,
  required List<Corte> cortes,
  required Map<String, Precio> precios,
}) {
  final cats = [...categorias]..sort((a, b) => a.orden.compareTo(b.orden));

  final doc = pw.Document(
    title: 'Lista de precios y rinde',
    author: 'Don Chacho',
  );

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(32, 32, 32, 36),
      header: (ctx) => ctx.pageNumber == 1 ? _encabezado() : pw.SizedBox(),
      footer: (ctx) => pw.Container(
        alignment: pw.Alignment.centerRight,
        margin: const pw.EdgeInsets.only(top: 8),
        child: pw.Text(
          'Página ${ctx.pageNumber} de ${ctx.pagesCount}',
          style: const pw.TextStyle(fontSize: 9, color: _grisClaro),
        ),
      ),
      build: (ctx) => [
        pw.SizedBox(height: 12),
        for (final c in cats)
          _seccionCategoria(
            categoria: c,
            cortes: cortes
                .where((co) => co.categoriaId == c.id && co.activo)
                .toList()
              ..sort((a, b) => a.orden.compareTo(b.orden)),
            precios: precios,
          ),
      ],
    ),
  );

  return doc;
}

pw.Widget _encabezado() => pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _rojo, width: 2)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Don Chacho',
                  style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: _rojo)),
              pw.SizedBox(height: 2),
              pw.Text('Lista de precios y rinde',
                  style: const pw.TextStyle(fontSize: 12, color: _gris)),
            ],
          ),
          pw.Text('Emitido ${_emision.format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 9, color: _grisClaro)),
        ],
      ),
    );

pw.Widget _seccionCategoria({
  required Categoria categoria,
  required List<Corte> cortes,
  required Map<String, Precio> precios,
}) {
  if (cortes.isEmpty) return pw.SizedBox();

  double kgTotal = 0;
  double ingreso = 0;
  final rows = <List<String>>[];
  for (final c in cortes) {
    final p = precios[c.id];
    final actual = p?.actual;
    kgTotal += c.kgrRinde;
    ingreso += c.kgrRinde * (actual ?? 0);
    rows.add([
      c.nombre,
      _money(p?.penultimo),
      _money(p?.ultimo),
      _money(actual),
      Fmt.kg(c.kgrRinde),
    ]);
  }
  final costo = categoria.costoPiezaBase;
  final resultado = costo == null ? null : ingreso - costo;
  final pct = (costo == null || costo == 0) ? null : resultado! / costo * 100;

  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 18),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Row(
          children: [
            pw.Text(categoria.nombre,
                style: pw.TextStyle(
                    fontSize: 13, fontWeight: pw.FontWeight.bold, color: _gris)),
            if (categoria.piezaBaseNombre != null)
              pw.Text(' · ${categoria.piezaBaseNombre}',
                  style: const pw.TextStyle(fontSize: 10, color: _grisClaro)),
          ],
        ),
        pw.SizedBox(height: 6),
        pw.TableHelper.fromTextArray(
          headers: ['Corte', 'Penúlt.', 'Último', 'Actual', 'KGR'],
          data: rows,
          border: null,
          headerStyle: pw.TextStyle(
              fontSize: 9.5,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white),
          headerDecoration: const pw.BoxDecoration(color: _rojo),
          cellStyle: const pw.TextStyle(fontSize: 10, color: _gris),
          rowDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFFFFFFF)),
          oddRowDecoration: const pw.BoxDecoration(color: _crema),
          cellHeight: 18,
          headerAlignments: const {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.centerRight,
            2: pw.Alignment.centerRight,
            3: pw.Alignment.centerRight,
            4: pw.Alignment.centerRight,
          },
          cellAlignments: const {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.centerRight,
            2: pw.Alignment.centerRight,
            3: pw.Alignment.centerRight,
            4: pw.Alignment.centerRight,
          },
          columnWidths: {
            1: const pw.FixedColumnWidth(70),
            2: const pw.FixedColumnWidth(70),
            3: const pw.FixedColumnWidth(70),
            4: const pw.FixedColumnWidth(60),
          },
          headerPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        ),
        if (costo != null) ...[
          pw.SizedBox(height: 4),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              _resumenItem('Kg rinde', Fmt.kg(kgTotal)),
              _resumenItem('Ingreso', Fmt.moneda(ingreso)),
              _resumenItem('Costo pieza', Fmt.moneda(costo)),
              _resumenItem('Resultado', Fmt.moneda(resultado!), destacado: true),
              _resumenItem('% rinde', Fmt.pct(pct!.roundToDouble()), destacado: true),
            ],
          ),
        ],
      ],
    ),
  );
}

pw.Widget _resumenItem(String etiqueta, String valor, {bool destacado = false}) =>
    pw.Padding(
      padding: const pw.EdgeInsets.only(left: 14),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Text(etiqueta, style: const pw.TextStyle(fontSize: 8, color: _grisClaro)),
          pw.Text(valor,
              style: pw.TextStyle(
                  fontSize: 10,
                  color: destacado ? _rojo : _gris,
                  fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );

String _money(double? v) => v == null ? '—' : Fmt.moneda(v);
