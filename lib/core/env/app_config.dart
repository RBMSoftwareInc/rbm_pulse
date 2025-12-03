import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  AppConfig({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.attentionCheckMinDays,
    required this.attentionCheckMaxDays,
    required this.minGroupSizeForAggregation,
  });

  final String supabaseUrl;
  final String supabaseAnonKey;
  final int attentionCheckMinDays;
  final int attentionCheckMaxDays;
  final int minGroupSizeForAggregation;

  static AppConfig? _instance;

  static AppConfig get instance {
    final value = _instance;
    if (value == null) {
      throw StateError('AppConfig.load() must be called before use.');
    }
    return value;
  }

  static Future<AppConfig> load({
    String fileName = '.env',
    String fallbackFileName = 'env.example',
  }) async {
    // For web, skip dotenv loading entirely - use String.fromEnvironment only
    // For mobile/desktop, try to load from .env file
    if (!kIsWeb && !dotenv.isInitialized) {
      try {
        await dotenv.load(fileName: fileName);
      } catch (e) {
        // Try fallback file for non-web platforms
        try {
          await dotenv.load(fileName: fallbackFileName);
        } catch (_) {
          // Both files failed, will use String.fromEnvironment
        }
      }
    }

    final config = AppConfig(
      supabaseUrl: _readString('SUPABASE_URL'),
      supabaseAnonKey: _readString('SUPABASE_ANON_KEY'),
      attentionCheckMinDays: _readInt('ATTENTION_CHECK_MIN_DAYS', fallback: 10),
      attentionCheckMaxDays: _readInt('ATTENTION_CHECK_MAX_DAYS', fallback: 14),
      minGroupSizeForAggregation:
          _readInt('AGGREGATION_MIN_GROUP', fallback: 10),
    );

    _instance = config;
    return config;
  }

  static String _readString(String key) {
    String? raw;
    
    // For web, use String.fromEnvironment (compile-time constants)
    // Must check each key explicitly since const expressions can't use variables
    if (kIsWeb) {
      if (key == 'SUPABASE_URL') {
        raw = const String.fromEnvironment('SUPABASE_URL', defaultValue: '');
      } else if (key == 'SUPABASE_ANON_KEY') {
        raw = const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
      }
    } else {
      // For non-web, try dotenv first
      raw = dotenv.maybeGet(key);
    }
    
    if (raw == null || raw.isEmpty) {
      if (kIsWeb) {
        throw StateError(
          'Missing required config value for $key.\n\n'
          'For web deployment, you need to rebuild with --dart-define flags:\n'
          '   flutter build web --release \\\n'
          '     --dart-define=SUPABASE_URL=your_url \\\n'
          '     --dart-define=SUPABASE_ANON_KEY=your_key\n\n'
          'See FIX_NETLIFY.md for details.'
        );
      } else {
        throw StateError(
          'Missing required config value for $key.\n\n'
          'Please create a .env file with your Supabase credentials.\n'
          'See env.example for the required variables.'
        );
      }
    }
    return raw;
  }

  static int _readInt(String key, {required int fallback}) {
    String? raw;
    
    // For web, use String.fromEnvironment (compile-time constants)
    if (kIsWeb) {
      if (key == 'ATTENTION_CHECK_MIN_DAYS') {
        raw = const String.fromEnvironment('ATTENTION_CHECK_MIN_DAYS', defaultValue: '');
      } else if (key == 'ATTENTION_CHECK_MAX_DAYS') {
        raw = const String.fromEnvironment('ATTENTION_CHECK_MAX_DAYS', defaultValue: '');
      } else if (key == 'AGGREGATION_MIN_GROUP') {
        raw = const String.fromEnvironment('AGGREGATION_MIN_GROUP', defaultValue: '');
      } else {
        raw = '';
      }
    } else {
      // For non-web, try dotenv first
      raw = dotenv.maybeGet(key);
    }
    
    if (raw == null || raw.isEmpty) {
      return fallback;
    }
    final parsed = int.tryParse(raw);
    if (parsed == null) {
      return fallback;
    }
    return parsed;
  }
}

