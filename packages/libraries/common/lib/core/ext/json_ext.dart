/// Typed reads for a decoded JSON object.
///
/// The mappers used to reach into the map and call a method on whatever came
/// back — `json['price'].toDouble()`, `(json['total'] ?? 0).toDouble()`,
/// `json['discount']?.toDouble() ?? 0`. Five spellings of the same idea, all
/// of them dynamic calls the analyzer cannot check, and all of them throwing
/// `NoSuchMethodError: Class 'String' has no instance method 'toDouble'` if the
/// server ever sends a number as text.
///
/// These read the field instead, and say which field was wrong when it is.
///
/// A missing field falls back; a field of the wrong shape throws. That split is
/// deliberate: an absent `discount` legitimately means zero, but a `price` that
/// arrives as something unreadable must not quietly become zero on a till.
extension JsonRead on Map<String, dynamic> {
  double readDouble(String key, {double fallback = 0}) {
    final value = this[key];
    if (value == null) return fallback;
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
    throw _wrongShape(key, 'a number', value);
  }

  int readInt(String key, {int fallback = 0}) {
    final value = this[key];
    if (value == null) return fallback;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value) ?? double.tryParse(value)?.toInt();
      if (parsed != null) return parsed;
    }
    throw _wrongShape(key, 'a whole number', value);
  }

  String readString(String key, {String fallback = ''}) {
    final value = this[key];
    if (value == null) return fallback;
    if (value is String) return value;
    if (value is num || value is bool) return value.toString();
    throw _wrongShape(key, 'a string', value);
  }

  bool readBool(String key, {bool fallback = false}) {
    final value = this[key];
    if (value == null) return fallback;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      if (value == 'true') return true;
      if (value == 'false') return false;
    }
    throw _wrongShape(key, 'a boolean', value);
  }

  /// A read that keeps null as null, for the fields the domain models as
  /// optional rather than defaulted.
  String? readStringOrNull(String key) {
    final value = this[key];
    if (value == null) return null;
    return readString(key);
  }
}

FormatException _wrongShape(String key, String expected, Object value) {
  return FormatException(
      "field '$key' expected $expected but got ${value.runtimeType}: $value");
}
