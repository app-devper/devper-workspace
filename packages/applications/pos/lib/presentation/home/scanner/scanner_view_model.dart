// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/usecase/product/get_product_by_barcode_use_case.dart';
import 'scanner_state.dart';

class ScannerViewModel {
  final GetProductByBarcodeUseCase getProductByBarcodeUseCase;

  ScannerViewModel({
    required this.getProductByBarcodeUseCase,
  });

  final _state = ValueNotifier<ScannerState>(const ScannerState());

  ValueListenable<ScannerState> get state => _state;

  Future<void> getProductBySerialNumber(String serialNumber) async {
    _state.value = _state.value.copyWith(loading: true, clearError: true, clearLoaded: true);
    try {
      final result = await getProductByBarcodeUseCase(serialNumber);
      if (result == null) {
        _state.value = _state.value.copyWith(loading: false, error: "ไม่พบสินค้า");
        return;
      }
      _state.value = _state.value.copyWith(loading: false, loaded: result);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(loading: false, error: toFailure(e).getMessage());
    }
  }

  void consumeError() {
    if (_state.value.error != null) {
      _state.value = _state.value.copyWith(clearError: true);
    }
  }

  void consumeLoaded() {
    if (_state.value.loaded != null) {
      _state.value = _state.value.copyWith(clearLoaded: true);
    }
  }

  void dispose() {
    _state.dispose();
  }
}
