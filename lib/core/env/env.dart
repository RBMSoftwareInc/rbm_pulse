import 'app_config.dart';

class Env {
  static late AppConfig _config;
  static bool _loaded = false;

  static AppConfig get config => _config;
  static String get supabaseUrl => _config.supabaseUrl;
  static String get supabaseAnonKey => _config.supabaseAnonKey;
  static int get attentionCheckMinDays => _config.attentionCheckMinDays;
  static int get attentionCheckMaxDays => _config.attentionCheckMaxDays;
  static int get minGroupSizeForAggregation =>
      _config.minGroupSizeForAggregation;

  static Future<void> load() async {
    if (_loaded) return;
    _config = await AppConfig.load();
    _loaded = true;
  }
}
