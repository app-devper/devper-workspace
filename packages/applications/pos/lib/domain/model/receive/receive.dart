// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import 'package:pos/domain/model/supplier/supplier.dart';

class Receive {
  final String id;
  final String supplierId;
  final String code;
  final String reference;
  final double totalCost;
  final String createdDate;
  Supplier? supplier;

  Receive({
    required this.id,
    required this.supplierId,
    required this.code,
    required this.reference,
    required this.totalCost,
    required this.createdDate,
    this.supplier,
  });

  String getCreatedDate() {
    final date = DateTime.parse(createdDate);
    final format = DateFormat("dd/MM/yyyy HH:mm");
    return format.format(date.toLocal());
  }
}
