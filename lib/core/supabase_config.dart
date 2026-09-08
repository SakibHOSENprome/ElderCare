import 'package:supabase_flutter/supabase_flutter.dart';

/// Fill these in with your own Supabase project credentials.
/// Project Settings -> API in your Supabase dashboard.
///
/// For production, prefer passing these via --dart-define instead of
/// hard-coding them:
///   flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
class SupabaseConfig {
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://YOUR-PROJECT-REF.supabase.co',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR-SUPABASE-ANON-KEY',
  );

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }
}

/// Shorthand accessor used throughout the app.
final supabase = Supabase.instance.client;
