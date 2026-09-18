import 'package:flutter/material.dart';

import '../../../core/widgets/modulo_placeholder.dart';

class PreciosRindePage extends StatelessWidget {
  const PreciosRindePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuloPlaceholder(
      titulo: 'Lista de Precios + Rinde',
      icono: Icons.sell,
      descripcion:
          'Dos paneles lado a lado: lista de precios con incremento por '
          'categoría y el cuadro de rinde recalculado en vivo.',
      fase: 'F3',
    );
  }
}
