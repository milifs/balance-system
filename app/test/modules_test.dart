import 'package:balance_system/auth/domain/app_profile.dart';
import 'package:balance_system/core/router/modules.dart';
import 'package:flutter_test/flutter_test.dart';

/// Permisos tal como vienen de la base: todo apagado.
Map<String, bool> _nada() => {
      for (final m in modulosConfigurables) m.ruta: false,
      for (final s in seccionesConfigurables) s.ruta: false,
    };

void main() {
  group('modulosPara', () {
    test('el admin ve los 6 módulos sin importar los permisos', () {
      expect(modulosPara(Rol.admin, _nada()), modulos);
    });

    test('la cajera sin permisos no ve nada', () {
      expect(modulosPara(Rol.cajera, _nada()), isEmpty);
    });

    test('la cajera ve solo los módulos habilitados', () {
      final p = _nada()..['/carga'] = true;
      expect(modulosPara(Rol.cajera, p).map((m) => m.ruta), ['/carga']);
    });

    test('Configuración no se habilita con un switch propio', () {
      // Aunque alguien escriba la fila a mano en la base, no alcanza:
      // Configuración depende de sus secciones, no de su propia ruta.
      final p = _nada()..[rutaConfiguracion] = true;
      expect(modulosPara(Rol.cajera, p), isEmpty);
    });

    test('Configuración aparece sola si hay una sección habilitada', () {
      final p = _nada()..['$rutaConfiguracion/tipos-gasto'] = true;
      expect(
          modulosPara(Rol.cajera, p).map((m) => m.ruta), [rutaConfiguracion]);
    });

    test('Configuración desaparece al apagar la última sección', () {
      final p = _nada()..['$rutaConfiguracion/tipos-gasto'] = true;
      expect(modulosPara(Rol.cajera, p), isNotEmpty);
      p['$rutaConfiguracion/tipos-gasto'] = false;
      expect(modulosPara(Rol.cajera, p), isEmpty);
    });

    test('respeta el orden de navegación', () {
      final p = _nada()
        ..['/pesaje'] = true
        ..['/carga'] = true;
      expect(modulosPara(Rol.cajera, p).map((m) => m.ruta),
          ['/carga', '/pesaje']);
    });
  });

  group('seccionesPara', () {
    test('el admin ve las 6 secciones, incluida Permisos', () {
      expect(seccionesPara(Rol.admin, _nada()), seccionesConfig);
    });

    test('la cajera nunca ve Permisos, ni forzando el permiso', () {
      final p = _nada()..['$rutaConfiguracion/permisos'] = true;
      expect(
        seccionesPara(Rol.cajera, p).map((s) => s.ruta),
        isNot(contains('$rutaConfiguracion/permisos')),
      );
    });

    test('la cajera ve solo las secciones habilitadas', () {
      final p = _nada()..['$rutaConfiguracion/medios-pago'] = true;
      expect(seccionesPara(Rol.cajera, p).map((s) => s.ruta),
          ['$rutaConfiguracion/medios-pago']);
    });

    test('Permisos queda fuera de las secciones configurables', () {
      expect(
        seccionesConfigurables.map((s) => s.ruta),
        isNot(contains('$rutaConfiguracion/permisos')),
      );
    });
  });

  group('rutaInicio', () {
    test('null si la cajera no tiene nada', () {
      expect(rutaInicio(Rol.cajera, _nada()), isNull);
    });

    test('cae en Configuración si es lo único que tiene', () {
      final p = _nada()..['$rutaConfiguracion/cortes'] = true;
      expect(rutaInicio(Rol.cajera, p), rutaConfiguracion);
    });
  });
}
