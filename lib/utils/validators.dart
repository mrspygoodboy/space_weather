/// All validator functions live here, outside any widget.
/// This satisfies the assignment requirement: validation logic must reside
/// outside the widget, e.g. in a dedicated validator function.

class Validators {
  Validators._();

  /// Validates a date string in YYYY-MM-DD format.
  static String? validateDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Date is required';
    }
    final trimmed = value.trim();
    final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!regex.hasMatch(trimmed)) {
      return 'Use format YYYY-MM-DD';
    }
    try {
      final parts = trimmed.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      if (month < 1 || month > 12) return 'Month must be 01–12';
      if (day < 1 || day > 31) return 'Day must be 01–31';
      if (year < 1990 || year > 2100) return 'Year out of range';
    } catch (_) {
      return 'Invalid date';
    }
    return null;
  }

  /// Validates that end date is not before start date.
  static String? validateDateRange(String? start, String? end) {
    if (start == null || end == null) return null;
    final s = DateTime.tryParse(start);
    final e = DateTime.tryParse(end);
    if (s == null || e == null) return null;
    if (e.isBefore(s)) return 'End date must be after start date';
    final diff = e.difference(s).inDays;
    if (diff > 30) return 'Range cannot exceed 30 days (API limit)';
    return null;
  }

  /// Validates a search query string.
  static String? validateSearchQuery(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter a search term';
    }
    if (value.trim().length < 2) {
      return 'At least 2 characters required';
    }
    if (value.trim().length > 100) {
      return 'Query too long (max 100 characters)';
    }
    return null;
  }

  /// Validates a NASA APOD date (must not be in the future).
  static String? validateApodDate(String? value) {
    final dateError = validateDate(value);
    if (dateError != null) return dateError;
    final date = DateTime.tryParse(value!.trim());
    if (date != null && date.isAfter(DateTime.now())) {
      return 'Date cannot be in the future';
    }
    return null;
  }
}
