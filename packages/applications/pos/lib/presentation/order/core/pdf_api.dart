// Package imports:
import 'package:flutter/foundation.dart';
import 'package:pdf/widgets.dart';
import 'package:universal_html/html.dart' as html;

class PdfApi {
  static Future<void> saveDocument({
    required String name,
    required Document doc,
  }) async {
    if (!kIsWeb) {
      return;
    }
    await downloadDocument(name: name, doc: doc);
  }

  static Future<void> downloadDocument({
    required String name,
    required Document doc,
  }) async {
    final bytes = await doc.save();
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    var anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = name;
    html.document.body?.children.add(anchor);
    anchor.click();
    anchor.remove();
  }
}
