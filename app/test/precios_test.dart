import 'package:balance_system/core/models/precio.dart';
import 'package:balance_system/features/precios_rinde/data/precios_rinde_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// Precio de un corte con su historial: actual 10.000, último 8.000,
/// penúltimo 6.000.
const _pierna = Precio(
  corteId: 'pierna',
  actual: 10000,
  ultimo: 8000,
  penultimo: 6000,
);

void main() {
  group('rotacionSiCambio', () {
    test('el campo vacío deja el corte como está', () {
      expect(
        rotacionSiCambio(corteId: 'pierna', nuevo: null, precio: _pierna),
        isNull,
      );
    });

    test('repetir el precio actual no rota el historial', () {
      // Apretar "Guardar" dos veces seguidas pisaba el último con el actual.
      expect(
        rotacionSiCambio(corteId: 'pierna', nuevo: 10000, precio: _pierna),
        isNull,
      );
    });

    test('un precio nuevo corre los tres escalones', () {
      final r = rotacionSiCambio(
          corteId: 'pierna', nuevo: 12000, precio: _pierna)!;
      expect(r.corteId, 'pierna');
      expect(r.nuevoActual, 12000);
      expect(r.nuevoUltimo, 10000);
      expect(r.nuevoPenultimo, 8000);
    });

    test('un corte sin precio cargado estrena el actual, sin historial', () {
      final r = rotacionSiCambio(
          corteId: 'nuevo',
          nuevo: 5000,
          precio: const Precio(corteId: 'nuevo'))!;
      expect(r.nuevoActual, 5000);
      expect(r.nuevoUltimo, isNull);
      expect(r.nuevoPenultimo, isNull);
    });

    test('un corte que todavía no tiene fila de precios también se guarda', () {
      final r =
          rotacionSiCambio(corteId: 'nuevo', nuevo: 5000, precio: null)!;
      expect(r.nuevoActual, 5000);
      expect(r.nuevoUltimo, isNull);
    });
  });
}
