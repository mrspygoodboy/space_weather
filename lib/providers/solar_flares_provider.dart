import 'package:flutter/foundation.dart';
import '../models/solar_flare.dart';
import '../services/nasa_api_service.dart';

enum FlaresStatus { initial, loading, success, error }

class SolarFlaresProvider extends ChangeNotifier {
  final NasaApiService _apiService;

  SolarFlaresProvider(this._apiService);

  FlaresStatus _status = FlaresStatus.initial;
  List<SolarFlare> _flares = [];
  List<SolarFlare> _filtered = [];
  String _errorMessage = '';
  String _searchQuery = '';
  FlareClass? _filterClass;

  FlaresStatus get status => _status;
  List<SolarFlare> get flares => _filtered;
  String get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  FlareClass? get filterClass => _filterClass;

  bool get hasData => _flares.isNotEmpty;

  Future<void> loadFlares({String? startDate, String? endDate}) async {
    _status = FlaresStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _flares = await _apiService.fetchSolarFlares(
        startDate: startDate,
        endDate: endDate,
      );
      // Sort newest first
      _flares.sort((a, b) {
        final da = a.beginDateTime;
        final db = b.beginDateTime;
        if (da == null || db == null) return 0;
        return db.compareTo(da);
      });
      _status = FlaresStatus.success;
      _applyFilters();
    } on ApiException catch (e) {
      _status = FlaresStatus.error;
      _errorMessage = e.message;
    } catch (e) {
      _status = FlaresStatus.error;
      _errorMessage = 'Unexpected error: $e';
    }

    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setFilterClass(FlareClass? cls) {
    _filterClass = cls;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _filterClass = null;
    _filtered = List.of(_flares);
    notifyListeners();
  }

  void _applyFilters() {
    _filtered = _flares.where((f) {
      final matchesClass =
          _filterClass == null || f.flareClass == _filterClass;
      final matchesSearch = _searchQuery.isEmpty ||
          f.classType.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (f.sourceLocation
                  ?.toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ??
              false) ||
          (f.note?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
              false);
      return matchesClass && matchesSearch;
    }).toList();
  }
}
