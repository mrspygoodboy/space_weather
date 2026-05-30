import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _keyThemeMode = 'theme_mode';
  static const _keyApiKey = 'nasa_api_key';
  static const _keyDefaultDays = 'default_days';

  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  static Future<SettingsService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsService(prefs);
  }

  // Theme
  String getThemeMode() => _prefs.getString(_keyThemeMode) ?? 'system';

  Future<void> setThemeMode(String mode) =>
      _prefs.setString(_keyThemeMode, mode);

  // NASA API key
  String getApiKey() => _prefs.getString(_keyApiKey) ?? '';

  Future<void> setApiKey(String key) => _prefs.setString(_keyApiKey, key);

  // Default date range in days
  int getDefaultDays() => _prefs.getInt(_keyDefaultDays) ?? 30;

  Future<void> setDefaultDays(int days) =>
      _prefs.setInt(_keyDefaultDays, days);
}
