class NearEarthObject {
  final String id;
  final String name;
  final bool isPotentiallyHazardous;
  final double estimatedDiameterMinKm;
  final double estimatedDiameterMaxKm;
  final String closeApproachDate;
  final double relativeVelocityKmh;
  final double missDistanceKm;
  final String orbitingBody;
  final String nasaJplUrl;

  const NearEarthObject({
    required this.id,
    required this.name,
    required this.isPotentiallyHazardous,
    required this.estimatedDiameterMinKm,
    required this.estimatedDiameterMaxKm,
    required this.closeApproachDate,
    required this.relativeVelocityKmh,
    required this.missDistanceKm,
    required this.orbitingBody,
    required this.nasaJplUrl,
  });

  factory NearEarthObject.fromJson(Map<String, dynamic> json) {
    final diameter =
        json['estimated_diameter']?['kilometers'] as Map<String, dynamic>? ??
            {};
    final approaches =
        (json['close_approach_data'] as List<dynamic>? ?? []).isNotEmpty
            ? json['close_approach_data'][0] as Map<String, dynamic>
            : <String, dynamic>{};

    return NearEarthObject(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      isPotentiallyHazardous:
          json['is_potentially_hazardous_asteroid'] as bool? ?? false,
      estimatedDiameterMinKm:
          (diameter['estimated_diameter_min'] as num?)?.toDouble() ?? 0.0,
      estimatedDiameterMaxKm:
          (diameter['estimated_diameter_max'] as num?)?.toDouble() ?? 0.0,
      closeApproachDate:
          approaches['close_approach_date'] as String? ?? 'Unknown',
      relativeVelocityKmh:
          double.tryParse(approaches['relative_velocity']
                      ?['kilometers_per_hour'] as String? ??
                  '0') ??
              0.0,
      missDistanceKm: double.tryParse(
              approaches['miss_distance']?['kilometers'] as String? ?? '0') ??
          0.0,
      orbitingBody:
          approaches['orbiting_body'] as String? ?? 'Earth',
      nasaJplUrl: json['nasa_jpl_url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'is_potentially_hazardous_asteroid': isPotentiallyHazardous,
        'estimated_diameter': {
          'kilometers': {
            'estimated_diameter_min': estimatedDiameterMinKm,
            'estimated_diameter_max': estimatedDiameterMaxKm,
          }
        },
        'close_approach_data': [
          {
            'close_approach_date': closeApproachDate,
            'relative_velocity': {
              'kilometers_per_hour': relativeVelocityKmh.toString()
            },
            'miss_distance': {'kilometers': missDistanceKm.toString()},
            'orbiting_body': orbitingBody,
          }
        ],
        'nasa_jpl_url': nasaJplUrl,
      };

  double get averageDiameterKm =>
      (estimatedDiameterMinKm + estimatedDiameterMaxKm) / 2;
}
