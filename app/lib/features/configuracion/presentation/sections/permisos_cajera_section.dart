import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/permisos/permisos_providers.dart';
import '../../../../core/router/modules.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/section_scaffold.dart';

class PermisosCajeraSection extends ConsumerStatefulWidget {
  const PermisosCajeraSection({super.key});

  @override
  ConsumerState<PermisosCajeraSection> createState() =>
      _PermisosCajeraSectionState();
}

class _PermisosCajeraSectionState extends ConsumerState<PermisosCajeraSection> {
  String? _guardando;

  Future<void> _cambiar(String ruta, bool habilitado) async {
    setState(() => _guardando = ruta);
    try {
      await ref
          .read(permisosRepositoryProvider)
          .setPermisoCajera(ruta: ruta, habilitado: habilitado);
      ref.invalidate(permisosCajeraProvider);
    } catch (e) {
      if (mounted) mostrarMensaje(context, 'No se pudo guardar: $e', error: true);
    } finally {
      if (mounted) setState(() => _guardando = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final value = ref.watch(permisosCajeraProvider);
    return SectionScaffold(
      titulo: 'Permisos de la cajera',
      descripcion:
          'Elegí qué módulos ve la cajera en el menú. Los cambios se aplican '
          'la próxima vez que ella entre o recargue la página.',
      child: value.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Error al cargar: $e',
                style: const TextStyle(color: AppColors.rojoNegativo)),
          ),
        ),
        data: (permisos) {
          final habilitados =
              modulosConfigurables.where((m) => permisos[m.ruta] ?? false).length;
          return ListView(
            children: [
              for (final m in modulosConfigurables)
                SwitchListTile(
                  secondary: Icon(m.icono),
                  title: Text(m.label),
                  value: permisos[m.ruta] ?? false,
                  onChanged: _guardando != null
                      ? null
                      : (v) => _cambiar(m.ruta, v),
                ),
              if (habilitados == 0)
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Text(
                    'Sin ningún módulo habilitado la cajera puede entrar, pero '
                    'solo ve un aviso de que no tiene acceso.',
                    style: TextStyle(color: AppColors.rojoNegativo),
                  ),
                ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Text(
                  'Configuración no está en la lista a propósito: es donde se '
                  'editan estos permisos, así que es siempre exclusivo del '
                  'administrador.',
                  style: TextStyle(color: AppColors.grisTexto, fontSize: 12),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
