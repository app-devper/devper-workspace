// Package imports:
import 'package:intl/intl.dart';

class ProductHistory {
  final String id;
  final String productId;
  final String type;
  final String description;
  final String unit;
  final int import;
  final int quantity;
  final double costPrice;
  final double price;
  final int balance;
  final String createdDate;

  ProductHistory({
    required this.id,
    required this.productId,
    required this.type,
    required this.description,
    required this.unit,
    required this.import,
    required this.quantity,
    required this.costPrice,
    required this.price,
    required this.balance,
    required this.createdDate,
  });

  String getCreatedDate() {
    final date = DateTime.parse(createdDate);
    final format = DateFormat("dd/MM/yyyy HH:mm");
    return format.format(date.toLocal());
  }
}

class DrugInteractionResult {
  final String productAId;
  final String productAName;
  final String productBId;
  final String productBName;
  final String interaction;

  DrugInteractionResult({
    required this.productAId,
    required this.productAName,
    required this.productBId,
    required this.productBName,
    required this.interaction,
  });
}

class CSVImportResult {
  final int total;
  final int success;
  final int failed;
  final List<String> errors;

  CSVImportResult({
    required this.total,
    required this.success,
    required this.failed,
    required this.errors,
  });
}
