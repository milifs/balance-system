import 'package:balance_system/auth/domain/app_profile.dart';
import 'package:balance_system/core/models/patrimonio.dart';
import 'package:balance_system/core/router/modules.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _item(String lado, int orden, String concepto, Object monto) =>
    {'lado': lado, 'orden': orden, 'concepto': concepto, 'monto': monto};

void main() {
  group('Patrimonio', () {
    test('suma cada columna y resta para el saldo', () {
      final p = Patrimonio.fromJson({
        'id': 'p1',
        'fecha': '2025-12-04',
        'patrimonio_items': [
          _item('haber', 0, 'EFECTIVO', 8000000),
          _item('haber', 1, 'BANCO BBVA', 2493968),
          _item('debe', 0, 'NINO PEREZ', 46769000),
        ],
      });

      expect(p.totalHaber, 10493968);
      expect(p.totalDebe, 46769000);
      expect(p.saldo, 10493968 - 46769000);
    });

    test('el saldo queda negativo cuando se debe más de lo que hay', () {
      final p = Patrimonio.fromJson({
        'id': 'p1',
        'fecha': '2025-12-04',
        'patrimonio_items': [
          _item('haber', 0, 'EFECTIVO', 100),
          _item('debe', 0, 'TARJETA', 250),
        ],
      });
      expect(p.saldo, -150);
    });

    test('lee los montos vengan como número o como string', () {
      // PostgREST puede devolver `numeric` de las dos formas.
      final p = Patrimonio.fromJson({
        'id': 'p1',
        'fecha': '2025-12-04',
        'patrimonio_items': [
          _item('haber', 0, 'EFECTIVO', '1234.56'),
          _item('haber', 1, 'BANCO', 1000),
        ],
      });
      expect(p.totalHaber, closeTo(2234.56, 0.001));
    });

    test('respeta el orden en que se escribieron las filas', () {
      // Llegan desordenadas desde la base: el cuadro se lee renglón contra
      // renglón, así que el orden de pantalla tiene que volver igual.
      final p = Patrimonio.fromJson({
        'id': 'p1',
        'fecha': '2025-12-04',
        'patrimonio_items': [
          _item('haber', 2, 'TERCERO', 3),
          _item('haber', 0, 'PRIMERO', 1),
          _item('haber', 1, 'SEGUNDO', 2),
        ],
      });
      expect(p.haber.map((i) => i.concepto), ['PRIMERO', 'SEGUNDO', 'TERCERO']);
    });

    test('un cuadro sin filas queda en cero, no rompe', () {
      final p = Patrimonio.fromJson({'id': 'p1', 'fecha': '2025-12-04'});
      expect(p.items, isEmpty);
      expect(p.totalHaber, 0);
      expect(p.totalDebe, 0);
      expect(p.saldo, 0);
    });

    test('cada fila vuelve al json como la espera el RPC', () {
      const item = PatrimonioItem(
        lado: LadoPatrimonio.debe,
        orden: 3,
        concepto: 'RENTAS',
        monto: 2790000,
      );
      expect(item.toJson(), {
        'lado': 'debe',
        'orden': 3,
        'concepto': 'RENTAS',
        'monto': 2790000,
      });
    });
  });

  group('Patrimonio en la navegación', () {
    test('el admin lo ve', () {
      expect(
        modulosPara(Rol.admin, const {}).map((m) => m.ruta),
        contains('/patrimonio'),
      );
    });

    test('la cajera no lo ve ni forzando el permiso en la base', () {
      // El cuadro mezcla el negocio con lo personal del dueño: no se habilita
      // con un switch, y la RLS de `patrimonios` igual pide `is_admin()`.
      final permisos = {'/patrimonio': true};
      expect(modulosPara(Rol.cajera, permisos), isEmpty);
    });

    test('no aparece entre los módulos configurables', () {
      expect(
        modulosConfigurables.map((m) => m.ruta),
        isNot(contains('/patrimonio')),
      );
    });
  });
}
