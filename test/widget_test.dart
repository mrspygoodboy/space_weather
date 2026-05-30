import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:space_weather/models/solar_flare.dart';
import 'package:space_weather/providers/solar_flares_provider.dart';
import 'package:space_weather/providers/settings_provider.dart';
import 'package:space_weather/services/nasa_api_service.dart';
import 'package:space_weather/services/settings_service.dart';
import 'package:space_weather/widgets/solar_flare_tile.dart';
import 'package:space_weather/widgets/flare_class_badge.dart';
import 'package:space_weather/widgets/state_widgets.dart' as sw;
import 'package:space_weather/screens/flare_detail_screen.dart';

// ─── Mocks ───────────────────────────────────────────────────────────────────

class MockNasaApiService extends Mock implements NasaApiService {}

class MockSettingsService extends Mock implements SettingsService {}

// ─── Helpers ─────────────────────────────────────────────────────────────────

Widget _wrap(Widget child, {List<ChangeNotifierProvider>? extra}) {
  final mockApi = MockNasaApiService();
  final mockSettings = MockSettingsService();

  when(() => mockSettings.getThemeMode()).thenReturn('system');
  when(() => mockSettings.getApiKey()).thenReturn('');
  when(() => mockSettings.getDefaultDays()).thenReturn(30);
  when(() => mockApi.setApiKey(any())).thenAnswer((_) {});

  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => SettingsProvider(mockSettings, mockApi),
      ),
      ChangeNotifierProvider(
        create: (_) => SolarFlaresProvider(mockApi),
      ),
      ...?extra,
    ],
    child: MaterialApp(home: child),
  );
}

final _sampleFlare = SolarFlare(
  id: 'test-flr-001',
  beginTime: '2024-06-01T10:00Z',
  peakTime: '2024-06-01T10:22Z',
  endTime: '2024-06-01T10:45Z',
  classType: 'X2.5',
  sourceLocation: 'N15W05',
  activeRegionNum: 3600,
  note: 'Large X-class flare with associated CME.',
  linkedEventIds: ['2024-06-01T12:00:00-CME-001'],
);

// ─── FlareClassBadge ─────────────────────────────────────────────────────────

void main() {
  group('FlareClassBadge widget', () {
    testWidgets('renders class type text', (tester) async {
      await tester.pumpWidget(_wrap(
        FlareClassBadge(
          flareClass: FlareClass.x,
          classType: 'X2.5',
        ),
      ));
      expect(find.text('X2.5'), findsOneWidget);
    });

    testWidgets('renders for each flare class without error', (tester) async {
      for (final cls in FlareClass.values) {
        await tester.pumpWidget(_wrap(
          FlareClassBadge(flareClass: cls, classType: cls.label),
        ));
        await tester.pump();
        expect(find.text(cls.label), findsOneWidget);
      }
    });
  });

  // ─── SolarFlareTile ───────────────────────────────────────────────────────

  group('SolarFlareTile widget', () {
    testWidgets('shows class type badge', (tester) async {
      await tester.pumpWidget(
        _wrap(SolarFlareTile(flare: _sampleFlare, onTap: () {})),
      );
      expect(find.text('X2.5'), findsOneWidget);
    });

    testWidgets('shows source location', (tester) async {
      await tester.pumpWidget(
        _wrap(SolarFlareTile(flare: _sampleFlare, onTap: () {})),
      );
      expect(find.textContaining('N15W05'), findsOneWidget);
    });

    testWidgets('shows note preview', (tester) async {
      await tester.pumpWidget(
        _wrap(SolarFlareTile(flare: _sampleFlare, onTap: () {})),
      );
      expect(find.textContaining('CME'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(SolarFlareTile(flare: _sampleFlare, onTap: () => tapped = true)),
      );
      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });

    testWidgets('shows linked event icon when events present', (tester) async {
      await tester.pumpWidget(
        _wrap(SolarFlareTile(flare: _sampleFlare, onTap: () {})),
      );
      expect(find.byIcon(Icons.link_rounded), findsOneWidget);
    });

    testWidgets('does not show link icon when no linked events', (tester) async {
      final noLinks = SolarFlare(
        id: 'id-2',
        beginTime: '2024-01-01T00:00Z',
        classType: 'C1.0',
        linkedEventIds: [],
      );
      await tester.pumpWidget(
        _wrap(SolarFlareTile(flare: noLinks, onTap: () {})),
      );
      expect(find.byIcon(Icons.link_rounded), findsNothing);
    });
  });

  // ─── LoadingWidget ────────────────────────────────────────────────────────

  group('LoadingWidget', () {
    testWidgets('shows progress indicator', (tester) async {
      await tester
          .pumpWidget(_wrap(const sw.LoadingWidget(message: 'Loading...')));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('works without message', (tester) async {
      await tester.pumpWidget(_wrap(const sw.LoadingWidget()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  // ─── ErrorWidget2 ─────────────────────────────────────────────────────────

  group('ErrorWidget2', () {
    testWidgets('shows error message and retry button', (tester) async {
      var retried = false;
      await tester.pumpWidget(_wrap(sw.ErrorWidget2(
        message: 'Rate limit reached',
        onRetry: () => retried = true,
      )));
      expect(find.text('Rate limit reached'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
      await tester.tap(find.text('Try again'));
      expect(retried, isTrue);
    });

    testWidgets('hides retry button when onRetry is null', (tester) async {
      await tester.pumpWidget(
          _wrap(const sw.ErrorWidget2(message: 'Error', onRetry: null)));
      expect(find.text('Try again'), findsNothing);
    });
  });

  // ─── EmptyWidget ──────────────────────────────────────────────────────────

  group('EmptyWidget', () {
    testWidgets('shows title and subtitle', (tester) async {
      await tester.pumpWidget(_wrap(const sw.EmptyWidget(
        title: 'Nothing here',
        subtitle: 'Try again later',
      )));
      expect(find.text('Nothing here'), findsOneWidget);
      expect(find.text('Try again later'), findsOneWidget);
    });

    testWidgets('shows action button when provided', (tester) async {
      var acted = false;
      await tester.pumpWidget(_wrap(sw.EmptyWidget(
        title: 'Empty',
        subtitle: 'No data',
        onAction: () => acted = true,
        actionLabel: 'Reload',
      )));
      expect(find.text('Reload'), findsOneWidget);
      await tester.tap(find.text('Reload'));
      expect(acted, isTrue);
    });
  });

  // ─── FlareDetailScreen ────────────────────────────────────────────────────

  group('FlareDetailScreen', () {
    testWidgets('renders flare class type in app bar', (tester) async {
      await tester.pumpWidget(
        _wrap(FlareDetailScreen(flare: _sampleFlare)),
      );
      await tester.pump();
      expect(find.text('Flare X2.5'), findsOneWidget);
    });

    testWidgets('shows source location section', (tester) async {
      await tester.pumpWidget(
        _wrap(FlareDetailScreen(flare: _sampleFlare)),
      );
      await tester.pump();
      expect(find.text('Source location'), findsOneWidget);
      expect(find.textContaining('N15W05'), findsOneWidget);
    });

    testWidgets('shows linked events section', (tester) async {
      await tester.pumpWidget(
        _wrap(FlareDetailScreen(flare: _sampleFlare)),
      );
      await tester.pump();
      expect(find.text('Linked events'), findsOneWidget);
    });

    testWidgets('shows notes section', (tester) async {
      await tester.pumpWidget(
        _wrap(FlareDetailScreen(flare: _sampleFlare)),
      );
      await tester.pump();
      expect(find.text('Notes'), findsOneWidget);
      expect(find.textContaining('CME'), findsOneWidget);
    });

    testWidgets('shows severity bar', (tester) async {
      await tester.pumpWidget(
        _wrap(FlareDetailScreen(flare: _sampleFlare)),
      );
      await tester.pump();
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });
}
