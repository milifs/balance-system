import 'package:flutter/material.dart';

import '../../../core/widgets/modulo_placeholder.dart';

class ConfiguracionPage extends StatelessWidget {
  const ConfiguracionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuloPlaceholder(
      titulo: 'Configuración',
      icono: Icons.settings,
      descripcion:
          'Usuarios y roles, sucursales, cortes, medios de pago, tipos de gasto '
          'y costos de piezas base para el rinde.',
      fase: 'F2',
    );
  }
}
