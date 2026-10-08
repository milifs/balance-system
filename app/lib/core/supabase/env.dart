/// Configuración que se resuelve en build time, por `--dart-define`.
///
/// La URL y la `anon key` de Supabase son **públicas** (la seguridad real la
/// da RLS en la base). Aun así se leen de acá para poder apuntar a los dos
/// ambientes (producción / dev) sin tocar código:
///
/// ```bash
/// flutter run -d chrome \
///   --dart-define=SUPABASE_URL=https://<ref>.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=<anon-key> \
///   --dart-define=APP_VERSION=1.0.0 \
///   --dart-define=CLIENTE_NOMBRE="Don Chacho" \
///   --dart-define=SOPORTE_WHATSAPP=5493511234567
/// ```
///
/// Si no se pasan, cae al proyecto de producción `balance-system-don-chacho`.
/// En Vercel los pasa `scripts/vercel-build.sh` desde las env vars del deploy.
class Env {
  const Env._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://wvdqtvhfmntocfbrorla.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static bool get hasAnonKey => supabaseAnonKey.isNotEmpty;

  /// Versión de la app. Viaja en cada reclamo de Soporte para saber sobre qué
  /// build se reportó el problema.
  static const String appVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: 'dev',
  );

  /// Cliente dueño de este deploy. Va en el mensaje de WhatsApp para
  /// distinguir de qué instalación viene el reclamo.
  static const String clienteNombre = String.fromEnvironment(
    'CLIENTE_NOMBRE',
    defaultValue: 'Don Chacho',
  );

  /// WhatsApp de soporte, en formato internacional sin `+` ni espacios.
  /// Celular argentino: `549` + área sin el 0 + número. Ej.: Córdoba
  /// 351 512-3456 → `5493515123456`.
  ///
  /// Puede quedar vacío: en ese caso el reclamo se guarda igual y no se abre
  /// WhatsApp (ver [tieneWhatsappSoporte]).
  static const String soporteWhatsapp = String.fromEnvironment(
    'SOPORTE_WHATSAPP',
    defaultValue: '',
  );

  static bool get tieneWhatsappSoporte => soporteWhatsapp.isNotEmpty;
}
