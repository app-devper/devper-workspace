// Dart imports:
import 'dart:async';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/receive/param.dart';
import 'package:pos/domain/model/receive/receive.dart';
import 'package:pos/domain/repositories/receive_repository.dart';
import 'package:pos/domain/repositories/supplier_repository.dart';
import 'package:pos/presentation/receive/main/receives_state.dart';

class ReceivesViewModel {
  final ReceiveRepository receiveRepo;
  final SupplierRepository supplierRepo;

  ReceivesViewModel({
    required this.receiveRepo,
    required this.supplierRepo,
  });

  final _states = StreamController<ReceivesState>();

  Stream<ReceivesState> get states => _states.stream;

  final _receives = StreamController<List<Receive>>();

  Stream<List<Receive>> get receives => _receives.stream;

  void getReceives() async {
    try {
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 365));
      final result = await receiveRepo.getReceives(
        GetReceivesRangeParam(
          startDate: startDate.toUtc().toIso8601String(),
          endDate: now.toUtc().toIso8601String(),
        ),
      );
      final _ = await supplierRepo.getSuppliers();
      for (var item in result) {
        item.supplier = await supplierRepo.getLocalSupplierById(item.supplierId);
      }
      _onListReceive(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  void setReceives(List<Receive> data) {
    _receives.sink.add(data);
  }

  void _onLoading() {
    _states.sink.add(LoadingState());
  }

  void _onListReceive(List<Receive> data) {
    if (!_states.isClosed) {
      _states.sink.add(ListReceiveState(
        data: data,
        totalCost: _calculateTotalCost(data),
      ));
    }
  }

  void _onError(Failure failure) {
    if (!_states.isClosed) {
      _states.sink.add(ErrorState(message: failure.getMessage()));
    }
  }

  double _calculateTotalCost(List<Receive> data) {
    double total = 0;
    for (var x in data) {
      total += x.totalCost;
    }
    return total;
  }

  void dispose() {
    _states.close();
    _receives.close();
  }
}
