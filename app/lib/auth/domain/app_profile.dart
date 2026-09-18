/// Rol del usuario dentro del sistema.
enum Rol { admin, cajera }

Rol _rolFromString(String? v) =>
    v == 'admin' ? Rol.admin : Rol.cajera;

/// Perfil del usuario autenticado (fila de `profiles`).
class AppProfile {
  const AppProfile({
    required this.id,
    required this.nombre,
    required this.rol,
    this.sucursalId,
  });

  final String id;
  final String nombre;
  final Rol rol;
  final String? sucursalId;

  bool get esAdmin => rol == Rol.admin;
  bool get esCajera => rol == Rol.cajera;

  factory AppProfile.fromJson(Map<String, dynamic> json) => AppProfile(
        id: json['id'] as String,
        nombre: (json['nombre'] as String?) ?? '',
        rol: _rolFromString(json['rol'] as String?),
        sucursalId: json['sucursal_id'] as String?,
      );
}
