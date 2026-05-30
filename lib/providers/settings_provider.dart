import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../services/nasa_api_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _settingsService;
  final NasaApiService _apiService;

  late ThemeMode _themeMode;
  late String _apiKey;
  late int _defaultDays;

  SettingsProvider(this._settingsService, this._apiService) {
    _loadFromPrefs();
  }

  ThemeMode get themeMode => _themeMode;
  String get apiKey => _apiKey;
  int get defaultDays => _defaultDays;

  void _loadFromPrefs() {
    final mode = _settingsService.getThemeMode();
    _themeMode = _modeFromString(mode);
    _apiKey = _settingsService.getApiKey();
    _defaultDays = _settingsService.getDefaultDays();
    _apiService.setApiKey(_apiKey);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _settingsService.setThemeMode(_modeToString(mode));
    notifyListeners();
  }

  Future<void> setApiKey(String key) async {
    _apiKey = key;
    await _settingsService.setApiKey(key);
    _apiService.setApiKey(key);
    notifyListeners();
  }

  Future<void> setDefaultDays(int days) async {
    _defaultDays = days;
    await _settingsService.setDefaultDays(days);
    notifyListeners();
  }

  static ThemeMode _modeFromString(String s) {
    switch (s) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static String _modeToString(ThemeMode m) {
    switch (m) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }
}
