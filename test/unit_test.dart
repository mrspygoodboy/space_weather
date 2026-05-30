import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:space_weather/models/solar_flare.dart';
import 'package:space_weather/models/near_earth_object.dart';
import 'package:space_weather/utils/validators.dart';
import 'package:space_weather/providers/solar_flares_provider.dart';
import 'package:space_weather/services/nasa_api_service.dart';

// ─── Mock ────────────────────────────────────────────────────────────────────

class MockNasaApiService extends Mock implements NasaApiService {}

// ─── SolarFlare model tests ───────────────────────────────────────────────────

void main() {
  group('SolarFlare.fromJson', () {
    final json = {
      'flrID': '2024-01-01T00:00:00-FLR-001',
      'beginTime': '2024-01-01T00:00Z',
      'peakTime': '2024-01-01T00:14Z',
      'endTime': '2024-01-01T00:28Z',
      'classType': 'X1.0',
      'sourceLocation': 'N20W10',
      'activeRegionNum': 3536,
      'note': 'Strong X-class flare.',
      'linkedEvents': [
        {'activityID': '2024-01-01T01:36:00-CME-001'}
      ],
    };

    test('parses all fields correctly', () {
      final flare = SolarFlare.fromJson(json);
      expect(flare.id, '2024-01-01T00:00:00-FLR-001');
      expect(flare.classType, 'X1.0');
      expect(flare.sourceLocation, 'N20W10');
      expect(flare.activeRegionNum, 3536);
      expect(flare.linkedEventIds, ['2024-01-01T01:36:00-CME-001']);
    });

    test('flareClass returns FlareClass.x for X1.0', () {
      final flare = SolarFlare.fromJson(json);
      expect(flare.flareClass, FlareClass.x);
    });

    test('toJson round-trips correctly', () {
      final flare = SolarFlare.fromJson(json);
      final roundTripped = SolarFlare.fromJson(flare.toJson());
      expect(roundTripped.id, flare.id);
      expect(roundTripped.classType, flare.classType);
      expect(roundTripped.linkedEventIds, flare.linkedEventIds);
    });

    test('handles missing optional fields', () {
      final minimal = {'flrID': 'test', 'beginTime': '2024-01-01T00:00Z', 'classType': 'B1.0'};
      final flare = SolarFlare.fromJson(minimal);
      expect(flare.note, isNull);
      expect(flare.linkedEventIds, isEmpty);
    });

    test('flareClass is correct for each prefix', () {
      for (final entry in {
        'M3.0': FlareClass.m,
        'C2.5': FlareClass.c,
        'B8.0': FlareClass.b,
        'Z9.9': FlareClass.unknown,
      }.entries) {
        final f = SolarFlare.fromJson({
          'flrID': 'id',
          'beginTime': '2024-01-01T00:00Z',
          'classType': entry.key,
        });
        expect(f.flareClass, entry.value,
            reason: 'Failed for classType=${entry.key}');
      }
    });

    test('FlareClass severity ordering', () {
      expect(FlareClass.x.severity, greaterThan(FlareClass.m.severity));
      expect(FlareClass.m.severity, greaterThan(FlareClass.c.severity));
      expect(FlareClass.c.severity, greaterThan(FlareClass.b.severity));
    });
  });

  // ─── NearEarthObject model tests ─────────────────────────────────────────

  group('NearEarthObject.fromJson', () {
    final json = {
      'id': '12345',
      'name': '(2024 AB1)',
      'is_potentially_hazardous_asteroid': true,
      'estimated_diameter': {
        'kilometers': {
          'estimated_diameter_min': 0.1,
          'estimated_diameter_max': 0.3,
        }
      },
      'close_approach_data': [
        {
          'close_approach_date': '2024-01-10',
          'relative_velocity': {'kilometers_per_hour': '72000.5'},
          'miss_distance': {'kilometers': '500000.0'},
          'orbiting_body': 'Earth',
        }
      ],
      'nasa_jpl_url': 'https://ssd.jpl.nasa.gov/sbdb.cgi?sbd=12345',
    };

    test('parses all fields correctly', () {
      final neo = NearEarthObject.fromJson(json);
      expect(neo.id, '12345');
      expect(neo.name, '(2024 AB1)');
      expect(neo.isPotentiallyHazardous, isTrue);
      expect(neo.estimatedDiameterMinKm, 0.1);
      expect(neo.estimatedDiameterMaxKm, 0.3);
      expect(neo.closeApproachDate, '2024-01-10');
      expect(neo.orbitingBody, 'Earth');
    });

    test('toJson round-trips correctly', () {
      final neo = NearEarthObject.fromJson(json);
      final rt = NearEarthObject.fromJson(neo.toJson());
      expect(rt.id, neo.id);
      expect(rt.isPotentiallyHazardous, neo.isPotentiallyHazardous);
      expect(rt.closeApproachDate, neo.closeApproachDate);
    });

    test('averageDiameterKm is the midpoint', () {
      final neo = NearEarthObject.fromJson(json);
      expect(neo.averageDiameterKm, closeTo(0.2, 0.0001));
    });

    test('handles empty close_approach_data gracefully', () {
      final minimal = {
        'id': '0',
        'name': 'Test',
        'is_potentially_hazardous_asteroid': false,
        'estimated_diameter': {
          'kilometers': {
            'estimated_diameter_min': 0.0,
            'estimated_diameter_max': 0.0,
          }
        },
        'close_approach_data': [],
        'nasa_jpl_url': '',
      };
      final neo = NearEarthObject.fromJson(minimal);
      expect(neo.closeApproachDate, 'Unknown');
      expect(neo.missDistanceKm, 0.0);
    });
  });

  // ─── Validators tests ─────────────────────────────────────────────────────

  group('Validators.validateDate', () {
    test('returns null for valid date', () {
      expect(Validators.validateDate('2024-06-15'), isNull);
    });

    test('returns error for empty string', () {
      expect(Validators.validateDate(''), isNotNull);
    });

    test('returns error for null', () {
      expect(Validators.validateDate(null), isNotNull);
    });

    test('returns error for wrong format', () {
      expect(Validators.validateDate('15-06-2024'), isNotNull);
      expect(Validators.validateDate('2024/06/15'), isNotNull);
    });

    test('returns error for invalid month', () {
      expect(Validators.validateDate('2024-13-01'), isNotNull);
    });

    test('returns error for invalid day', () {
      expect(Validators.validateDate('2024-01-32'), isNotNull);
    });
  });

  group('Validators.validateDateRange', () {
    test('returns null when dates are valid and in order', () {
      expect(
          Validators.validateDateRange('2024-01-01', '2024-01-15'), isNull);
    });

    test('returns error when end is before start', () {
      expect(Validators.validateDateRange('2024-01-15', '2024-01-01'),
          isNotNull);
    });

    test('returns error when range exceeds 30 days', () {
      expect(Validators.validateDateRange('2024-01-01', '2024-02-15'),
          isNotNull);
    });

    test('returns null when both are null', () {
      expect(Validators.validateDateRange(null, null), isNull);
    });
  });

  group('Validators.validateSearchQuery', () {
    test('returns null for valid query', () {
      expect(Validators.validateSearchQuery('X1.0'), isNull);
    });

    test('returns error for empty string', () {
      expect(Validators.validateSearchQuery(''), isNotNull);
    });

    test('returns error for single character', () {
      expect(Validators.validateSearchQuery('X'), isNotNull);
    });

    test('returns error for very long query', () {
      expect(Validators.validateSearchQuery('a' * 101), isNotNull);
    });
  });

  group('Validators.validateApodDate', () {
    test('returns error for future date', () {
      final future = DateTime.now().add(const Duration(days: 5));
      final dateStr =
          '${future.year}-${future.month.toString().padLeft(2, '0')}-${future.day.toString().padLeft(2, '0')}';
      expect(Validators.validateApodDate(dateStr), isNotNull);
    });

    test('returns null for past date', () {
      expect(Validators.validateApodDate('2024-01-01'), isNull);
    });
  });

  // ─── SolarFlaresProvider tests ────────────────────────────────────────────

  group('SolarFlaresProvider', () {
    late MockNasaApiService mockApi;
    late SolarFlaresProvider provider;

    final fakeFlares = [
      SolarFlare(
        id: 'id-1',
        beginTime: '2024-01-01T00:00Z',
        classType: 'X1.0',
        linkedEventIds: [],
        note: 'Big flare',
        sourceLocation: 'N20W10',
      ),
      SolarFlare(
        id: 'id-2',
        beginTime: '2024-01-02T00:00Z',
        classType: 'M3.0',
        linkedEventIds: [],
        note: 'Moderate event',
        sourceLocation: 'S10E05',
      ),
    ];

    setUp(() {
      mockApi = MockNasaApiService();
      provider = SolarFlaresProvider(mockApi);
    });

    test('initial status is initial', () {
      expect(provider.status, FlaresStatus.initial);
    });

    test('loadFlares sets status to success on data', () async {
      when(() => mockApi.fetchSolarFlares(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenAnswer((_) async => fakeFlares);

      await provider.loadFlares();

      expect(provider.status, FlaresStatus.success);
      expect(provider.flares.length, 2);
    });

    test('loadFlares sets status to error on ApiException', () async {
      when(() => mockApi.fetchSolarFlares(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenThrow(const ApiException('Network error'));

      await provider.loadFlares();

      expect(provider.status, FlaresStatus.error);
      expect(provider.errorMessage, 'Network error');
    });

    test('setSearchQuery filters flares by note', () async {
      when(() => mockApi.fetchSolarFlares(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenAnswer((_) async => fakeFlares);

      await provider.loadFlares();
      provider.setSearchQuery('Moderate');

      expect(provider.flares.length, 1);
      expect(provider.flares.first.classType, 'M3.0');
    });

    test('clearFilters restores all flares', () async {
      when(() => mockApi.fetchSolarFlares(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenAnswer((_) async => fakeFlares);

      await provider.loadFlares();
      provider.setFilterClass(FlareClass.x);
      expect(provider.flares.length, 1);

      provider.clearFilters();
      expect(provider.flares.length, 2);
    });

    test('setFilterClass filters by flare class', () async {
      when(() => mockApi.fetchSolarFlares(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenAnswer((_) async => fakeFlares);

      await provider.loadFlares();
      provider.setFilterClass(FlareClass.m);

      expect(provider.flares.length, 1);
      expect(provider.flares.first.flareClass, FlareClass.m);
    });
  });
}
