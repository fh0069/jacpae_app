import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

/// Entry point of the application
///
/// Configuration is loaded from the .env file at the project root.
/// Required variables: SUPABASE_URL, SUPABASE_ANON_KEY, API_BASE_URL
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env (MUST be before any usage)
  await dotenv.load(fileName: '.env');

  // Diagnostic log — only in debug mode, never prints tokens
  if (kDebugMode) {
    print('[ENV] API_BASE_URL = ${dotenv.env['API_BASE_URL']}');
    print('[ENV] SUPABASE_URL = ${dotenv.env['SUPABASE_URL']}');
    // NEVER print SUPABASE_ANON_KEY or tokens
  }

  // Read Supabase credentials from .env
  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // Validate credentials are provided
  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw Exception(
      'Supabase credentials not found in .env!\n'
      'Ensure .env contains SUPABASE_URL and SUPABASE_ANON_KEY.',
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
