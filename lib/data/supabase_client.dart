import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/env/env.dart';

final supabase = Supabase.instance.client;

Future<void> initSupabase() async {
  await Env.load();
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );
}
