// Project imports:
import 'package:pos/domain/model/category/category.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/model/receive/receive.dart';
import 'package:pos/domain/model/receive/receive_item.dart';
import 'package:pos/domain/model/supplier/supplier.dart';

abstract class ReceiveEditState {}

class LoadingState extends ReceiveEditState {}

class GetReceiveState extends ReceiveEditState {
  final Receive data;
  final List<Supplier> suppliers;

  GetReceiveState({
    required this.data,
    required this.suppliers,
  });
}

class GetSuppliersState extends ReceiveEditState {
  final List<Supplier> suppliers;

  GetSuppliersState({
    required this.suppliers,
  });
}

class CreateReceiveState extends ReceiveEditState {
  final Receive data;

  CreateReceiveState({required this.data});
}

class UpdateReceiveState extends ReceiveEditState {
  final Receive data;

  UpdateReceiveState({required this.data});
}

class RemoveReceiveState extends ReceiveEditState {
  final Receive data;

  RemoveReceiveState({required this.data});
}

class RemoveReceiveItemState extends ReceiveEditState {
  final ReceiveItem data;

  RemoveReceiveItemState({required this.data});
}

class GetReceiveItemsState extends ReceiveEditState {
  final double totalCost;
  final List<ReceiveItem> data;

  GetReceiveItemsState({
    required this.totalCost,
    required this.data,
  });
}

class ErrorState extends ReceiveEditState {
  final String message;

  ErrorState({required this.message});
}
