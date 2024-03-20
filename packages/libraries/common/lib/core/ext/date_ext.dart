// Package imports:
import 'package:intl/intl.dart';

const serverDatePattern = "yyyy-MM-dd";

const presentDatePattern = "dd/MM/yyyy";
const shortDatePattern = "d/M";

String formatDate(String? date, {String src = serverDatePattern, String dest = presentDatePattern}) {
  if (date == null || date.isEmpty) {
    return '';
  } else {
    var inputDate = DateFormat(src).parse(date);
    var outputFormat = DateFormat(dest);
    return outputFormat.format(inputDate);
  }
}

String formatShortDate(DateTime date) {
  var outputFormat = DateFormat(shortDatePattern);
  return outputFormat.format(date);
}

DateTime getCurrentDate() {
  return DateTime.now();
}

extension FormatDateTime on DateTime {
  formatShortDate() {
    final outputFormat = DateFormat(shortDatePattern);
    return outputFormat.format(this);
  }
}
