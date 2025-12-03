import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart' as provider;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/env/env.dart';
import 'core/theme/theme_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/home/dashboard_screen.dart';
import 'features/learning/learning_hub_screen.dart';
import 'features/onboarding/app_tour_service.dart';
import 'features/onboarding/curtain_screen.dart';

const logoAsset = 'assets/logo/rbm-logo.svg';

// App entry
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Env.load();
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );
    runApp(const ProviderScope(child: OrgPulseApp()));
  } catch (e, stackTrace) {
    // Show error in console and display error screen
    debugPrint('❌ App initialization error: $e');
    debugPrint('Stack trace: $stackTrace');
    
    // Extract error message - handle both regular and minified errors
    String errorMessage = 'Unknown error occurred';
    
    try {
      // Try to get message from StateError
      if (e is StateError) {
        // Access message property safely
        final message = (e as dynamic).message;
        if (message != null && message is String && message.isNotEmpty) {
          errorMessage = message;
        } else {
          // Fallback to toString
          final errorStr = e.toString();
          if (errorStr.contains('Missing required config value')) {
            final parts = errorStr.split('Missing required config value');
            if (parts.length > 1) {
              errorMessage = 'Missing required config value${parts[1].split('\n').first}';
            } else {
              errorMessage = 'Missing required configuration value';
            }
          } else {
            errorMessage = errorStr.replaceAll('StateError: ', '').split('\n').first;
          }
        }
      } else {
        final errorStr = e.toString();
        // Handle minified errors that show "Instance of 'minified:WT'"
        if (errorStr.contains('Instance of') || errorStr.contains('minified:')) {
          // Try to extract from stack trace or use generic message
          if (stackTrace.toString().contains('Missing required config value')) {
            errorMessage = 'Missing required configuration value. Please rebuild with --dart-define flags.';
          } else if (stackTrace.toString().contains('SUPABASE_URL')) {
            errorMessage = 'Missing SUPABASE_URL. Please rebuild with --dart-define=SUPABASE_URL=your_url';
          } else if (stackTrace.toString().contains('SUPABASE_ANON_KEY')) {
            errorMessage = 'Missing SUPABASE_ANON_KEY. Please rebuild with --dart-define=SUPABASE_ANON_KEY=your_key';
          } else {
            errorMessage = 'Configuration error. Please rebuild with --dart-define flags for SUPABASE_URL and SUPABASE_ANON_KEY.';
          }
        } else if (errorStr.contains('Missing required config value')) {
          final parts = errorStr.split('Missing required config value');
          if (parts.length > 1) {
            errorMessage = 'Missing required config value${parts[1].split('\n').first}';
          } else {
            errorMessage = 'Missing required configuration value';
          }
        } else if (errorStr.contains('StateError')) {
          errorMessage = errorStr.replaceAll('StateError: ', '').split('\n').first;
        } else {
          errorMessage = errorStr;
        }
      }
    } catch (_) {
      // If all else fails, use a generic helpful message
      errorMessage = 'Configuration error. Please rebuild with:\n'
          'flutter build web --release \\\n'
          '  --dart-define=SUPABASE_URL=your_url \\\n'
          '  --dart-define=SUPABASE_ANON_KEY=your_key';
    }
    
    runApp(MaterialApp(
      home: Scaffold(
      body: Center(
        child: Padding(
            padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 24),
                const Text(
                  'Configuration Error',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 24),
                const Text(
                  'For web deployment, rebuild with:\n'
                  'flutter build web --release \\\n'
                  '  --dart-define=SUPABASE_URL=your_url \\\n'
                  '  --dart-define=SUPABASE_ANON_KEY=your_key',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey, fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}

class OrgPulseApp extends ConsumerStatefulWidget {
  const OrgPulseApp({super.key});
  @override
  ConsumerState<OrgPulseApp> createState() => _OrgPulseAppState();
}

class _OrgPulseAppState extends ConsumerState<OrgPulseApp> {
  String? _userId;
  String _role = 'employee'; // Default until loaded
  bool _initialized = false;
  bool _tourShown = false; // Track if the tour has been shown
  final bool _showCurtain = true; // Track if the curtain screen should be shown

  @override
  void initState() {
    super.initState();
    _bootstrap();
    // Listen to auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null && _userId == null) {
        // User just logged in
        _bootstrap();
      } else if (session == null && _userId != null) {
        // User just logged out
        setState(() {
          _userId = null;
          _role = 'employee';
        });
      }
    });
  }

  // Load and set user session, role
  Future<void> _bootstrap() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      setState(() {
        _userId = null;
        _role = 'employee';
        _initialized = true;
      });
      return;
    }
    final userId = session.user.id;
    final role = await _fetchUserRole(userId);
    if (mounted) {
      setState(() {
        _userId = userId;
        _role = role;
        _initialized = true;
      });
    }
  }

  Future<String> _fetchUserRole(String userId) async {
    final res = await Supabase.instance.client
        .from('profiles')
        .select('role')
        .eq('id', userId)
        .maybeSingle();
    return res?['role'] ?? 'employee';
  }

  // Login callback
  void _onLogin() async {
    // Wait a bit for auth state to update
    await Future.delayed(const Duration(milliseconds: 300));
    await _bootstrap();
  }

  // Logout
  Future<void> _onLogout() async {
    await Supabase.instance.client.auth.signOut();
    setState(() {
      _userId = null;
      _role = 'employee';
    });
  }

  @override
  Widget build(BuildContext context) {
    return provider.ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: provider.Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          ThemeData currentTheme;
          if (themeProvider.themeMode == ThemeMode.light) {
            currentTheme = themeProvider.getLightTheme();
          } else if (themeProvider.themeMode == ThemeMode.dark) {
            currentTheme = themeProvider.getDarkTheme();
          } else {
            // System mode - use MediaQuery if available, otherwise default to dark
            try {
              final brightness = MediaQuery.of(context).platformBrightness;
              currentTheme = brightness == Brightness.light
                  ? themeProvider.getLightTheme()
                  : themeProvider.getDarkTheme();
            } catch (e) {
              // Fallback to dark if MediaQuery not available yet
              currentTheme = themeProvider.getDarkTheme();
            }
          }

    if (!_initialized) {
      return MaterialApp(
              theme: currentTheme,
              home: const Scaffold(
                  body: Center(child: CircularProgressIndicator())),
      );
    }

          // Show login if not authed (curtain screen only shows once on first launch)
    if (_userId == null) {
      return MaterialApp(
              theme: currentTheme,
              themeMode: themeProvider.themeMode,
              debugShowCheckedModeBanner: false,
        home: LoginScreen(onLogin: _onLogin),
      );
    }

          // Show dashboard as home screen after login
          final navigatorKey = GlobalKey<NavigatorState>();
          return MaterialApp(
            title: 'RBM-Pulse',
            theme: currentTheme,
            navigatorKey: navigatorKey,
            themeMode: themeProvider.themeMode,
            debugShowCheckedModeBanner: false,
            home: _DashboardWithTour(
              userId: _userId!,
      role: _role,
      onLogout: _onLogout,
              tourShown: _tourShown,
              navigatorKey: navigatorKey,
              onTourShown: () {
                setState(() {
                  _tourShown = true;
                });
              },
            ),
          );
        },
      ),
    );
  }
}

// Wrapper widget to show tour after MaterialApp is built
class _DashboardWithTour extends StatefulWidget {
  final String userId;
  final String role;
  final Future<void> Function() onLogout;
  final bool tourShown;
  final GlobalKey<NavigatorState> navigatorKey;
  final VoidCallback onTourShown;

  const _DashboardWithTour({
    required this.userId,
    required this.role,
    required this.onLogout,
    required this.tourShown,
    required this.navigatorKey,
    required this.onTourShown,
  });

  @override
  State<_DashboardWithTour> createState() => _DashboardWithTourState();
}

class _DashboardWithTourState extends State<_DashboardWithTour> {
  @override
  void initState() {
    super.initState();
    // Show tour after MaterialApp is fully built
    if (!widget.tourShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (mounted && !widget.tourShown) {
          widget.onTourShown();
          // Wait for MaterialApp to be fully initialized
          await Future.delayed(const Duration(milliseconds: 800));
          // Use navigator context which is guaranteed to be inside MaterialApp
          final navigatorContext = widget.navigatorKey.currentContext;
          if (mounted && navigatorContext != null && navigatorContext.mounted) {
            await AppTourService.showTourIfNeeded(navigatorContext);
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DashboardScreen(
      userId: widget.userId,
      role: widget.role,
      onLogout: widget.onLogout,
    );
  }
}
