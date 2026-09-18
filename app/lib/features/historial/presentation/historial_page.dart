import 'package:flutter/material.dart';

import '../../../core/widgets/modulo_placeholder.dart';

class HistorialPage extends StatelessWidget {
  const HistorialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuloPlaceholder(
      titulo: 'Historial de Balance',
      icono: Icons.history,
      descripcion:
          'Listado de períodos cerrados con su detalle para consultar balances '
          'anteriores.',
      fase: 'F7',
    );
  }
}
