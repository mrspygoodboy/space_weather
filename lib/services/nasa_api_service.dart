import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import '../models/solar_flare.dart';
import '../models/near_earth_object.dart';

class NasaApiService {
  // NASA DONKI and NeoWs APIs are free without a key (DEMO_KEY has limits).
  // Users can set their own key in settings for higher rate limits.
  static const String _baseUrl = 'https://api.nasa.gov';
  static const String _demoKey = 'DEMO_KEY';

  final http.Client _client;
  String _apiKey;

  NasaApiService({http.Client? client, String? apiKey})
      : _client = client ?? http.Client(),
        _apiKey = apiKey ?? _demoKey;

  void setApiKey(String key) {
    _apiKey = key.isEmpty ? _demoKey : key;
  }

  /// Fetch solar flares from NASA DONKI. Falls back to local JSON on error.
  Future<List<SolarFlare>> fetchSolarFlares({
    String? startDate,
    String? endDate,
  }) async {
    final start = startDate ?? _daysAgo(30);
    final end = endDate ?? _today();

    final uri = Uri.parse(
      '$_baseUrl/DONKI/FLR?startDate=$start&endDate=$end&api_key=$_apiKey',
    );

    try {
      final response = await _client.get(uri).timeout(
            const Duration(seconds: 15),
          );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => SolarFlare.fromJson(e)).toList();
      } else if (response.statusCode == 429) {
        throw ApiException('Rate limit reached. Try using a personal NASA API key.');
      } else {
        throw ApiException('Server error: ${response.statusCode}');
      }
    } on SocketException {
      // No internet — fall back to bundled data
      return _loadLocalFlares();
    } on ApiException {
      rethrow;
    } catch (_) {
      return _loadLocalFlares();
    }
  }

  /// Fetch near-earth objects for the next 7 days from NeoWs.
  Future<List<NearEarthObject>> fetchNearEarthObjects({
    String? startDate,
    String? endDate,
  }) async {
    final start = startDate ?? _today();
    final end = endDate ?? _daysFromNow(7);

    final uri = Uri.parse(
      '$_baseUrl/neo/rest/v1/feed?start_date=$start&end_date=$end&api_key=$_apiKey',
    );

    try {
      final response = await _client.get(uri).timeout(
            const Duration(seconds: 15),
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final neoMap =
            data['near_earth_objects'] as Map<String, dynamic>? ?? {};
        final objects = <NearEarthObject>[];
        for (final dateList in neoMap.values) {
          for (final neo in (dateList as List<dynamic>)) {
            objects.add(NearEarthObject.fromJson(neo));
          }
        }
        objects.sort((a, b) =>
            a.closeApproachDate.compareTo(b.closeApproachDate));
        return objects;
      } else if (response.statusCode == 429) {
        throw ApiException('Rate limit reached. Try using a personal NASA API key.');
      } else {
        throw ApiException('Server error: ${response.statusCode}');
      }
    } on SocketException {
      return [];
    } on ApiException {
      rethrow;
    } catch (_) {
      return [];
    }
  }

  Future<List<SolarFlare>> _loadLocalFlares() async {
    final raw = await rootBundle.loadString('assets/data/solar_flares.json');
    final List<dynamic> data = json.decode(raw);
    return data.map((e) => SolarFlare.fromJson(e)).toList();
  }

  static String _today() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static String _daysAgo(int days) {
    final d = DateTime.now().subtract(Duration(days: days));
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  static String _daysFromNow(int days) {
    final d = DateTime.now().add(Duration(days: days));
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}
