// Dart imports:
import 'dart:convert';

// Project imports:
import 'package:pos/domain/model/receive/param.dart';
import 'package:pos/domain/model/receive/receive.dart';
import 'package:pos/domain/model/receive/receive_item.dart';

class ReceiveMapper {
  List<Receive> toReceivesDomain(List json) {
    final lists = json.map((data) => toReceiveDomain(data)).toList();
    return lists;
  }

  Receive toReceiveDomain(Map<String, dynamic> json) {
    return Receive(
      id: json['id'],
      supplierId: json['supplierId'],
      code: json['code'],
      reference: json['reference'],
      totalCost: json['totalCost'].toDouble(),
      createdDate: json['createdDate'],
    );
  }

  String toReceiveRequest(ReceiveParam param) {
    return jsonEncode({
      'supplierId': param.supplierId,
      'reference': param.reference,
    });
  }

  String toUpdateReceiveRequest(UpdateReceiveParam param) {
    return jsonEncode({
      'supplierId': param.supplierId,
      'reference': param.reference,
      'totalCost': param.totalCost,
    });
  }

  List<ReceiveItem> toReceiveItemsDomain(List json) {
    final lists = json.map((data) => toReceiveItemDomain(data)).toList();
    return lists;
  }

  ReceiveItem toReceiveItemDomain(Map<String, dynamic> json) {
    return ReceiveItem(
      id: json['id'],
      receiveId: json['receiveId'],
      lotId: json['lotId'],
      productId: json['productId'],
      quantity: json['quantity'],
      costPrice: json['costPrice'].toDouble(),
    );
  }
}
