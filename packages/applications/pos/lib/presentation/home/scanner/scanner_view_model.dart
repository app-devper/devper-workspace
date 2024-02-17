// Dart imports:
import 'dart:async';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/product_repository.dart';
import 'scanner_state.dart';

class ScannerViewModel {
  final ProductRepository productRepo;

  ScannerViewModel({
    required this.productRepo,
  });

  final _states = StreamController<ScannerState>();

  StreamController<ScannerState> get states => _states;

  void getProductBySerialNumber(String serialNumber) async {
    _onLoading();
    try {
      final result = await productRepo.getProductBySerialNumber(serialNumber);
      _onGetProductSuccess(result);
    } on Exception catch (e) {
      _onGetProductError(toFailure(e));
    }
  }

  _onLoading() {
    _states.sink.add(LoadingState());
  }

  _onGetProductSuccess(Product data) {
    if (!_states.isClosed) {
      _states.sink.add(GetProductState(data: data));
    }
  }

  _onGetProductError(Failure failure) {
    if (!_states.isClosed) {
      _states.sink.add(ErrorState(message: failure.getMessage()));
    }
  }

  dispose() {
    _states.close();
  }
}
