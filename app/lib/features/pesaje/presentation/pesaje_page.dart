import 'package:flutter/material.dart';

import '../../../core/widgets/modulo_placeholder.dart';

class PesajePage extends StatelessWidget {
  const PesajePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuloPlaceholder(
      titulo: 'Pesaje',
      icono: Icons.scale,
      descripcion:
          'Una pestaña por sucursal. Cada corte se pesa (apertura/cierre) y se '
          'valoriza a precio de venta o a costo según corresponda.',
      fase: 'F4',
    );
  }
}
