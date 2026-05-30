import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/solar_flares_provider.dart';
import 'providers/neo_provider.dart';
import 'providers/settings_provider.dart';
import 'services/nasa_api_service.dart';
import 'services/settings_service.dart';
import 'utils/app_router.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settingsService = await SettingsService.create();
  final apiService = NasaApiService(apiKey: settingsService.getApiKey());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(settingsService, apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => SolarFlaresProvider(apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => NeoProvider(apiService),
        ),
      ],
      child: const SpaceWeatherApp(),
    ),
  );
}

class SpaceWeatherApp extends StatelessWidget {
  const SpaceWeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.select<SettingsProvider, ThemeMode>(
      (p) => p.themeMode,
    );

    return MaterialApp.router(
      title: 'Space Weather',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
