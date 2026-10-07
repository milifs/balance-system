import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/application/auth_providers.dart';
import '../../../core/permisos/permisos_providers.dart';
import '../../../core/router/modules.dart';
import '../../../core/theme/app_theme.dart';
import 'sections/categorias_section.dart';
import 'sections/cortes_section.dart';
import 'sections/medios_pago_section.dart';
import 'sections/permisos_cajera_section.dart';
import 'sections/sucursales_section.dart';
import 'sections/tipos_gasto_section.dart';

class ConfiguracionPage extends ConsumerStatefulWidget {
  const ConfiguracionPage({super.key});

  @override
  ConsumerState<ConfiguracionPage> createState() => _ConfiguracionPageState();
}

class _ConfiguracionPageState extends ConsumerState<ConfiguracionPage> {
  /// Sección elegida, por ruta. Se guarda la ruta y no el índice porque la
  /// lista de secciones visibles cambia según el rol y los permisos.
  String? _ruta;

  Widget _contenido(String ruta) {
    switch (ruta) {
      case '$rutaConfiguracion/sucursales':
        return const SucursalesSection();
      case '$rutaConfiguracion/categorias':
        return const CategoriasSection();
      case '$rutaConfiguracion/cortes':
        return const CortesSection();
      case '$rutaConfiguracion/medios-pago':
        return const MediosPagoSection();
      case '$rutaConfiguracion/tipos-gasto':
        return const TiposGastoSection();
      case '$rutaConfiguracion/permisos':
        return const PermisosCajeraSection();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentProfileProvider).asData?.value;
    final permisos =
        ref.watch(permisosCajeraProvider).asData?.value ?? const <String, bool>{};
    if (profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final visibles = seccionesPara(profile.rol, permisos);
    if (visibles.isEmpty) {
      // El router no debería dejar llegar acá, pero puede pasar por un frame
      // si el admin apaga la última sección mientras la cajera está adentro.
      return const Center(child: CircularProgressIndicator());
    }

    // Si la sección elegida dejó de estar permitida, caer en la primera.
    final actual =
        visibles.any((s) => s.ruta == _ruta) ? _ruta! : visibles.first.ruta;

    return Row(
      children: [
        Material(
          color: Colors.white,
          child: SizedBox(
            width: 240,
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Text('CONFIGURACIÓN',
                      style: TextStyle(
                        color: AppColors.grisTexto,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1.1,
                      )),
                ),
                for (final s in visibles)
                  ListTile(
                    selected: actual == s.ruta,
                    selectedTileColor: AppColors.rojo.withValues(alpha: 0.08),
                    selectedColor: AppColors.rojo,
                    leading: Icon(s.icono),
                    title: Text(s.label),
                    onTap: () => setState(() => _ruta = s.ruta),
                  ),
              ],
            ),
          ),
        ),
        const VerticalDivider(width: 1, color: Color(0x11000000)),
        Expanded(child: _contenido(actual)),
      ],
    );
  }
}
