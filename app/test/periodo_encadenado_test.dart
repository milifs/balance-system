import 'package:balance_system/core/models/periodo.dart';
import 'package:balance_system/features/carga/domain/periodo_encadenado.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

Periodo _p(String id, DateTime inicio, DateTime fin) =>
    Periodo(id: id, sucursalId: 'chacho-1', fechaInicio: inicio, fechaFin: fin);

/// Enero (6-ene al 5-feb) y febrero (6-feb al 5-mar), pegados.
final _enero = _p('ene', DateTime(2026, 1, 6), DateTime(2026, 2, 5));
final _febrero = _p('feb', DateTime(2026, 2, 6), DateTime(2026, 3, 5));

void main() {
  // Los mensajes llevan fechas formateadas.
  setUpAll(() => initializeDateFormatting('es_AR', null));

  group('errorDeEncadenado', () {
    test('el primer período de la sucursal puede empezar cualquier día', () {
      expect(
        errorDeEncadenado(
            otros: const [],
            inicio: DateTime(2026, 1, 6),
            fin: DateTime(2026, 2, 5)),
        isNull,
      );
    });

    test('arrancar el día siguiente al cierre anterior está bien', () {
      expect(
        errorDeEncadenado(
            otros: [_enero],
            inicio: DateTime(2026, 2, 6),
            fin: DateTime(2026, 3, 5)),
        isNull,
      );
    });

    test('empezar el mismo día que cerró el anterior es pisarse', () {
      expect(
        errorDeEncadenado(
            otros: [_enero],
            inicio: DateTime(2026, 2, 5),
            fin: DateTime(2026, 3, 5)),
        contains('Se pisa'),
      );
    });

    test('dejar un hueco avisa con la fecha que corresponde', () {
      final e = errorDeEncadenado(
          otros: [_enero],
          inicio: DateTime(2026, 2, 10),
          fin: DateTime(2026, 3, 5));
      expect(e, contains('06/02/2026'));
    });

    test('editar el del medio tiene que cerrar pegado al que sigue', () {
      // Se intenta estirar enero hasta el 10-feb, con febrero ya cargado.
      final e = errorDeEncadenado(
          otros: [_febrero],
          inicio: DateTime(2026, 1, 6),
          fin: DateTime(2026, 2, 10));
      expect(e, contains('Se pisa'));
    });

    test('acortar el del medio deja un hueco y también avisa', () {
      final e = errorDeEncadenado(
          otros: [_febrero],
          inicio: DateTime(2026, 1, 6),
          fin: DateTime(2026, 2, 1));
      expect(e, contains('05/02/2026'));
    });

    test('el cierre no puede ser anterior al inicio', () {
      expect(
        errorDeEncadenado(
            otros: const [],
            inicio: DateTime(2026, 3, 5),
            fin: DateTime(2026, 2, 6)),
        contains('no puede ser anterior'),
      );
    });

    test('la hora no cuenta: compara días', () {
      expect(
        errorDeEncadenado(
          otros: [_enero],
          inicio: DateTime(2026, 2, 6, 23, 59),
          fin: DateTime(2026, 3, 5, 8, 30),
        ),
        isNull,
      );
    });
  });
}
