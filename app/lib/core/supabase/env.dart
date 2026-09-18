/// Configuración de conexión a Supabase.
///
/// La URL y la `anon key` son **públicas** (la seguridad real la da RLS en la
/// base). Aun así se leen por `--dart-define` para poder apuntar a los dos
/// ambientes (producción / dev) sin tocar código:
///
/// ```bash
/// flutter run -d chrome \
///   --dart-define=SUPABASE_URL=https://<ref>.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=<anon-key>
/// ```
///
/// Si no se pasan, cae al proyecto de producción `balance-system-don-chacho`.
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
}
