import 'package:flutter/material.dart';

import '../../auth/domain/app_profile.dart';

/// Definición de un módulo del sistema (una entrada de navegación).
class ModuloApp {
  const ModuloApp({
    required this.ruta,
    required this.label,
    required this.icono,
    this.exclusivoAdmin = false,
  });

  final String ruta;
  final String label;
  final IconData icono;

  /// Módulo que la cajera nunca puede tener, ni aunque el admin quiera.
  /// Solo aplica a Configuración: es el panel donde se editan estos mismos
  /// permisos, así que dárselo le permitiría auto-habilitarse todo.
  final bool exclusivoAdmin;
}

/// Los 6 módulos, en orden de navegación.
const List<ModuloApp> modulos = [
  ModuloApp(ruta: '/carga', label: 'Carga', icono: Icons.edit_note),
  ModuloApp(ruta: '/precios-rinde', label: 'Lista de Precios', icono: Icons.sell),
  ModuloApp(ruta: '/pesaje', label: 'Pesaje', icono: Icons.scale),
  ModuloApp(ruta: '/balance', label: 'Balance', icono: Icons.assessment),
  ModuloApp(ruta: '/historial', label: 'Historial', icono: Icons.history),
  ModuloApp(
    ruta: '/configuracion',
    label: 'Configuración',
    icono: Icons.settings,
    exclusivoAdmin: true,
  ),
];

/// Módulos que el admin puede habilitar o no para la cajera.
List<ModuloApp> get modulosConfigurables =>
    modulos.where((m) => !m.exclusivoAdmin).toList();

/// Módulos visibles para un rol, según los permisos guardados.
///
/// El admin ve todo. La cajera ve los que el admin le habilitó en
/// Configuración > Permisos de la cajera.
List<ModuloApp> modulosPara(Rol rol, Map<String, bool> permisosCajera) {
  if (rol == Rol.admin) return modulos;
  return modulosConfigurables
      .where((m) => permisosCajera[m.ruta] ?? false)
      .toList();
}

/// Ruta a la que cae cada usuario al entrar: su primer módulo permitido.
/// `null` si la cajera se quedó sin ningún módulo habilitado.
String? rutaInicio(Rol rol, Map<String, bool> permisosCajera) {
  final visibles = modulosPara(rol, permisosCajera);
  return visibles.isEmpty ? null : visibles.first.ruta;
}
