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
    _state.value = _state.value.copyWith(task: const ScannerRunning());
    try {
      final result = await getProductByBarcodeUseCase(serialNumber);
      if (result == null) {
        _state.value =
            _state.value.copyWith(task: const ScannerRejected("ไม่พบสินค้า"));
        return;
      }
      _state.value = _state.value.copyWith(task: ScannerLoaded(result));
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(task: ScannerFailed(toFailure(e)));
    }
  }

  void consumeError() {
    if (_state.value.task is ScannerFailed ||
        _state.value.task is ScannerRejected) {
      _state.value = _state.value.copyWith(task: const ScannerTask());
    }
  }

  void consumeLoaded() {
    if (_state.value.task is ScannerLoaded) {
      _state.value = _state.value.copyWith(task: const ScannerTask());
    }
  }

  void dispose() {
    _state.dispose();
  }
}
