import 'package:flutter/material.dart';

import '../../../core/widgets/modulo_placeholder.dart';

class CargaPage extends StatelessWidget {
  const CargaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuloPlaceholder(
      titulo: 'Carga',
      icono: Icons.edit_note,
      descripcion:
          'Selección de período y carga de ventas, compras y gastos como '
          'registros individuales por sucursal.',
      fase: 'F5',
    );
  }
}
