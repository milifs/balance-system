import 'package:balance_system/core/models/periodo.dart';
import 'package:balance_system/features/carga/presentation/widgets/carga_ui.dart';
import 'package:flutter_test/flutter_test.dart';

/// Período del 6 de febrero al 5 de marzo de 2026.
final _febrero = Periodo(
  id: 'feb',
  sucursalId: 'chacho-1',
  fechaInicio: DateTime(2026, 2, 6),
  fechaFin: DateTime(2026, 3, 5),
);

void main() {
  group('fechaDentroDelPeriodo', () {
    test('una fecha de adentro queda como está', () {
      expect(fechaDentroDelPeriodo(_febrero, DateTime(2026, 2, 20)),
          DateTime(2026, 2, 20));
    });

    test('cargar después del cierre no manda la fecha afuera', () {
      // Cargan el 12 de marzo lo que faltaba de febrero.
      expect(fechaDentroDelPeriodo(_febrero, DateTime(2026, 3, 12)),
          _febrero.fechaFin);
    });

    test('una fecha anterior al período se corre al inicio', () {
      expect(fechaDentroDelPeriodo(_febrero, DateTime(2026, 1, 30)),
          _febrero.fechaInicio);
    });

    test('los dos bordes son parte del período', () {
      expect(fechaDentroDelPeriodo(_febrero, _febrero.fechaInicio),
          _febrero.fechaInicio);
      expect(fechaDentroDelPeriodo(_febrero, _febrero.fechaFin),
          _febrero.fechaFin);
    });
  });
}
