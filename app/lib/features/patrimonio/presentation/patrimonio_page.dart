import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'sections/carga_patrimonio_section.dart';
import 'sections/consulta_patrimonio_section.dart';

/// Módulo Patrimonio (solo admin): el cuadro de "qué tengo / qué debo" a una
/// fecha, en dos pestañas — Carga para la foto nueva, Consulta para las ya
/// guardadas. Las dos exportan a PDF.
class PatrimonioPage extends StatelessWidget {
  const PatrimonioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          Material(
            color: AppColors.crema,
            child: TabBar(
              tabs: [
                Tab(text: 'Carga'),
                Tab(text: 'Consulta'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              // Carga se mantiene viva al cambiar de pestaña (ver
              // `AutomaticKeepAliveClientMixin` allá): ir a Consulta y
              // volver no puede borrar lo que todavía no se guardó.
              children: [
                CargaPatrimonioSection(),
                ConsultaPatrimonioSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
