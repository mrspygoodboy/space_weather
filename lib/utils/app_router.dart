import 'package:go_router/go_router.dart';
import '../models/solar_flare.dart';
import '../models/near_earth_object.dart';
import '../screens/home_screen.dart';
import '../screens/flare_detail_screen.dart';
import '../screens/neo_screen.dart';
import '../screens/neo_detail_screen.dart';
import '../screens/search_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/about_screen.dart';

class AppRouter {
  AppRouter._();

  static const home = '/';
  static const flareDetail = '/flare/:id';
  static const neo = '/neo';
  static const neoDetail = '/neo/:id';
  static const search = '/search';
  static const settings = '/settings';
  static const about = '/about';

  static final router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: flareDetail,
        builder: (context, state) {
          final flare = state.extra as SolarFlare;
          return FlareDetailScreen(flare: flare);
        },
      ),
      GoRoute(
        path: neo,
        builder: (context, state) => const NeoScreen(),
      ),
      GoRoute(
        path: neoDetail,
        builder: (context, state) {
          final neo = state.extra as NearEarthObject;
          return NeoDetailScreen(neo: neo);
        },
      ),
      GoRoute(
        path: search,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: about,
        builder: (context, state) => const AboutScreen(),
      ),
    ],
  );
}
