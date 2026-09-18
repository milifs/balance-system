import 'package:flutter/material.dart';

import '../../auth/domain/app_profile.dart';

/// Definición de un módulo del sistema (una entrada de navegación).
class ModuloApp {
  const ModuloApp({
    required this.ruta,
    required this.label,
    required this.icono,
    required this.soloAdmin,
  });

  final String ruta;
  final String label;
  final IconData icono;

  /// Si es true, solo el admin lo ve. La cajera ve únicamente
  /// Carga, Lista de Precios y Pesaje.
  final bool soloAdmin;

  bool visiblePara(Rol rol) => rol == Rol.admin || !soloAdmin;
}

/// Los 6 módulos, en orden de navegación.
const List<ModuloApp> modulos = [
  ModuloApp(ruta: '/carga', label: 'Carga', icono: Icons.edit_note, soloAdmin: false),
  ModuloApp(ruta: '/precios-rinde', label: 'Lista de Precios', icono: Icons.sell, soloAdmin: false),
  ModuloApp(ruta: '/pesaje', label: 'Pesaje', icono: Icons.scale, soloAdmin: false),
  ModuloApp(ruta: '/balance', label: 'Balance', icono: Icons.assessment, soloAdmin: true),
  ModuloApp(ruta: '/historial', label: 'Historial', icono: Icons.history, soloAdmin: true),
  ModuloApp(ruta: '/configuracion', label: 'Configuración', icono: Icons.settings, soloAdmin: true),
];

/// Ruta a la que cae cada rol al entrar (primera permitida).
const String rutaInicioCajera = '/carga';
const String rutaInicioAdmin = '/carga';

/// Módulos visibles para un rol dado.
List<ModuloApp> modulosPara(Rol rol) =>
    modulos.where((m) => m.visiblePara(rol)).toList();
