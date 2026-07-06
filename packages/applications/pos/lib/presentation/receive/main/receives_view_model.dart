// Dart imports:
import 'dart:async';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/receive/param.dart';
import 'package:pos/domain/model/receive/receive.dart';
import 'package:pos/domain/repositories/receive_repository.dart';
import 'package:pos/domain/repositories/supplier_repository.dart';

class ReceivesViewModel {
  final ReceiveRepository receiveRepo;
  final SupplierRepository supplierRepo;

  ReceivesViewModel({
    required this.receiveRepo,
    required this.supplierRepo,
  });

  final _receives = StreamController<List<Receive>>();

  Stream<List<Receive>> get receives => _receives.stream;

  void searchReceive(String s) {
    getReceives();
  }

  void getReceives() async {
    try {
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 365));
      final param = GetReceivesRangeParam(
        startDate: startDate.toUtc().toIso8601String(),
        endDate: now.toUtc().toIso8601String(),
      );
      final result = await receiveRepo.getReceives(param);
      _onListReceive("", result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  void _onListReceive(String param, List<Receive> data) {
    if (!_receives.isClosed) {
      _receives.sink.add(_searchReceive(param, data));
    }
  }

  void _onError(Failure failure) {
    if (!_receives.isClosed) {
      _receives.sink.addError(failure.getMessage());
    }
  }

  List<Receive> _searchReceive(String param, List<Receive> data) {
    if (param.isEmpty) {
      return data;
    } else {
      List<Receive> filtered = [];
      for (var item in data) {
        if (item.code.toLowerCase().contains(param.toLowerCase())) {
          filtered.add(item);
        }
      }
      return filtered;
    }
  }

  void dispose() {
    _receives.close();
  }
}
