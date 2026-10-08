import 'package:balance_system/auth/domain/app_profile.dart';
import 'package:balance_system/core/router/modules.dart';
import 'package:balance_system/features/soporte/domain/soporte.dart';
import 'package:balance_system/features/soporte/domain/soporte_whatsapp.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

Soporte _reclamo({
  int numero = 1,
  bool bloqueante = false,
  String modulo = 'Carga',
}) =>
    Soporte(
      numero: numero,
      modulo: modulo,
      descripcion: 'Quise cargar una venta y me tiró un error.',
      bloqueante: bloqueante,
      reportadoPor: 'Mili',
      rol: 'cajera',
      appVersion: '1.0.0+1',
      plataforma: 'Web · macOS · 1512x857',
      creadoEn: DateTime(2026, 10, 7, 15, 30),
    );

void main() {
  setUpAll(() => initializeDateFormatting('es_AR', null));

  group('numeración', () {
    test('el insert omite numero para que lo asigne la secuencia', () {
      // Mandarlo calculado desde el cliente abre una carrera entre dos
      // personas reportando a la vez.
      final json = _reclamo(numero: 0).toInsertJson();
      expect(json.containsKey('numero'), isFalse);
    });

    test('un numero ya asignado sí viaja', () {
      expect(_reclamo(numero: 7).toInsertJson()['numero'], 7);
    });

    test('el codigo se arma con 4 dígitos', () {
      expect(_reclamo(numero: 1).codigo, 'S-0001');
      expect(_reclamo(numero: 1234).codigo, 'S-1234');
    });
  });

  group('adjunto', () {
    test('en la tabla se guarda el path, nunca la URL', () {
      final json = Soporte(
        modulo: 'Pesaje',
        descripcion: 'x',
        adjuntoPath: 'a1b2c3d4-0000-4000-8000-000000000000.jpg',
      ).toInsertJson();
      expect(json['adjunto_path'], endsWith('.jpg'));
      expect(json['adjunto_path'], isNot(contains('http')));
    });
  });

  group('catálogo de módulos', () {
    test('ofrece todas las pantallas reales más "Otro"', () {
      for (final m in modulos) {
        expect(modulosSoporte, contains(m.label));
      }
      expect(modulosSoporte.last, 'Otro');
    });
  });

  group('navegación de Soporte', () {
    test('reportar no depende de los permisos de la cajera', () {
      // Si estuviera en modulosConfigurables, el admin podría apagárselo
      // justo a quien necesita avisar que no puede trabajar.
      final configurables = modulosConfigurables.map((m) => m.ruta);
      expect(configurables, isNot(contains(rutaSoporte)));
      expect(modulosSoportePara(Rol.cajera).map((m) => m.ruta),
          [rutaSoporte]);
    });

    test('la bandeja es solo del admin', () {
      expect(modulosSoportePara(Rol.admin).map((m) => m.ruta),
          [rutaSoporte, rutaSoporteBandeja]);
      expect(modulosSoportePara(Rol.cajera).map((m) => m.ruta),
          isNot(contains(rutaSoporteBandeja)));
    });
  });

  group('mensaje de WhatsApp', () {
    test('marca URGENTE cuando es bloqueante', () {
      expect(mensajeWhatsapp(_reclamo(bloqueante: true)), contains('URGENTE'));
      expect(mensajeWhatsapp(_reclamo()), isNot(contains('URGENTE')));
    });

    test('lleva todo el contexto que capturó la app', () {
      final texto = mensajeWhatsapp(_reclamo());
      expect(texto, contains('S-0001'));
      expect(texto, contains('Carga'));
      expect(texto, contains('Mili'));
      expect(texto, contains('1.0.0+1'));
      expect(texto, contains('Web · macOS'));
      expect(texto, contains('07/10/2026 15:30'));
    });

    test('la foto viaja como link porque wa.me no adjunta archivos', () {
      final texto = mensajeWhatsapp(
        _reclamo(),
        linkAdjunto: 'https://x.supabase.co/storage/v1/object/sign/abc',
      );
      expect(texto, contains('Captura: https://x.supabase.co'));
    });

    test('sin adjunto no deja la línea de la captura vacía', () {
      expect(mensajeWhatsapp(_reclamo()), isNot(contains('Captura:')));
    });
  });

  group('uriWhatsapp', () {
    test('arma wa.me con el mensaje escapado', () {
      final uri = uriWhatsapp(numero: '5493515123456', mensaje: 'hola y chau');
      expect(uri.host, 'wa.me');
      expect(uri.path, '/5493515123456');
      expect(uri.queryParameters['text'], 'hola y chau');
      expect(uri.toString(), contains('hola+y+chau'));
    });
  });
}
