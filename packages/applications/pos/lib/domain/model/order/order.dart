// Project imports:
import 'package:pos/domain/model/product/product.dart';

class Order {
  final String id;
  final String code;
  final String customerCode;
  final String customerName;
  final String? patientId;
  final String? pharmacistName;
  final String? licenseNo;
  final String? prescriberName;
  final String? buyerName;
  final String? buyerIdCard;
  final String createdDate;
  final double total;
  final double totalCost;
  final double discount;
  final String type;

  Order({
    required this.id,
    required this.code,
    required this.customerCode,
    required this.customerName,
    this.patientId,
    this.pharmacistName,
    this.licenseNo,
    this.prescriberName,
    this.buyerName,
    this.buyerIdCard,
    required this.createdDate,
    required this.total,
    required this.totalCost,
    required this.discount,
    required this.type,
  });
}

class OrderResult {
  final Order data;
  final List<ProductStock> stocks;

  OrderResult({
    required this.data,
    required this.stocks,
  });
}
