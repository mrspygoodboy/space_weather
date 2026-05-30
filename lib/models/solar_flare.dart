class SolarFlare {
  final String id;
  final String beginTime;
  final String? peakTime;
  final String? endTime;
  final String classType;
  final String? sourceLocation;
  final int? activeRegionNum;
  final String? note;
  final List<String> linkedEventIds;

  const SolarFlare({
    required this.id,
    required this.beginTime,
    this.peakTime,
    this.endTime,
    required this.classType,
    this.sourceLocation,
    this.activeRegionNum,
    this.note,
    required this.linkedEventIds,
  });

  factory SolarFlare.fromJson(Map<String, dynamic> json) {
    final linked = (json['linkedEvents'] as List<dynamic>? ?? [])
        .map((e) => e['activityID'] as String? ?? '')
        .where((s) => s.isNotEmpty)
        .toList();

    return SolarFlare(
      id: json['flrID'] as String? ?? '',
      beginTime: json['beginTime'] as String? ?? '',
      peakTime: json['peakTime'] as String?,
      endTime: json['endTime'] as String?,
      classType: json['classType'] as String? ?? 'Unknown',
      sourceLocation: json['sourceLocation'] as String?,
      activeRegionNum: json['activeRegionNum'] as int?,
      note: json['note'] as String?,
      linkedEventIds: linked,
    );
  }

  Map<String, dynamic> toJson() => {
        'flrID': id,
        'beginTime': beginTime,
        'peakTime': peakTime,
        'endTime': endTime,
        'classType': classType,
        'sourceLocation': sourceLocation,
        'activeRegionNum': activeRegionNum,
        'note': note,
        'linkedEvents':
            linkedEventIds.map((id) => {'activityID': id}).toList(),
      };

  /// X > M > C > B in severity
  FlareClass get flareClass {
    final prefix = classType.isNotEmpty ? classType[0].toUpperCase() : 'U';
    switch (prefix) {
      case 'X':
        return FlareClass.x;
      case 'M':
        return FlareClass.m;
      case 'C':
        return FlareClass.c;
      case 'B':
        return FlareClass.b;
      default:
        return FlareClass.unknown;
    }
  }

  DateTime? get beginDateTime => _parseDate(beginTime);
  DateTime? get peakDateTime => peakTime != null ? _parseDate(peakTime!) : null;

  static DateTime? _parseDate(String s) {
    try {
      return DateTime.parse(s);
    } catch (_) {
      return null;
    }
  }
}

enum FlareClass { x, m, c, b, unknown }

extension FlareClassExt on FlareClass {
  String get label {
    switch (this) {
      case FlareClass.x:
        return 'X';
      case FlareClass.m:
        return 'M';
      case FlareClass.c:
        return 'C';
      case FlareClass.b:
        return 'B';
      case FlareClass.unknown:
        return '?';
    }
  }

  int get severity {
    switch (this) {
      case FlareClass.x:
        return 4;
      case FlareClass.m:
        return 3;
      case FlareClass.c:
        return 2;
      case FlareClass.b:
        return 1;
      case FlareClass.unknown:
        return 0;
    }
  }
}
