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
          'Elegí qué puede ver y editar la cajera. Los cambios se aplican '
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
          final modulosOn =
              modulosConfigurables.where((m) => permisos[m.ruta] ?? false).length;
          final seccionesOn = seccionesConfigurables
              .where((s) => permisos[s.ruta] ?? false)
              .length;

          return ListView(
            children: [
              const _Encabezado(
                titulo: 'MÓDULOS',
                detalle: 'Las pantallas que ve en el menú principal.',
              ),
              for (final m in modulosConfigurables)
                SwitchListTile(
                  secondary: Icon(m.icono),
                  title: Text(m.label),
                  value: permisos[m.ruta] ?? false,
                  onChanged:
                      _guardando != null ? null : (v) => _cambiar(m.ruta, v),
                ),
              if (modulosOn == 0 && seccionesOn == 0)
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Text(
                    'Sin nada habilitado la cajera puede entrar, pero solo ve '
                    'un aviso de que no tiene acceso.',
                    style: TextStyle(color: AppColors.rojoNegativo),
                  ),
                ),
              const Divider(height: 32),
              const _Encabezado(
                titulo: 'SECCIONES DE CONFIGURACIÓN',
                detalle:
                    'Habilitá alguna y el módulo Configuración le aparece solo '
                    'en el menú, con nada más que las secciones permitidas.',
              ),
              for (final s in seccionesConfigurables)
                SwitchListTile(
                  secondary: Icon(s.icono),
                  title: Text(s.label),
                  value: permisos[s.ruta] ?? false,
                  onChanged:
                      _guardando != null ? null : (v) => _cambiar(s.ruta, v),
                ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'En las secciones que habilites, la cajera puede agregar, '
                  'editar y borrar. Ojo con dos de ellas: la "Retención %" de '
                  'Medios de pago y el rinde de Categorías entran directo en '
                  'el cálculo del balance de las 4 sucursales.',
                  style: TextStyle(color: AppColors.rojoNegativo, fontSize: 12),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  '"Permisos de la cajera" no está en la lista a propósito: es '
                  'esta misma pantalla, así que habilitarla le permitiría '
                  'darse todos los demás permisos sola.',
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

class _Encabezado extends StatelessWidget {
  const _Encabezado({required this.titulo, required this.detalle});

  final String titulo;
  final String detalle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo,
              style: const TextStyle(
                color: AppColors.grisTexto,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.1,
              )),
          const SizedBox(height: 4),
          Text(detalle,
              style: const TextStyle(
                  color: AppColors.grisTexto, fontSize: 12)),
        ],
      ),
    );
  }
}
