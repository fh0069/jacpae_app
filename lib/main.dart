import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

/// Entry point of the application
///
/// IMPORTANT: Run with dart-define variables:
/// ```
/// flutter run --dart-define=SUPABASE_URL=your_supabase_url --dart-define=SUPABASE_ANON_KEY=your_anon_key
/// ```
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Get Supabase credentials from dart-define
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  // Validate credentials are provided
  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw Exception(
      'Supabase credentials not found!\n'
      'Run with: flutter run --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key',
    );
  }

  // Initialize Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  // Wrap with ProviderScope for Riverpod
  runApp(const ProviderScope(child: App()));
}
