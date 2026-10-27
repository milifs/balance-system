import 'package:balance_system/features/precios_rinde/domain/rinde_kgr.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  // Los avisos llevan kilos y porcentajes formateados.
  setUpAll(() => initializeDateFormatting('es_AR', null));

  group('avisoDeKgr', () {
    test('un despiece con merma normal no dice nada', () {
      // Media res de 111 kg que rinde 105: 5,4% de merma.
      expect(avisoDeKgr(kgRindeTotal: 105, piezaBaseKg: 111), isNull);
    });

    test('los cortes no pueden sumar más que la pieza', () {
      expect(avisoDeKgr(kgRindeTotal: 120, piezaBaseKg: 111),
          contains('más que'));
    });

    test('una merma demasiado grande avisa', () {
      // Típico KGR tipeado 10 en vez de 100.
      final a = avisoDeKgr(kgRindeTotal: 40, piezaBaseKg: 111);
      expect(a, contains('merma'));
      expect(a, contains('Revisá los KGR'));
    });

    test('el aviso aparece al pasar el límite de merma', () {
      // El límite es 15%: 94,4 kg de 111 es 14,95% y 94 kg es 15,3%.
      expect(avisoDeKgr(kgRindeTotal: 94.4, piezaBaseKg: 111), isNull);
      expect(avisoDeKgr(kgRindeTotal: 94, piezaBaseKg: 111), isNotNull);
    });

    test('sin pieza base cargada no hay con qué comparar', () {
      expect(avisoDeKgr(kgRindeTotal: 105, piezaBaseKg: null), isNull);
      expect(avisoDeKgr(kgRindeTotal: 105, piezaBaseKg: 0), isNull);
    });

    test('una categoría sin KGR cargados todavía no avisa', () {
      expect(avisoDeKgr(kgRindeTotal: 0, piezaBaseKg: 111), isNull);
    });
  });

  group('merma', () {
    test('los kilos que no quedaron en los cortes', () {
      expect(mermaKg(kgRindeTotal: 105, piezaBaseKg: 111), closeTo(6, 0.001));
      expect(mermaKg(kgRindeTotal: 105, piezaBaseKg: null), isNull);
    });

    test('el porcentaje sobre la pieza base', () {
      expect(mermaPct(kgRindeTotal: 105, piezaBaseKg: 111),
          closeTo(5.405, 0.001));
      expect(mermaPct(kgRindeTotal: 105, piezaBaseKg: 0), isNull);
    });

    test('si los cortes pasan la pieza, la merma es negativa', () {
      expect(mermaKg(kgRindeTotal: 120, piezaBaseKg: 111), closeTo(-9, 0.001));
    });
  });
}
