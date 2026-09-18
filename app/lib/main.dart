import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/supabase/env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Formateo de fechas/números en es_AR.
  await initializeDateFormatting('es_AR', null);

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  runApp(const ProviderScope(child: BalanceApp()));
}
