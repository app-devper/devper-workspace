// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:common/core/ext/number_ext.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';

// Project imports:
import 'package:pos/domain/model/customer/customer.dart';
import 'package:pos/domain/model/receipt/receipt.dart';
import 'package:pos/domain/model/supplier/supplier.dart';
import 'pdf_api.dart';

class ExportPdf {
  static Future<dynamic> generate(Receipt receipt) async {
    final font = await rootBundle.load("packages/common/assets/font/Sarabun-Regular.ttf");
    final ttf = pw.Font.ttf(font);
    return await PdfApi.saveDocument(name: '${receipt.info.number}.pdf', doc: genDocument(receipt, ttf));
  }

  static Future<dynamic> download(Receipt receipt) async {
    final font = await rootBundle.load("packages/common/assets/font/Sarabun-Regular.ttf");
    final ttf = pw.Font.ttf(font);
    return PdfApi.downloadDocument(name: '${receipt.info.number}.pdf', doc: genDocument(receipt, ttf));
  }

  static Document genDocument(Receipt invoice, Font font) {
    final pdf = Document();
    pdf.addPage(
      pw.MultiPage(
        theme: pw.ThemeData(
          defaultTextStyle: pw.TextStyle(font: font, height: 2.0),
        ),
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          buildTitle(invoice, font),
          buildHeader(invoice, font),
          SizedBox(height: 1 * PdfPageFormat.cm),
          buildInvoice(invoice, font),
          Divider(),
          buildTotal(invoice, font),
          SizedBox(height: 2 * PdfPageFormat.cm),
          buildReceipt(font)
        ],
      ),
    );

    return pdf;
  }

  static Widget buildHeader(Receipt receipt, Font font) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: buildSupplierAddress(receipt.supplier, font),
              ),
              SizedBox(width: 20),
              Container(
                width: 150,
                child: buildInvoiceInfo(receipt.info, font),
              ),
            ],
          ),
          SizedBox(height: 1 * PdfPageFormat.cm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildCustomerAddress(receipt.customer, font),
            ],
          ),
        ],
      );

  static Widget buildCustomerAddress(Customer customer, Font font) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ลูกค้า: ${customer.name}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              font: font,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'ที่อยู่: ${customer.address}',
            style: TextStyle(font: font, lineSpacing: 4),
          ),
        ],
      );

  static Widget buildInvoiceInfo(ReceiptInfo info, Font font) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildText(
          title: 'เลขที่:',
          value: info.number,
          width: 150,
          font: font,
        ),
        SizedBox(height: 4),
        buildText(
          title: 'วันที่:',
          value: info.date,
          width: 150,
          font: font,
        )
      ],
    );
  }

  static Widget buildSupplierAddress(Supplier supplier, Font font) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            supplier.name,
            style: TextStyle(fontWeight: FontWeight.bold, font: font, lineSpacing: 4),
          ),
          SizedBox(height: 1 * PdfPageFormat.mm),
          Text(
            supplier.address,
            style: TextStyle(font: font, lineSpacing: 4),
          ),
        ],
      );

  static Widget buildTitle(Receipt receipt, font) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ใบเสร็จรับเงิน',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              font: font,
            ),
          ),
          SizedBox(height: 0.8 * PdfPageFormat.cm),
        ],
      );

  static Widget buildInvoice(Receipt receipt, Font font) {
    final headers = ['รายละเอียด', 'จำนวน', 'ราคา/หน่วย', 'จำนวนเงิน'];
    final data = receipt.items.map((item) {
      final total = item.price;
      final price = item.price / item.quantity;
      return [
        item.product?.name ?? "",
        '${item.quantity}',
        (price.toStringAsFixed(2)),
        (total.toStringAsFixed(2)),
      ];
    }).toList();

    return TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: null,
      headerStyle: TextStyle(fontWeight: FontWeight.bold, font: font),
      headerDecoration: const BoxDecoration(color: PdfColors.grey300),
      cellHeight: 30,
      cellAlignments: {
        0: Alignment.centerLeft,
        1: Alignment.centerRight,
        2: Alignment.centerRight,
        3: Alignment.centerRight,
        4: Alignment.centerRight,
        5: Alignment.centerRight,
      },
    );
  }

  static Widget buildTotal(Receipt invoice, Font font) {
    final total = invoice.items.map((item) => item.price).reduce((item1, item2) => item1 + item2);
    final number = formatPrice(total);
    return Container(
      child: Row(
        children: [
          Expanded(
            flex: 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildText(
                  title: 'รวมจำนวนเงิน',
                  titleStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    font: font,
                  ),
                  value: convertAmountToLetter(number),
                  unite: true,
                  font: font,
                ),
                SizedBox(height: 2 * PdfPageFormat.mm),
                Container(height: 1, color: PdfColors.grey400),
                SizedBox(height: 0.5 * PdfPageFormat.mm),
                Container(height: 1, color: PdfColors.grey400),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildText(
                  title: '',
                  titleStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    font: font,
                  ),
                  value: formatPrice(total),
                  unite: true,
                  font: font,
                ),
                SizedBox(height: 2 * PdfPageFormat.mm),
                Container(height: 1, color: PdfColors.grey400),
                SizedBox(height: 0.5 * PdfPageFormat.mm),
                Container(height: 1, color: PdfColors.grey400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildReceipt(Font font) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ผู้รับเงิน:................................................................',
            style: TextStyle(fontWeight: FontWeight.bold, font: font),
          ),
        ],
      );

  static Widget buildFooter(Receipt invoice) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Divider(),
          SizedBox(height: 1 * PdfPageFormat.mm),
        ],
      );

  static pw.Container buildText({
    required String title,
    required String value,
    double width = double.infinity,
    TextStyle? titleStyle,
    bool unite = false,
    Font? font,
  }) {
    final style = titleStyle ?? TextStyle(fontWeight: FontWeight.bold, font: font, height: 2);

    return Container(
      width: width,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: style,
            ),
          ),
          Text(value, style: unite ? style : null),
        ],
      ),
    );
  }
}
