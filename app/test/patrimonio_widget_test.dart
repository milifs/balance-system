import 'package:balance_system/core/models/patrimonio.dart';
import 'package:balance_system/features/patrimonio/application/patrimonio_providers.dart';
import 'package:balance_system/features/patrimonio/data/patrimonio_repository.dart';
import 'package:balance_system/features/patrimonio/presentation/patrimonio_pdf.dart';
import 'package:balance_system/features/patrimonio/presentation/sections/carga_patrimonio_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Repo de mentira: devuelve un cuadro guardado y se queda con lo que se
/// manda a guardar, para poder mirarlo desde el test.
class _RepoFalso implements PatrimonioRepository {
  _RepoFalso(this.guardado);

  final Patrimonio? guardado;
  List<PatrimonioItem>? ultimoGuardado;

  @override
  Future<Patrimonio?> porFecha(DateTime fecha) async => guardado;

  @override
  Future<List<Patrimonio>> listPatrimonios() async =>
      guardado == null ? [] : [guardado!];

  @override
  Future<String> guardar({
    required DateTime fecha,
    required List<PatrimonioItem> items,
  }) async {
    ultimoGuardado = items;
    return 'p1';
  }

  @override
  Future<void> eliminar(String id) async {}
}

Patrimonio _cuadro() => Patrimonio.fromJson({
      'id': 'p1',
      'fecha': DateTime.now().toIso8601String().split('T').first,
      'patrimonio_items': [
        {'lado': 'haber', 'orden': 0, 'concepto': 'EFECTIVO', 'monto': 8000000},
        {'lado': 'haber', 'orden': 1, 'concepto': 'BANCO BBVA', 'monto': 2493968},
        {'lado': 'debe', 'orden': 0, 'concepto': 'NINO PEREZ', 'monto': 46769000},
      ],
    });

Future<_RepoFalso> _pump(WidgetTester tester, {Patrimonio? guardado}) async {
  final repo = _RepoFalso(guardado);
  await tester.binding.setSurfaceSize(const Size(1400, 900));
  await tester.pumpWidget(ProviderScope(
    overrides: [patrimonioRepositoryProvider.overrideWithValue(repo)],
    child: const MaterialApp(
      home: Scaffold(body: CargaPatrimonioSection()),
    ),
  ));
  await tester.pumpAndSettle();
  return repo;
}

void main() {
  setUpAll(() => initializeDateFormatting('es_AR', null));

  testWidgets('abre la fecha con lo que ya estaba guardado', (tester) async {
    await _pump(tester, guardado: _cuadro());

    expect(find.text('EFECTIVO'), findsOneWidget);
    expect(find.text('NINO PEREZ'), findsOneWidget);
    // Los dos totales y el saldo, calculados sobre lo cargado.
    expect(find.text('10.493.968 \$'), findsOneWidget); // TOTAL A FAVOR
    expect(find.text('46.769.000 \$'), findsOneWidget); // TOTAL DEUDAS
    expect(find.text('-36.275.032 \$'), findsOneWidget); // saldo
  });

  testWidgets('el total y el saldo se recalculan mientras se tipea',
      (tester) async {
    await _pump(tester, guardado: _cuadro());

    await tester.enterText(find.text('8000000'), '9000000');
    await tester.pumpAndSettle();

    expect(find.text('11.493.968 \$'), findsOneWidget);
    expect(find.text('-35.275.032 \$'), findsOneWidget);
  });

  testWidgets('guarda solo las filas escritas, en orden y por lado',
      (tester) async {
    final repo = await _pump(tester, guardado: _cuadro());

    await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
    await tester.pumpAndSettle();

    final items = repo.ultimoGuardado!;
    // Las 5 filas en blanco que ofrece la pantalla no se guardan.
    expect(items.length, 3);
    expect(
      items.map((i) => '${i.lado.name}:${i.orden}:${i.concepto}'),
      ['haber:0:EFECTIVO', 'haber:1:BANCO BBVA', 'debe:0:NINO PEREZ'],
    );
  });

  testWidgets('un monto que no se entiende frena el guardado', (tester) async {
    final repo = await _pump(tester, guardado: _cuadro());

    await tester.enterText(find.text('8000000'), 'dos mil');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
    await tester.pumpAndSettle();

    expect(repo.ultimoGuardado, isNull);
    expect(find.textContaining('monto que no se entiende'), findsOneWidget);
  });

  testWidgets('una fecha sin cuadro arranca vacía y en cero', (tester) async {
    await _pump(tester);

    expect(find.text('0 \$'), findsNWidgets(3)); // los dos totales y el saldo
    expect(find.textContaining('ya tiene un cuadro'), findsNothing);
  });

  test('el PDF se arma con las dos columnas de distinto largo', () async {
    // El cuadro es una sola tabla de 4 columnas: el lado más corto se
    // completa con celdas vacías y el armado no se cae.
    final doc = construirPatrimonioPdf(
      fecha: DateTime(2025, 12, 4),
      haber: _cuadro().haber,
      debe: _cuadro().debe,
    );
    final bytes = await doc.save();
    expect(bytes.length, greaterThan(0));
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });
}
