// Package imports:
import 'package:pos/domain/model/receive/receive_item.dart';

// Project imports:
import 'package:pos/domain/model/supplier/supplier.dart';

class Receive {
  final String id;
  final String supplierId;
  final String code;
  final String reference;
  final double totalCost;
  final String createdDate;
  final String status;
  final List<ReceiveItem> items;
  bool get isImported => status == 'IMPORTED';
  Supplier? supplier;

  Receive({
    required this.id,
    required this.supplierId,
    required this.code,
    required this.reference,
    required this.totalCost,
    required this.createdDate,
    this.status = 'ACTIVE',
    this.items = const [],
    this.supplier,
  });
}
