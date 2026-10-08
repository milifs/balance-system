import 'dart:math';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/soporte.dart';

/// Acceso a los reclamos de soporte y a sus adjuntos.
class SoporteRepository {
  SoporteRepository(this._db);

  final SupabaseClient _db;

  static const String bucket = 'soporte-adjuntos';

  /// Vigencia de los links firmados: 90 días.
  ///
  /// Suficiente para que el link reenviado por WhatsApp siga sirviendo
  /// mientras el reclamo está vivo, y lo bastante corto para que caduque solo
  /// una vez cerrado. La bandeja siempre puede firmar uno nuevo.
  static const Duration vigenciaLink = Duration(days: 90);

  /// Crea el reclamo y devuelve la fila tal como quedó en la base.
  ///
  /// El `.select().single()` no es decorativo: es la única forma de saber qué
  /// número de ticket asignó la secuencia de Postgres (ver
  /// [Soporte.toInsertJson]).
  Future<Soporte> crear(Soporte soporte) async {
    final row =
        await _db.from('soportes').insert(soporte.toInsertJson()).select().single();
    return Soporte.fromJson(row);
  }

  /// Sube la captura y devuelve su **path** dentro del bucket.
  ///
  /// Se guarda el path y no la URL porque el bucket es privado: la URL se
  /// firma cada vez que hace falta. El nombre es un uuid para no filtrar el
  /// nombre original del archivo ni pisar subidas de otro reclamo.
  Future<String> subirAdjunto({
    required Uint8List bytes,
    required String nombreOriginal,
  }) async {
    final ext = _extension(nombreOriginal);
    final path = '${_uuidV4()}$ext';
    await _db.storage.from(bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: _contentType(ext)),
        );
    return path;
  }

  /// Link firmado para ver la captura. `null` si el reclamo no tiene adjunto.
  Future<String?> linkAdjunto(String? path) async {
    if (path == null || path.isEmpty) return null;
    return _db.storage
        .from(bucket)
        .createSignedUrl(path, vigenciaLink.inSeconds);
  }

  /// Todos los reclamos para la bandeja: bloqueantes primero, después por
  /// fecha desc.
  ///
  /// Se traen de una y se agrupan por estado en el cliente, así los tres tabs
  /// comparten una sola consulta y los contadores están bien desde el arranque
  /// sin tener que entrar a cada tab. El `limit` es un techo de cordura: son
  /// decenas de filas, no miles.
  Future<List<Soporte>> listTodos() async {
    final rows = await _db
        .from('soportes')
        .select()
        .order('bloqueante', ascending: false)
        .order('creado_en', ascending: false)
        .limit(300);
    return rows.map(Soporte.fromJson).toList();
  }

  /// Los últimos 5 reclamos de una persona, para "Tus reclamos".
  Future<List<Soporte>> misUltimos(String reportadoPor) async {
    final rows = await _db
        .from('soportes')
        .select()
        .eq('reportado_por', reportadoPor)
        .order('creado_en', ascending: false)
        .limit(5);
    return rows.map(Soporte.fromJson).toList();
  }

  /// Triage: cambia el estado y guarda la respuesta para el cliente.
  Future<void> actualizar({
    required String id,
    required EstadoSoporte estado,
    required String respuesta,
    required String resueltoPor,
  }) async {
    final cerrado = estado == EstadoSoporte.resuelto;
    await _db.from('soportes').update({
      'estado': estado.db,
      'respuesta': respuesta,
      // Al reabrir se limpian: si no, queda colgada la fecha de un cierre que
      // ya no vale.
      'resuelto_en': cerrado ? DateTime.now().toUtc().toIso8601String() : null,
      'resuelto_por': cerrado ? resueltoPor : null,
    }).eq('id', id);
  }
}

/// Extensión en minúsculas, con el punto. `''` si el archivo no tiene.
String _extension(String nombre) {
  final i = nombre.lastIndexOf('.');
  if (i < 0 || i == nombre.length - 1) return '';
  return nombre.substring(i).toLowerCase();
}

/// Content-type por extensión.
///
/// Se setea a mano porque el picker en web no siempre informa el mime, y el
/// bucket tiene `allowed_mime_types`: si sube como `application/octet-stream`
/// lo rechaza.
String _contentType(String ext) => switch (ext) {
      '.png' => 'image/png',
      '.webp' => 'image/webp',
      '.heic' => 'image/heic',
      '.heif' => 'image/heif',
      _ => 'image/jpeg',
    };

String _uuidV4() {
  final rnd = Random.secure();
  final bytes = List<int>.generate(16, (_) => rnd.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40; // versión 4
  bytes[8] = (bytes[8] & 0x3f) | 0x80; // variante RFC 4122
  final hex =
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}
