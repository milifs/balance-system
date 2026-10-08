import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatters/formatters.dart';
import '../../../core/theme/app_theme.dart';
import '../application/soporte_providers.dart';
import '../domain/soporte.dart';
import 'widgets/adjunto_view.dart';
import 'widgets/soporte_ui.dart';

/// Bandeja de triage de los reclamos. Solo admin (lo gatea el router y, del
/// lado de los datos, la política de UPDATE de `soportes`).
class BandejaSoportePage extends ConsumerStatefulWidget {
  const BandejaSoportePage({super.key});

  @override
  ConsumerState<BandejaSoportePage> createState() => _BandejaSoportePageState();
}

class _BandejaSoportePageState extends ConsumerState<BandejaSoportePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs =
      TabController(length: EstadoSoporte.values.length, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _refrescar() async {
    ref.invalidate(soportesProvider);
    await ref.read(soportesProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final soportes = ref.watch(soportesProvider);

    // Los contadores salen de la misma lista que los tabs: no hace falta
    // entrar a cada uno para saber cuántos hay.
    final porEstado = <EstadoSoporte, List<Soporte>>{
      for (final e in EstadoSoporte.values)
        e: soportes.asData?.value.where((s) => s.estado == e).toList() ??
            const [],
    };

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bandeja de soporte',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.grisTexto,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Los reclamos que no dejan trabajar van primero.',
                      style: TextStyle(color: AppColors.grisTexto),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: _refrescar,
                icon: const Icon(Icons.refresh),
                label: const Text('Refrescar'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  TabBar(
                    controller: _tabs,
                    labelColor: AppColors.rojo,
                    indicatorColor: AppColors.rojo,
                    tabs: [
                      for (final e in EstadoSoporte.values)
                        Tab(text: '${e.plural} (${porEstado[e]!.length})'),
                    ],
                  ),
                  Expanded(
                    child: soportes.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) =>
                          SoporteError(e, onReintentar: _refrescar),
                      data: (_) => TabBarView(
                        controller: _tabs,
                        children: [
                          for (final e in EstadoSoporte.values)
                            _ListaEstado(
                              items: porEstado[e]!,
                              onRefrescar: _refrescar,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListaEstado extends StatelessWidget {
  const _ListaEstado({required this.items, required this.onRefrescar});

  final List<Soporte> items;
  final Future<void> Function() onRefrescar;

  @override
  Widget build(BuildContext context) {
    // El RefreshIndicator va incluso con la lista vacía: si no, en el tab sin
    // reclamos no habría forma de tirar para refrescar.
    return RefreshIndicator(
      onRefresh: onRefrescar,
      color: AppColors.rojo,
      child: items.isEmpty
          ? ListView(
              children: const [
                SizedBox(height: 60),
                Center(
                  child: Text(
                    'No hay reclamos en este estado.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              ],
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, color: Color(0x11000000)),
              itemBuilder: (_, i) => _FilaBandeja(items[i]),
            ),
    );
  }
}

class _FilaBandeja extends StatelessWidget {
  const _FilaBandeja(this.soporte);

  final Soporte soporte;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => showDialog<void>(
        context: context,
        builder: (_) => _DetalleDialog(soporte),
      ),
      leading: soporte.bloqueante
          ? const Icon(Icons.priority_high, color: AppColors.rojo)
          : const Icon(Icons.bug_report_outlined, color: Colors.black38),
      title: Row(
        children: [
          Text(
            soporte.codigo,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Text(
            soporte.modulo,
            style: const TextStyle(color: AppColors.grisTexto),
          ),
          if (soporte.bloqueante) ...[
            const SizedBox(width: 8),
            const BloqueanteChip(),
          ],
          if (soporte.tieneAdjunto) ...[
            const SizedBox(width: 8),
            const Icon(Icons.image_outlined, size: 16, color: Colors.black38),
          ],
        ],
      ),
      subtitle: Text(
        soporte.descripcion,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            Fmt.fechaHora(soporte.creadoEn),
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            soporte.reportadoPor ?? '—',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

/// Detalle del reclamo: todo el contexto que capturó la app, la captura, y el
/// triage.
class _DetalleDialog extends ConsumerStatefulWidget {
  const _DetalleDialog(this.soporte);

  final Soporte soporte;

  @override
  ConsumerState<_DetalleDialog> createState() => _DetalleDialogState();
}

class _DetalleDialogState extends ConsumerState<_DetalleDialog> {
  late final _respuesta =
      TextEditingController(text: widget.soporte.respuesta);
  bool _guardando = false;

  @override
  void dispose() {
    _respuesta.dispose();
    super.dispose();
  }

  /// Guarda la respuesta y mueve el reclamo de estado.
  ///
  /// La respuesta viaja con cualquiera de los tres botones: así el admin no
  /// tiene que acordarse de guardarla aparte, y escribirla sin mover el estado
  /// se hace apretando el botón del estado en el que ya está.
  Future<void> _aplicar(EstadoSoporte estado) async {
    final id = widget.soporte.id;
    if (id == null) return;
    setState(() => _guardando = true);
    try {
      await ref.read(soporteRepositoryProvider).actualizar(
            id: id,
            estado: estado,
            respuesta: _respuesta.text.trim(),
            resueltoPor: ref.read(identidadUsuarioProvider) ?? '',
          );
      ref.invalidate(soportesProvider);
      ref.invalidate(misReclamosProvider);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text('No se pudo actualizar el reclamo: $e'),
          backgroundColor: AppColors.rojoNegativo,
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.soporte;

    return AlertDialog(
      title: Row(
        children: [
          Text(s.codigo),
          const SizedBox(width: 12),
          EstadoChip(s.estado),
          if (s.bloqueante) ...[
            const SizedBox(width: 8),
            const BloqueanteChip(),
          ],
        ],
      ),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DatoContexto('Módulo', s.modulo),
              DatoContexto('Reportó', s.reportadoPor ?? '—'),
              DatoContexto('Rol', s.rol ?? '—'),
              DatoContexto('Fecha', Fmt.fechaHora(s.creadoEn)),
              DatoContexto('Versión', s.appVersion ?? '—'),
              DatoContexto('Plataforma', s.plataforma ?? '—'),
              if (s.resueltoEn != null)
                DatoContexto(
                  'Resuelto',
                  '${Fmt.fechaHora(s.resueltoEn)} · ${s.resueltoPor ?? '—'}',
                ),
              const SizedBox(height: 12),
              const Text(
                'Qué pasó',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.grisTexto,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                s.descripcion,
                style: const TextStyle(color: AppColors.grisTexto),
              ),
              if (s.tieneAdjunto) ...[
                const SizedBox(height: 16),
                const Text(
                  'Captura',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.grisTexto,
                  ),
                ),
                const SizedBox(height: 8),
                AdjuntoView(path: s.adjuntoPath!),
              ],
              const SizedBox(height: 20),
              TextField(
                controller: _respuesta,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Respuesta para el cliente',
                  hintText: 'Lo que escribas acá lo ve quien reportó.',
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: _guardando
          ? const [
              Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ]
          : [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
              TextButton(
                onPressed: () => _aplicar(EstadoSoporte.abierto),
                child: const Text('Reabrir'),
              ),
              OutlinedButton(
                onPressed: () => _aplicar(EstadoSoporte.enRevision),
                child: const Text('Marcar en revisión'),
              ),
              FilledButton(
                onPressed: () => _aplicar(EstadoSoporte.resuelto),
                child: const Text('Marcar resuelto'),
              ),
            ],
    );
  }
}
