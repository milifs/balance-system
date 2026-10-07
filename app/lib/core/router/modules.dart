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

  /// Módulo que no se habilita con un switch propio.
  /// Solo aplica a Configuración, que no se prende o apaga en bloque sino
  /// sección por sección (ver [seccionesConfig]).
  final bool exclusivoAdmin;
}

/// Ruta del módulo Configuración. Las secciones cuelgan de acá.
const rutaConfiguracion = '/configuracion';

/// Una sección dentro de Configuración (el menú de la izquierda).
class SeccionConfig {
  const SeccionConfig({
    required this.ruta,
    required this.label,
    required this.icono,
    this.exclusivoAdmin = false,
  });

  /// Ruta lógica, p. ej. `/configuracion/tipos-gasto`. No es una ruta de
  /// go_router (la navegación entre secciones es estado interno de la
  /// pantalla): es la clave con la que se guarda el permiso en la base.
  final String ruta;
  final String label;
  final IconData icono;

  /// Sección que la cajera nunca puede tener, ni aunque el admin quiera.
  /// Solo aplica a "Permisos de la cajera": es donde se editan estos mismos
  /// permisos, así que dársela le permitiría auto-habilitarse todo.
  final bool exclusivoAdmin;
}

/// Las 6 secciones de Configuración, en orden de menú.
const List<SeccionConfig> seccionesConfig = [
  SeccionConfig(
      ruta: '$rutaConfiguracion/sucursales',
      label: 'Sucursales',
      icono: Icons.store),
  SeccionConfig(
      ruta: '$rutaConfiguracion/categorias',
      label: 'Categorías y rinde',
      icono: Icons.category),
  SeccionConfig(
      ruta: '$rutaConfiguracion/cortes',
      label: 'Cortes',
      icono: Icons.content_cut),
  SeccionConfig(
      ruta: '$rutaConfiguracion/medios-pago',
      label: 'Medios de pago',
      icono: Icons.payments),
  SeccionConfig(
      ruta: '$rutaConfiguracion/tipos-gasto',
      label: 'Tipos de gasto',
      icono: Icons.receipt_long),
  SeccionConfig(
    ruta: '$rutaConfiguracion/permisos',
    label: 'Permisos de la cajera',
    icono: Icons.admin_panel_settings,
    exclusivoAdmin: true,
  ),
];

/// Secciones que el admin puede habilitar o no para la cajera.
List<SeccionConfig> get seccionesConfigurables =>
    seccionesConfig.where((s) => !s.exclusivoAdmin).toList();

/// Secciones visibles para un rol, según los permisos guardados.
List<SeccionConfig> seccionesPara(Rol rol, Map<String, bool> permisosCajera) {
  if (rol == Rol.admin) return seccionesConfig;
  return seccionesConfigurables
      .where((s) => permisosCajera[s.ruta] ?? false)
      .toList();
}

/// Los 6 módulos, en orden de navegación.
const List<ModuloApp> modulos = [
  ModuloApp(ruta: '/carga', label: 'Carga', icono: Icons.edit_note),
  ModuloApp(ruta: '/precios-rinde', label: 'Lista de Precios', icono: Icons.sell),
  ModuloApp(ruta: '/pesaje', label: 'Pesaje', icono: Icons.scale),
  ModuloApp(ruta: '/balance', label: 'Balance', icono: Icons.assessment),
  ModuloApp(ruta: '/historial', label: 'Historial', icono: Icons.history),
  ModuloApp(
    ruta: rutaConfiguracion,
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
///
/// Configuración es el caso especial: no tiene switch propio, aparece sola
/// si la cajera tiene al menos una sección habilitada adentro.
List<ModuloApp> modulosPara(Rol rol, Map<String, bool> permisosCajera) {
  if (rol == Rol.admin) return modulos;
  return modulos.where((m) {
    if (m.ruta == rutaConfiguracion) {
      return seccionesPara(rol, permisosCajera).isNotEmpty;
    }
    return !m.exclusivoAdmin && (permisosCajera[m.ruta] ?? false);
  }).toList();
}

/// Ruta a la que cae cada usuario al entrar: su primer módulo permitido.
/// `null` si la cajera se quedó sin ningún módulo habilitado.
String? rutaInicio(Rol rol, Map<String, bool> permisosCajera) {
  final visibles = modulosPara(rol, permisosCajera);
  return visibles.isEmpty ? null : visibles.first.ruta;
}
