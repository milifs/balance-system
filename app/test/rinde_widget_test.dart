import 'package:balance_system/core/models/categoria.dart';
import 'package:balance_system/core/models/corte.dart';
import 'package:balance_system/core/models/precio.dart';
import 'package:balance_system/features/precios_rinde/presentation/widgets/categoria_precios_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

const _carne = Categoria(
  id: 'cat-carne',
  nombre: 'Carne',
  orden: 1,
  piezaBaseNombre: 'Media Res',
  piezaBaseKg: 111,
  piezaBaseCostoKg: 10400,
);

const _pierna = Corte(
  id: 'pierna',
  categoriaId: 'cat-carne',
  nombre: 'Pierna',
  kgrRinde: 40,
);

Future<void> _pump(WidgetTester tester, double kgr) async {
  await tester.binding.setSurfaceSize(const Size(1400, 900));
  await tester.pumpWidget(ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: CategoriaPreciosView(
          categoria: _carne,
          cortes: [_pierna.copyWith(kgrRinde: kgr)],
          precios: const {'pierna': Precio(corteId: 'pierna', actual: 7700)},
          esAdmin: false,
        ),
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => initializeDateFormatting('es_AR', null));

  testWidgets('el pie muestra la merma y avisa si los KGR no cierran',
      (tester) async {
    await _pump(tester, 40);
    expect(find.textContaining('Merma del despiece'), findsOneWidget);
    expect(find.textContaining('Revisá los KGR'), findsOneWidget);
  });

  testWidgets('con una merma normal no aparece el aviso', (tester) async {
    await _pump(tester, 105);
    expect(find.textContaining('Merma del despiece'), findsOneWidget);
    expect(find.textContaining('Revisá los KGR'), findsNothing);
  });
}
