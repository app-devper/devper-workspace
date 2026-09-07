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
      status: json['status'] ?? 'ACTIVE',
      items: toReceiveItemsDomain(json['items'] ?? [], receiveId: json['id']),
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
      'items': param.items.map(toReceiveItemRequest).toList(),
    });
  }

  Map<String, dynamic> toReceiveItemRequest(ReceiveItem item) => {
        'productId': item.productId,
        'quantity': item.quantity,
        'costPrice': item.costPrice,
        'lotNumber': item.lotNumber,
        'expireDate': item.expireDate,
        'unitId': item.unitId,
        'baseQuantity': item.baseQuantity,
      };

  List<ReceiveItem> toReceiveItemsDomain(List json,
          {required String receiveId}) =>
      json
          .map((data) => toReceiveItemDomain(data, receiveId: receiveId))
          .toList();

  ReceiveItem toReceiveItemDomain(Map<String, dynamic> json,
          {required String receiveId}) =>
      ReceiveItem(
        receiveId: receiveId,
        productId: json['productId'],
        quantity: json['quantity'],
        costPrice: (json['costPrice'] as num).toDouble(),
        lotNumber: json['lotNumber'] ?? '',
        expireDate: json['expireDate'] ?? '',
        unitId: json['unitId'] ?? '',
        baseQuantity: json['baseQuantity'] ?? 0,
      );
}
