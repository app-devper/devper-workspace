// Dart imports:
import 'dart:convert';

// Project imports:
import 'package:pos/domain/model/receive/param.dart';
import 'package:pos/domain/model/receive/receive.dart';
import 'package:pos/domain/model/receive/receive_item.dart';

/// Extension methods, not a mapper object: there was never any state to hold,
/// and they only exist where this file is imported, so the repositories see
/// them and nothing else does.
///
/// jsonOrThrow returns dynamic and an extension cannot be reached through a
/// dynamic receiver — it compiles and then throws NoSuchMethodError. The casts
/// at the call sites are what keep that a compile error instead.
extension ReceiveJson on Map<String, dynamic> {
  Receive toReceiveDomain() {
    final json = this;

    return Receive(
      id: json['id'],
      supplierId: json['supplierId'],
      code: json['code'],
      reference: json['reference'],
      totalCost: json['totalCost'].toDouble(),
      createdDate: json['createdDate'],
      status: json['status'] ?? 'ACTIVE',
      items: ((json['items'] ?? []) as List)
          .toReceiveItemsDomain(receiveId: json['id']),
    );
  }
}

extension ReceiveItemListJson on List {
  /// receiveId comes from the parent document; the item rows do not carry it.
  List<ReceiveItem> toReceiveItemsDomain({required String receiveId}) =>
      map((data) => (data as Map<String, dynamic>)
          .toReceiveItemDomain(receiveId: receiveId)).toList();
}

extension ReceiveItemRequest on ReceiveItem {
  Map<String, dynamic> toReceiveItemRequest() => {
        'productId': productId,
        'quantity': quantity,
        'costPrice': costPrice,
        'lotNumber': lotNumber,
        'expireDate': expireDate,
        'unitId': unitId,
        'baseQuantity': baseQuantity,
      };
}

extension ReceiveListJson on List {
  List<Receive> toReceivesDomain() {
    final json = this;

    final lists = json
        .map((data) => (data as Map<String, dynamic>).toReceiveDomain())
        .toList();
    return lists;
  }
}

extension ReceiveItemJson on Map<String, dynamic> {
  ReceiveItem toReceiveItemDomain({required String receiveId}) => ReceiveItem(
        receiveId: receiveId,
        productId: this['productId'],
        quantity: this['quantity'],
        costPrice: (this['costPrice'] as num).toDouble(),
        lotNumber: this['lotNumber'] ?? '',
        expireDate: this['expireDate'] ?? '',
        unitId: this['unitId'] ?? '',
        baseQuantity: this['baseQuantity'] ?? 0,
      );
}

extension ReceiveParamRequest on ReceiveParam {
  String toReceiveRequest() {
    final param = this;

    return jsonEncode({
      'supplierId': param.supplierId,
      'reference': param.reference,
    });
  }
}

extension UpdateReceiveParamRequest on UpdateReceiveParam {
  String toUpdateReceiveRequest() {
    final param = this;

    return jsonEncode({
      'supplierId': param.supplierId,
      'reference': param.reference,
      'items': param.items.map((e) => e.toReceiveItemRequest()).toList(),
    });
  }
}
