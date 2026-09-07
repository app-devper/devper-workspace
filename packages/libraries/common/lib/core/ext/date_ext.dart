// Package imports:
import 'package:intl/intl.dart';

const serverDatePattern = "yyyy-MM-dd";

const presentDatePattern = "dd/MM/yyyy";
const shortDatePattern = "d/M";
const presentShortDatePattern = "d/M/yy";

String formatDate(String? date, {String src = serverDatePattern, String dest = presentDatePattern}) {
  if (date == null || date.isEmpty) {
    return '';
  } else {
    var inputDate = DateFormat(src).parse(date);
    var outputFormat = DateFormat(dest);
    return outputFormat.format(inputDate);
  }
}

DateTime getCurrentDate() {
  return DateTime.now();
}

extension FormatDateTime on DateTime {
  String formatShortDate() {
    final outputFormat = DateFormat(shortDatePattern);
    return outputFormat.format(this);
  }

  String formatDate() {
    final outputFormat = DateFormat(presentDatePattern);
    return outputFormat.format(this);
  }
}

extension FormatStringDateTime on String {
  String formatDate() {
    if (isEmpty) {
      return '';
    } else {
      final date = DateTime.parse(this);
      final format = DateFormat(presentDatePattern);
      return format.format(date.toLocal());
    }
  }

  String formatShortDate() {
    if (isEmpty) {
      return '';
    } else {
      final date = DateTime.parse(this);
      final format = DateFormat(presentShortDatePattern);
      return format.format(date.toLocal());
    }
  }

  DateTime? tryParseDate() {
    try {
      return DateFormat(presentDatePattern).parse(this);
    } on FormatException {
      return null;
    }
  }

  String toServerDate() {
    return DateFormat(presentDatePattern).parse(this).toUtc().toIso8601String();
  }
}
