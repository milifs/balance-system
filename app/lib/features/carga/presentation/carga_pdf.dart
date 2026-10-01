import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/formatters/formatters.dart';
import '../../../core/models/compra.dart';
import '../../../core/models/gasto.dart';
import '../../../core/models/medio_pago.dart';
import '../../../core/models/periodo.dart';
import '../../../core/models/sucursal.dart';
import '../../../core/models/tipo_gasto.dart';
import '../../../core/models/venta.dart';

/// Colores de marca replicados para el PDF (los `AppColors` son `dart:ui`
/// y acá necesitamos `PdfColor`).
const _rojo = PdfColor.fromInt(0xFF8B1E1E);
const _crema = PdfColor.fromInt(0xFFF7F3EE);
const _gris = PdfColor.fromInt(0xFF2B2B2B);
const _grisClaro = PdfColor.fromInt(0xFF777777);

final _emision = DateFormat('dd/MM/yyyy HH:mm', 'es_AR');

/// Genera el PDF con todo lo cargado en un período (ventas, compras, gastos)
/// y dispara la descarga/compartir en el navegador.
Future<void> exportarCargaPdf({
  required Sucursal sucursal,
  required Periodo periodo,
  required List<Venta> ventas,
  required Map<String, MedioPago> medios,
  required List<Compra> compras,
  required Map<String, TipoGasto> tipos,
  required List<Gasto> gastos,
}) async {
  final doc = _construir(
    sucursal: sucursal,
    periodo: periodo,
    ventas: ventas,
    medios: medios,
    compras: compras,
    tipos: tipos,
    gastos: gastos,
  );
  await Printing.sharePdf(
    bytes: await doc.save(),
    filename: _nombreArchivo(sucursal, periodo),
  );
}

String _nombreArchivo(Sucursal s, Periodo p) {
  String slug(String v) => v
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  final ini = DateFormat('yyyyMMdd').format(p.fechaInicio);
  final fin = DateFormat('yyyyMMdd').format(p.fechaFin);
  return 'carga_${slug(s.nombre)}_${ini}_$fin.pdf';
}

pw.Document _construir({
  required Sucursal sucursal,
  required Periodo periodo,
  required List<Venta> ventas,
  required Map<String, MedioPago> medios,
  required List<Compra> compras,
  required Map<String, TipoGasto> tipos,
  required List<Gasto> gastos,
}) {
  // Ordenados por fecha ascendente para que el reporte se lea cronológico.
  final vs = [...ventas]..sort((a, b) => a.fecha.compareTo(b.fecha));
  final cs = [...compras]..sort((a, b) => a.fecha.compareTo(b.fecha));
  final gs = [...gastos]..sort((a, b) => a.fecha.compareTo(b.fecha));

  double ventasBruto = 0;
  double ventasNeto = 0;
  for (final v in vs) {
    final ret = medios[v.medioPagoId]?.retencionPct ?? 0;
    ventasBruto += v.monto;
    ventasNeto += v.monto * (1 - ret / 100);
  }
  final comprasTotal = cs.fold<double>(0, (s, c) => s + c.monto);
  final gastosTotal = gs.fold<double>(0, (s, g) => s + g.monto);

  final doc = pw.Document(
    title: 'Carga ${sucursal.nombre}',
    author: 'Don Chacho',
  );

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(32, 32, 32, 36),
      header: (ctx) => ctx.pageNumber == 1
          ? _encabezado(sucursal, periodo)
          : pw.SizedBox(),
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
        _tituloSeccion('Ventas por medio de pago'),
        _tablaVentas(vs, medios),
        _subtotalDoble('Total ventas', ventasBruto, ventasNeto),
        pw.SizedBox(height: 18),
        _tituloSeccion('Compras a proveedores'),
        _tablaCompras(cs),
        _subtotal('Total compras', comprasTotal),
        pw.SizedBox(height: 18),
        _tituloSeccion('Gastos'),
        _tablaGastos(gs, tipos),
        _subtotal('Total gastos', gastosTotal),
        pw.SizedBox(height: 22),
        _resumen(
          ventasBruto: ventasBruto,
          ventasNeto: ventasNeto,
          comprasTotal: comprasTotal,
          gastosTotal: gastosTotal,
        ),
      ],
    ),
  );

  return doc;
}

pw.Widget _encabezado(Sucursal sucursal, Periodo periodo) {
  final estado =
      periodo.estado == EstadoPeriodo.abierto ? 'Abierto' : 'Cerrado';
  return pw.Container(
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
            pw.Text('Carga del período · ${sucursal.nombre}',
                style: const pw.TextStyle(fontSize: 12, color: _gris)),
            pw.SizedBox(height: 1),
            pw.Text(
              '${Fmt.fecha(periodo.fechaInicio)} – ${Fmt.fecha(periodo.fechaFin)}  ·  $estado',
              style: const pw.TextStyle(fontSize: 10, color: _grisClaro),
            ),
          ],
        ),
        pw.Text('Emitido ${_emision.format(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 9, color: _grisClaro)),
      ],
    ),
  );
}

pw.Widget _tituloSeccion(String texto) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Text(texto,
          style: pw.TextStyle(
              fontSize: 13, fontWeight: pw.FontWeight.bold, color: _gris)),
    );

pw.Widget _tablaVentas(List<Venta> ventas, Map<String, MedioPago> medios) {
  if (ventas.isEmpty) return _vacio('Sin ventas cargadas.');
  final rows = <List<String>>[];
  for (final v in ventas) {
    final m = medios[v.medioPagoId];
    final ret = m?.retencionPct ?? 0;
    final neto = v.monto * (1 - ret / 100);
    rows.add([
      Fmt.fecha(v.fecha),
      m?.nombre ?? 'Medio desconocido',
      ret > 0 ? Fmt.pct(ret) : '—',
      Fmt.moneda(v.monto),
      Fmt.moneda(neto),
    ]);
  }
  return _tabla(
    headers: ['Fecha', 'Medio de pago', 'Retención', 'Bruto', 'Neto'],
    rows: rows,
    alineacionDerecha: {2, 3, 4},
    anchos: {
      0: const pw.FixedColumnWidth(70),
      2: const pw.FixedColumnWidth(65),
      3: const pw.FixedColumnWidth(90),
      4: const pw.FixedColumnWidth(90),
    },
  );
}

pw.Widget _tablaCompras(List<Compra> compras) {
  if (compras.isEmpty) return _vacio('Sin compras cargadas.');
  final rows = compras
      .map((c) => [
            Fmt.fecha(c.fecha),
            c.tipoCompra.label,
            (c.proveedor ?? '').trim().isEmpty ? '—' : c.proveedor!.trim(),
            Fmt.moneda(c.monto),
          ])
      .toList();
  return _tabla(
    headers: ['Fecha', 'Tipo', 'Proveedor', 'Monto'],
    rows: rows,
    alineacionDerecha: {3},
    anchos: {
      0: const pw.FixedColumnWidth(70),
      1: const pw.FixedColumnWidth(70),
      3: const pw.FixedColumnWidth(95),
    },
  );
}

pw.Widget _tablaGastos(List<Gasto> gastos, Map<String, TipoGasto> tipos) {
  if (gastos.isEmpty) return _vacio('Sin gastos cargados.');
  final rows = gastos
      .map((g) => [
            Fmt.fecha(g.fecha),
            tipos[g.tipoGastoId]?.nombre ?? 'Gasto',
            Fmt.moneda(g.monto),
          ])
      .toList();
  return _tabla(
    headers: ['Fecha', 'Concepto', 'Monto'],
    rows: rows,
    alineacionDerecha: {2},
    anchos: {
      0: const pw.FixedColumnWidth(70),
      2: const pw.FixedColumnWidth(95),
    },
  );
}

pw.Widget _tabla({
  required List<String> headers,
  required List<List<String>> rows,
  required Set<int> alineacionDerecha,
  Map<int, pw.TableColumnWidth>? anchos,
}) {
  final cellAlign = <int, pw.Alignment>{
    for (var i = 0; i < headers.length; i++)
      i: alineacionDerecha.contains(i)
          ? pw.Alignment.centerRight
          : pw.Alignment.centerLeft,
  };
  return pw.TableHelper.fromTextArray(
    headers: headers,
    data: rows,
    border: null,
    headerStyle: pw.TextStyle(
        fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
    headerDecoration: const pw.BoxDecoration(color: _rojo),
    cellStyle: const pw.TextStyle(fontSize: 10, color: _gris),
    rowDecoration:
        const pw.BoxDecoration(color: PdfColor.fromInt(0xFFFFFFFF)),
    oddRowDecoration: const pw.BoxDecoration(color: _crema),
    cellHeight: 18,
    headerAlignments: cellAlign,
    cellAlignments: cellAlign,
    columnWidths: anchos,
    headerPadding:
        const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
    cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
  );
}

pw.Widget _vacio(String texto) => pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      child: pw.Text(texto,
          style: const pw.TextStyle(
              fontSize: 10, color: _grisClaro, fontStyle: pw.FontStyle.italic)),
    );

pw.Widget _subtotal(String etiqueta, double valor) => pw.Container(
      margin: const pw.EdgeInsets.only(top: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Text('$etiqueta:  ',
              style: pw.TextStyle(
                  fontSize: 11, fontWeight: pw.FontWeight.bold, color: _gris)),
          pw.Text(Fmt.moneda(valor),
              style: pw.TextStyle(
                  fontSize: 11, fontWeight: pw.FontWeight.bold, color: _gris)),
        ],
      ),
    );

pw.Widget _subtotalDoble(String etiqueta, double bruto, double neto) =>
    pw.Container(
      margin: const pw.EdgeInsets.only(top: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Text('$etiqueta — bruto ',
              style: pw.TextStyle(
                  fontSize: 11, fontWeight: pw.FontWeight.bold, color: _gris)),
          pw.Text(Fmt.moneda(bruto),
              style: pw.TextStyle(
                  fontSize: 11, fontWeight: pw.FontWeight.bold, color: _gris)),
          pw.Text('   ·   neto ',
              style: pw.TextStyle(
                  fontSize: 11, fontWeight: pw.FontWeight.bold, color: _gris)),
          pw.Text(Fmt.moneda(neto),
              style: pw.TextStyle(
                  fontSize: 11, fontWeight: pw.FontWeight.bold, color: _gris)),
        ],
      ),
    );

pw.Widget _resumen({
  required double ventasBruto,
  required double ventasNeto,
  required double comprasTotal,
  required double gastosTotal,
}) {
  pw.Widget fila(String l, String v, {bool bold = false}) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(l,
                style: pw.TextStyle(
                    fontSize: 11,
                    color: _gris,
                    fontWeight:
                        bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
            pw.Text(v,
                style: pw.TextStyle(
                    fontSize: 11,
                    color: _gris,
                    fontWeight:
                        bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          ],
        ),
      );
  return pw.Container(
    padding: const pw.EdgeInsets.all(12),
    decoration: pw.BoxDecoration(
      color: _crema,
      border: pw.Border.all(color: _rojo, width: 0.8),
      borderRadius: pw.BorderRadius.circular(6),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Text('Resumen del período',
            style: pw.TextStyle(
                fontSize: 12, fontWeight: pw.FontWeight.bold, color: _rojo)),
        pw.SizedBox(height: 6),
        fila('Ventas (bruto)', Fmt.moneda(ventasBruto)),
        fila('Ventas (neto)', Fmt.moneda(ventasNeto), bold: true),
        fila('Compras a proveedores', Fmt.moneda(comprasTotal)),
        fila('Gastos', Fmt.moneda(gastosTotal)),
      ],
    ),
  );
}
