import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'sections/categorias_section.dart';
import 'sections/cortes_section.dart';
import 'sections/medios_pago_section.dart';
import 'sections/permisos_cajera_section.dart';
import 'sections/sucursales_section.dart';
import 'sections/tipos_gasto_section.dart';

class ConfiguracionPage extends StatefulWidget {
  const ConfiguracionPage({super.key});

  @override
  State<ConfiguracionPage> createState() => _ConfiguracionPageState();
}

class _ConfiguracionPageState extends State<ConfiguracionPage> {
  int _seccion = 0;

  static const _items = [
    (_Sec(icono: Icons.store, label: 'Sucursales')),
    (_Sec(icono: Icons.category, label: 'Categorías y rinde')),
    (_Sec(icono: Icons.content_cut, label: 'Cortes')),
    (_Sec(icono: Icons.payments, label: 'Medios de pago')),
    (_Sec(icono: Icons.receipt_long, label: 'Tipos de gasto')),
    (_Sec(icono: Icons.admin_panel_settings, label: 'Permisos de la cajera')),
  ];

  Widget _contenido() {
    switch (_seccion) {
      case 0:
        return const SucursalesSection();
      case 1:
        return const CategoriasSection();
      case 2:
        return const CortesSection();
      case 3:
        return const MediosPagoSection();
      case 4:
        return const TiposGastoSection();
      case 5:
        return const PermisosCajeraSection();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
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
              for (var i = 0; i < _items.length; i++)
                ListTile(
                  selected: _seccion == i,
                  selectedTileColor: AppColors.rojo.withValues(alpha: 0.08),
                  selectedColor: AppColors.rojo,
                  leading: Icon(_items[i].icono),
                  title: Text(_items[i].label),
                  onTap: () => setState(() => _seccion = i),
                ),
            ],
          ),
          ),
        ),
        const VerticalDivider(width: 1, color: Color(0x11000000)),
        Expanded(child: _contenido()),
      ],
    );
  }
}

class _Sec {
  const _Sec({required this.icono, required this.label});
  final IconData icono;
  final String label;
}
