import 'package:flutter/foundation.dart';
import '../models/near_earth_object.dart';
import '../services/nasa_api_service.dart';

enum NeoStatus { initial, loading, success, error }

class NeoProvider extends ChangeNotifier {
  final NasaApiService _apiService;

  NeoProvider(this._apiService);

  NeoStatus _status = NeoStatus.initial;
  List<NearEarthObject> _objects = [];
  String _errorMessage = '';
  bool _showHazardousOnly = false;

  NeoStatus get status => _status;
  String get errorMessage => _errorMessage;
  bool get showHazardousOnly => _showHazardousOnly;
  bool get hasData => _objects.isNotEmpty;

  List<NearEarthObject> get objects => _showHazardousOnly
      ? _objects.where((o) => o.isPotentiallyHazardous).toList()
      : _objects;

  int get hazardousCount =>
      _objects.where((o) => o.isPotentiallyHazardous).length;

  Future<void> loadNearEarthObjects({
    String? startDate,
    String? endDate,
  }) async {
    _status = NeoStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _objects = await _apiService.fetchNearEarthObjects(
        startDate: startDate,
        endDate: endDate,
      );
      _status = NeoStatus.success;
    } on ApiException catch (e) {
      _status = NeoStatus.error;
      _errorMessage = e.message;
    } catch (e) {
      _status = NeoStatus.error;
      _errorMessage = 'Unexpected error: $e';
    }

    notifyListeners();
  }

  void toggleHazardousFilter() {
    _showHazardousOnly = !_showHazardousOnly;
    notifyListeners();
  }
}
