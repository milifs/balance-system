import '../../../core/formatters/formatters.dart';
import '../../../core/supabase/env.dart';
import 'soporte.dart';

/// Texto del aviso que se manda por WhatsApp.
///
/// WhatsApp **no puede adjuntar archivos** por `wa.me`: por eso la captura va
/// a Storage y viaja acá como link firmado dentro del texto.
///
/// El nombre del cliente va primero porque el mismo número de soporte atiende
/// varias instalaciones y hay que saber de cuál viene el reclamo.
String mensajeWhatsapp(Soporte s, {String? linkAdjunto}) {
  final lineas = <String>[
    '*Reclamo ${s.codigo}* · ${Env.clienteNombre}',
    if (s.bloqueante) '*URGENTE: no puede seguir trabajando*',
    '',
    'Módulo: ${s.modulo}',
    '',
    s.descripcion,
    '',
    if (linkAdjunto != null) 'Captura: $linkAdjunto',
    if (linkAdjunto != null) '',
    'Usuario: ${s.reportadoPor ?? '—'}${s.rol == null ? '' : ' (${s.rol})'}',
    'Fecha: ${Fmt.fechaHora(s.creadoEn ?? DateTime.now())}',
    'Versión: ${s.appVersion ?? '—'}',
    'Plataforma: ${s.plataforma ?? '—'}',
  ];
  return lineas.join('\n');
}

/// URI de `wa.me` con el mensaje ya escrito.
Uri uriWhatsapp({required String numero, required String mensaje}) {
  return Uri.https('wa.me', '/$numero', {'text': mensaje});
}
