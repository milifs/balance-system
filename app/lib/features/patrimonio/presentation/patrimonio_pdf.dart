import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/formatters/formatters.dart';
import '../../../core/models/patrimonio.dart';

/// Colores de marca replicados para el PDF (los `AppColors` son `dart:ui`
/// y acá necesitamos `PdfColor`).
const _rojo = PdfColor.fromInt(0xFF8B1E1E);
const _crema = PdfColor.fromInt(0xFFF7F3EE);
const _gris = PdfColor.fromInt(0xFF2B2B2B);
const _grisClaro = PdfColor.fromInt(0xFF777777);
const _verde = PdfColor.fromInt(0xFF2E7D32);
const _rojoNegativo = PdfColor.fromInt(0xFFC62828);
const _borde = PdfColor.fromInt(0xFFDDD6CC);

final _emision = DateFormat('dd/MM/yyyy HH:mm', 'es_AR');

/// Arma el PDF del cuadro de patrimonio a una fecha y dispara la
/// descarga/compartir en el navegador.
///
/// Toma los datos ya resueltos (no lee la base) para que la pantalla de
/// Carga pueda exportar lo que está en pantalla y Consulta lo guardado.
Future<void> exportarPatrimonioPdf({
  required DateTime fecha,
  required List<PatrimonioItem> haber,
  required List<PatrimonioItem> debe,
}) async {
  final doc = construirPatrimonioPdf(fecha: fecha, haber: haber, debe: debe);
  await Printing.sharePdf(
    bytes: await doc.save(),
    filename: 'patrimonio_${DateFormat('yyyyMMdd').format(fecha)}.pdf',
  );
}

/// Arma el documento, sin descargarlo. Separado de `exportarPatrimonioPdf`
/// para poder generarlo en un test, donde no hay plataforma que comparta
/// archivos.
pw.Document construirPatrimonioPdf({
  required DateTime fecha,
  required List<PatrimonioItem> haber,
  required List<PatrimonioItem> debe,
}) {
  final totalHaber = totalDe(haber);
  final totalDebe = totalDe(debe);

  final doc = pw.Document(title: 'Patrimonio', author: 'Don Chacho');

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(32, 32, 32, 36),
      header: (ctx) =>
          ctx.pageNumber == 1 ? _encabezado(fecha) : pw.SizedBox(),
      footer: (ctx) => pw.Container(
        alignment: pw.Alignment.centerRight,
        margin: const pw.EdgeInsets.only(top: 8),
        child: pw.Text(
          'Página ${ctx.pageNumber} de ${ctx.pagesCount}',
          style: const pw.TextStyle(fontSize: 9, color: _grisClaro),
        ),
      ),
      build: (ctx) => [
        pw.SizedBox(height: 14),
        _cuadro(haber: haber, debe: debe),
        pw.SizedBox(height: 18),
        _saldo(fecha: fecha, saldo: totalHaber - totalDebe),
      ],
    ),
  );

  return doc;
}

pw.Widget _encabezado(DateTime fecha) => pw.Container(
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
              pw.Text('Patrimonio del negocio',
                  style: const pw.TextStyle(fontSize: 12, color: _gris)),
              pw.SizedBox(height: 1),
              pw.Text('Al ${Fmt.fecha(fecha)}',
                  style: const pw.TextStyle(fontSize: 10, color: _grisClaro)),
            ],
          ),
          pw.Text('Emitido ${_emision.format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 9, color: _grisClaro)),
        ],
      ),
    );

/// Las dos columnas en una sola tabla de 4 columnas (concepto + monto por
/// lado), igual que la planilla: así los renglones quedan enfrentados y la
/// tabla se puede cortar entre páginas sin partir el cuadro al medio.
pw.Widget _cuadro({
  required List<PatrimonioItem> haber,
  required List<PatrimonioItem> debe,
}) {
  final filas = haber.length > debe.length ? haber.length : debe.length;

  return pw.Table(
    border: pw.TableBorder.symmetric(
      inside: const pw.BorderSide(color: _borde, width: 0.5),
      outside: const pw.BorderSide(color: _borde, width: 0.5),
    ),
    columnWidths: const {
      0: pw.FlexColumnWidth(3),
      1: pw.FixedColumnWidth(85),
      2: pw.FlexColumnWidth(3),
      3: pw.FixedColumnWidth(85),
    },
    children: [
      // Encabezado: dos celdas por lado con el mismo fondo, que leídas
      // juntas hacen de título de la columna (la tabla no tiene colspan).
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: _rojo),
        children: [
          _celdaTitulo('HABER'),
          _celdaTitulo(''),
          _celdaTitulo('DEBE'),
          _celdaTitulo(''),
        ],
      ),
      for (var i = 0; i < filas; i++)
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: i.isOdd ? _crema : const PdfColor.fromInt(0xFFFFFFFF),
          ),
          children: [
            _celdaConcepto(i < haber.length ? haber[i].concepto : ''),
            _celdaMonto(i < haber.length ? haber[i].monto : null),
            _celdaConcepto(i < debe.length ? debe[i].concepto : ''),
            _celdaMonto(i < debe.length ? debe[i].monto : null),
          ],
        ),
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: _crema),
        children: [
          _celdaTotal('TOTAL A FAVOR'),
          _celdaTotal(Fmt.moneda(totalDe(haber)), derecha: true),
          _celdaTotal('TOTAL DEUDAS'),
          _celdaTotal(Fmt.moneda(totalDe(debe)), derecha: true),
        ],
      ),
    ],
  );
}

pw.Widget _celdaTitulo(String texto) => pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(texto,
          style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white)),
    );

pw.Widget _celdaConcepto(String texto) => pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      child: pw.Text(texto,
          style: const pw.TextStyle(fontSize: 9.5, color: _gris)),
    );

pw.Widget _celdaMonto(double? monto) => pw.Container(
      alignment: pw.Alignment.centerRight,
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      child: pw.Text(monto == null ? '' : Fmt.moneda(monto),
          style: const pw.TextStyle(fontSize: 9.5, color: _gris)),
    );

pw.Widget _celdaTotal(String texto, {bool derecha = false}) => pw.Container(
      alignment: derecha ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(texto,
          style: pw.TextStyle(
              fontSize: 10, fontWeight: pw.FontWeight.bold, color: _gris)),
    );

pw.Widget _saldo({required DateTime fecha, required double saldo}) {
  final color = saldo < 0 ? _rojoNegativo : _verde;
  return pw.Container(
    padding: const pw.EdgeInsets.all(12),
    decoration: pw.BoxDecoration(
      color: _crema,
      border: pw.Border.all(color: color, width: 0.8),
      borderRadius: pw.BorderRadius.circular(6),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text('SALDO BALANCE NEGOCIO AL ${Fmt.fecha(fecha)}',
            style: pw.TextStyle(
                fontSize: 12, fontWeight: pw.FontWeight.bold, color: _gris)),
        pw.Text(Fmt.moneda(saldo),
            style: pw.TextStyle(
                fontSize: 14, fontWeight: pw.FontWeight.bold, color: color)),
      ],
    ),
  );
}
