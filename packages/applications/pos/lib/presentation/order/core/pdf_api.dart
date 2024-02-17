// Dart imports:
import 'dart:io';

// Package imports:
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart';
import 'package:universal_html/html.dart' as html;

class PdfApi {
  static saveDocument({
    required String name,
    required Document doc,
  }) async {
    final bytes = await doc.save();

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes);

    final url = file.path;
    await OpenFile.open(url);
  }

  static downloadDocument({
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
