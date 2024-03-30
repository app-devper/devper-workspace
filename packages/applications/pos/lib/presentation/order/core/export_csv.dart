// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;

// Project imports:
import 'package:pos/domain/model/order/order_item_detail.dart';
import 'package:pos/domain/model/product/product.dart';

class ExportCsv {
  static downloadOrderItems(Product product, List<OrderItemDetail> data) async {
    List<List<dynamic>> rows = <List<dynamic>>[];
    List<dynamic> row = [];
    row.add("No.");
    row.add("Date");
    row.add("Name");
    row.add("Quantity");
    row.add("Price");
    rows.add(row);
    for (int i = 0; i < data.length; i++) {
      List<dynamic> row = [];
      row.add(i + 1);
      row.add(data[i].getCreatedDate());
      row.add(data[i].order?.customerName ?? "");
      row.add(data[i].quantity);
      row.add(data[i].price);
      rows.add(row);
    }

    String csv = const ListToCsvConverter().convert(rows);
    var format = DateFormat("yyyy-MM-dd");
    var date = format.format(DateTime.now().toLocal());
    String filename = "${product.name.trim()}-$date.csv";

    if (kIsWeb) {
      html.AnchorElement(href: "data:text/plain;charset=utf-8,$csv")
        ..setAttribute("download", filename)
        ..click();
    } else {
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/$filename");
      await file.writeAsString(csv);
      final url = file.path;
      await OpenFile.open(url);
    }
  }

  static downloadProducts(List<Product> data) async {
    List<List<dynamic>> rows = <List<dynamic>>[];
    List<dynamic> row = [];
    row.add("No.");
    row.add("Id");
    row.add("ชื่อสินค้า");
    row.add("ราคาขาย");
    row.add("หน่วยนับ");
    row.add("ขนาดบรรจุ");
    row.add("ต้นทุน");
    row.add("บาร์โค้ด");
    row.add("คงเหลือ");
    row.add("ปริมาณ");
    row.add("หน่วยปริมาณ");
    rows.add(row);
    int index = 0;
    for (int i = 0; i < data.length; i++) {
      for (int j = 0; j < data[i].units.length; j++) {
        print(data[i].name);
        List<dynamic> row = [];
        row.add(index + 1);
        row.add(data[i].id);
        row.add(data[i].name.replaceAll("#", " "));
        row.add(data[i].getDefaultPriceUnit(data[i].units[j].id).price);
        row.add(data[i].units[j].unit);
        row.add(data[i].units[j].size);
        row.add(data[i].units[j].costPrice);
        row.add(data[i].units[j].barcode);
        row.add(data[i].getQuantityByUnit(data[i].units[j].id));
        row.add(data[i].units[j].volume == 0 ? "" : data[i].units[j].volume);
        row.add(data[i].units[j].volumeUnit);
        rows.add(row);
        index++;
      }
    }

    String csv = const ListToCsvConverter().convert(rows);
    var format = DateFormat("yyyy-MM-dd");
    var date = format.format(DateTime.now().toLocal());
    String filename = "products-$date.csv";

    if (kIsWeb) {
      html.AnchorElement(href: "data:text/plain;charset=utf-8,$csv")
        ..setAttribute("download", filename)
        ..click();
    } else {
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/$filename");
      await file.writeAsString(csv);
      final url = file.path;
      await OpenFile.open(url);
    }
  }
}
