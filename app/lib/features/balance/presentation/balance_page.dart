import 'package:flutter/material.dart';

import '../../../core/widgets/modulo_placeholder.dart';

class BalancePage extends StatelessWidget {
  const BalancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuloPlaceholder(
      titulo: 'Balance',
      icono: Icons.assessment,
      descripcion:
          'Balance por sucursal (bruto/neto, CMV, ganancia, utilidad %) y '
          'consolidado de las 4 sucursales.',
      fase: 'F6',
    );
  }
}
