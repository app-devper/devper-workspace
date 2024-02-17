// Project imports:
import 'package:pos/domain/model/receive/receive.dart';
import 'package:pos/domain/model/receive/receive_item.dart';
import 'package:pos/domain/model/supplier/supplier.dart';

abstract class ReceiveManageState {}

class LoadingState extends ReceiveManageState {}

class GetReceiveState extends ReceiveManageState {
  final Receive? data;
  final List<Supplier> suppliers;

  GetReceiveState({
    required this.data,
    required this.suppliers,
  });
}

class GetSuppliersState extends ReceiveManageState {
  final List<Supplier> suppliers;

  GetSuppliersState({
    required this.suppliers,
  });
}

class CreateReceiveState extends ReceiveManageState {
  final Receive data;

  CreateReceiveState({required this.data});
}

class UpdateReceiveState extends ReceiveManageState {
  final Receive data;

  UpdateReceiveState({required this.data});
}

class RemoveReceiveState extends ReceiveManageState {
  final Receive data;

  RemoveReceiveState({required this.data});
}

class RemoveReceiveItemState extends ReceiveManageState {
  final ReceiveItem data;

  RemoveReceiveItemState({required this.data});
}

class GetReceiveItemsState extends ReceiveManageState {
  final double totalCost;
  final List<ReceiveItem> data;

  GetReceiveItemsState({
    required this.totalCost,
    required this.data,
  });
}

class ErrorState extends ReceiveManageState {
  final String message;

  ErrorState({required this.message});
}
