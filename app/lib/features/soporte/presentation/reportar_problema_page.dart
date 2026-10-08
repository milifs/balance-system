import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../auth/application/auth_providers.dart';
import '../../../core/formatters/formatters.dart';
import '../../../core/supabase/env.dart';
import '../../../core/theme/app_theme.dart';
import '../application/soporte_providers.dart';
import '../domain/contexto_app.dart';
import '../domain/soporte.dart';
import '../domain/soporte_whatsapp.dart';
import 'widgets/soporte_ui.dart';

/// Mínimo de caracteres de la descripción para poder enviar. "no anda" no
/// alcanza para arrancar a mirar nada.
const int _minDescripcion = 10;

/// "Reportar un problema": la pantalla que reemplaza al WhatsApp suelto.
///
/// No se gatea con permisos a propósito. El caso que más importa es
/// justamente el de alguien que no puede trabajar porque le falta un acceso:
/// si la pantalla dependiera de los permisos, esa persona no podría avisar.
class ReportarProblemaPage extends ConsumerStatefulWidget {
  const ReportarProblemaPage({super.key});

  @override
  ConsumerState<ReportarProblemaPage> createState() =>
      _ReportarProblemaPageState();
}

class _ReportarProblemaPageState extends ConsumerState<ReportarProblemaPage> {
  final _descripcion = TextEditingController();
  String? _modulo;
  bool _bloqueante = false;
  bool _enviando = false;

  Uint8List? _fotoBytes;
  String? _fotoNombre;

  @override
  void dispose() {
    _descripcion.dispose();
    super.dispose();
  }

  bool get _puedeEnviar =>
      !_enviando &&
      _modulo != null &&
      _descripcion.text.trim().length >= _minDescripcion;

  Future<void> _elegirFoto() async {
    final elegida = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1600,
    );
    if (elegida == null) return;
    final bytes = await elegida.readAsBytes();
    if (!mounted) return;
    setState(() {
      _fotoBytes = bytes;
      _fotoNombre = elegida.name;
    });
  }

  Future<void> _enviar() async {
    final profile = ref.read(currentProfileProvider).asData?.value;
    if (profile == null) return;

    setState(() => _enviando = true);
    final repo = ref.read(soporteRepositoryProvider);
    // Se lee antes de los awaits: después de subir la foto el context puede
    // haber quedado desmontado.
    final plataforma = plataformaActual(MediaQuery.of(context).size);

    // La foto es un plus: si falla la subida, el reclamo se manda igual y se
    // avisa. Perder el reclamo por una captura sería peor que no tenerla.
    String? adjuntoPath;
    var falloFoto = false;
    if (_fotoBytes != null) {
      try {
        adjuntoPath = await repo.subirAdjunto(
          bytes: _fotoBytes!,
          nombreOriginal: _fotoNombre ?? 'captura.jpg',
        );
      } catch (_) {
        falloFoto = true;
      }
    }

    final Soporte creado;
    try {
      creado = await repo.crear(Soporte(
        modulo: _modulo!,
        descripcion: _descripcion.text.trim(),
        bloqueante: _bloqueante,
        adjuntoPath: adjuntoPath,
        reportadoPor: ref.read(identidadUsuarioProvider),
        rol: profile.rol.name,
        appVersion: Env.appVersion,
        plataforma: plataforma,
      ));
    } catch (e) {
      // Si falla el insert no se sigue en silencio: sin ticket no hay reclamo.
      if (!mounted) return;
      setState(() => _enviando = false);
      _mensaje('No se pudo registrar el reclamo: $e', error: true);
      return;
    }

    // El URI se arma ACÁ, con el reclamo ya guardado, y no en el `onPressed`
    // del diálogo: firmar el link del adjunto es otra ida a la red, y el
    // launch de WhatsApp tiene que salir de un toque sin nada asincrónico en
    // el medio.
    final uri = await _armarUriWhatsapp(creado, adjuntoPath);

    ref.invalidate(misReclamosProvider);
    if (!mounted) return;
    setState(() {
      _enviando = false;
      _modulo = null;
      _descripcion.clear();
      _bloqueante = false;
      _fotoBytes = null;
      _fotoNombre = null;
    });
    await _dialogoRegistrado(creado, uri, falloFoto: falloFoto);
  }

  /// Arma el link de WhatsApp. Devuelve `null` si este deploy no tiene número
  /// de soporte configurado.
  Future<Uri?> _armarUriWhatsapp(Soporte creado, String? adjuntoPath) async {
    if (!Env.tieneWhatsappSoporte) return null;
    String? link;
    try {
      link = await ref.read(soporteRepositoryProvider).linkAdjunto(adjuntoPath);
    } catch (_) {
      // Sin link, el mensaje va igual: la captura queda en la bandeja.
      link = null;
    }
    return uriWhatsapp(
      numero: Env.soporteWhatsapp,
      mensaje: mensajeWhatsapp(creado, linkAdjunto: link),
    );
  }

  Future<void> _dialogoRegistrado(
    Soporte creado,
    Uri? uri, {
    required bool falloFoto,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reclamo ${creado.codigo} registrado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              uri == null
                  ? 'Quedó anotado y soporte lo va a ver en la bandeja.'
                  : 'Quedó anotado. Si querés avisar ahora, el mensaje para '
                      'soporte ya está escrito.',
            ),
            if (falloFoto) ...[
              const SizedBox(height: 12),
              const Text(
                'La foto no se pudo subir, pero el reclamo quedó registrado '
                'igual.',
                style: TextStyle(color: AppColors.rojoNegativo, fontSize: 13),
              ),
            ],
          ],
        ),
        actions: [
          if (uri == null)
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Listo'),
            )
          else ...[
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Después'),
            ),
            FilledButton.icon(
              // Acá sale el launch: directo del toque, sin awaits de por medio.
              onPressed: () {
                Navigator.pop(ctx);
                abrirLink(
                  context,
                  uri,
                  siFalla: 'No se pudo abrir WhatsApp. El reclamo '
                      '${creado.codigo} quedó registrado igual.',
                );
              },
              icon: const Icon(Icons.send),
              label: const Text('Abrir WhatsApp'),
            ),
          ],
        ],
      ),
    );
  }

  void _mensaje(String texto, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(texto),
        backgroundColor: error ? AppColors.rojoNegativo : AppColors.verde,
      ));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _formulario(),
              const SizedBox(height: 24),
              const _TusReclamos(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _formulario() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reportar un problema',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.grisTexto,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Contanos qué pasó y lo revisamos. El resto de los datos '
              '(quién sos, cuándo fue, qué versión usás) los toma el sistema '
              'solo.',
              style: TextStyle(color: AppColors.grisTexto),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              initialValue: _modulo,
              decoration: const InputDecoration(
                labelText: '¿En qué parte del sistema?',
              ),
              items: [
                for (final m in modulosSoporte)
                  DropdownMenuItem(value: m, child: Text(m)),
              ],
              onChanged: (v) => setState(() => _modulo = v),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descripcion,
              minLines: 4,
              maxLines: 8,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: '¿Qué pasó?',
                hintText:
                    'Contá qué querías hacer y qué pasó en su lugar.',
                alignLabelWithHint: true,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              value: _bloqueante,
              onChanged: (v) => setState(() => _bloqueante = v),
              contentPadding: EdgeInsets.zero,
              title: const Text('No puedo seguir trabajando'),
              subtitle: const Text(
                'Marcalo solo si el problema te frena del todo: esos se miran '
                'primero.',
              ),
            ),
            const SizedBox(height: 8),
            _selectorFoto(),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _puedeEnviar || _enviando
                        ? ''
                        : 'Elegí la parte del sistema y contá qué pasó '
                            '(al menos $_minDescripcion caracteres).',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ),
                FilledButton.icon(
                  onPressed: _puedeEnviar ? _enviar : null,
                  icon: _enviando
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send),
                  label: Text(
                    Env.tieneWhatsappSoporte
                        ? 'Enviar a soporte'
                        : 'Registrar el problema',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _selectorFoto() {
    if (_fotoBytes == null) {
      return OutlinedButton.icon(
        onPressed: _elegirFoto,
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('Adjuntar una foto de la pantalla (opcional)'),
      );
    }
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            _fotoBytes!,
            width: 72,
            height: 72,
            fit: BoxFit.cover,
            // Las fotos de iPhone llegan en HEIC y el navegador no las
            // renderiza. Se suben igual; acá solo se avisa que no hay preview.
            errorBuilder: (_, _, _) => Container(
              width: 72,
              height: 72,
              color: const Color(0x11000000),
              alignment: Alignment.center,
              child: const Icon(Icons.image_not_supported_outlined, size: 20),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            _fotoNombre ?? 'Captura adjunta',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.grisTexto),
          ),
        ),
        TextButton(onPressed: _elegirFoto, child: const Text('Cambiar')),
        IconButton(
          tooltip: 'Quitar la foto',
          icon: const Icon(Icons.close),
          onPressed: () => setState(() {
            _fotoBytes = null;
            _fotoNombre = null;
          }),
        ),
      ],
    );
  }
}

/// Los últimos 5 reclamos del usuario, con su estado y lo que contestó
/// soporte.
class _TusReclamos extends ConsumerWidget {
  const _TusReclamos();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reclamos = ref.watch(misReclamosProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tus reclamos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.grisTexto,
              ),
            ),
            const SizedBox(height: 12),
            reclamos.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SoporteError(
                e,
                onReintentar: () => ref.invalidate(misReclamosProvider),
              ),
              data: (items) => items.isEmpty
                  ? const Text(
                      'Todavía no reportaste ningún problema.',
                      style: TextStyle(color: Colors.black54),
                    )
                  : Column(
                      children: [
                        for (final s in items) _FilaReclamo(s),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilaReclamo extends StatelessWidget {
  const _FilaReclamo(this.soporte);

  final Soporte soporte;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                soporte.codigo,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.grisTexto,
                ),
              ),
              const SizedBox(width: 8),
              EstadoChip(soporte.estado),
              if (soporte.bloqueante) ...[
                const SizedBox(width: 8),
                const BloqueanteChip(),
              ],
              const Spacer(),
              Text(
                Fmt.fechaHora(soporte.creadoEn),
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${soporte.modulo} · ${soporte.descripcion}',
            style: const TextStyle(color: AppColors.grisTexto),
          ),
          if (soporte.tieneRespuesta) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.verde.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Respuesta de soporte',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.verde,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    soporte.respuesta,
                    style: const TextStyle(color: AppColors.grisTexto),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
