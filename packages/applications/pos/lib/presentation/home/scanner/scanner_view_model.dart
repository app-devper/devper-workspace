// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:common/core/state/one_shot.dart';

// Project imports:
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/usecase/product/get_product_by_barcode_use_case.dart';
import 'scanner_state.dart';

class ScannerViewModel {
  final GetProductByBarcodeUseCase getProductByBarcodeUseCase;

  ScannerViewModel({
    required this.getProductByBarcodeUseCase,
  });

  final _state = ValueNotifier<ScannerState>(const ScannerState());

  /// Delivered once each: a hit opens the edit screen, a miss or a failure
  /// flashes a dialog and resumes the camera.
  final _loaded = OneShot<Product>();
  final _errors = OneShot<String>();

  ValueListenable<ScannerState> get state => _state;

  Stream<Product> get loaded => _loaded.stream;

  Stream<String> get errors => _errors.stream;

  Future<void> getProductBySerialNumber(String serialNumber) async {
    if (_state.value.loading) return;
    _state.value = _state.value.copyWith(loading: true);
    try {
      final result = await getProductByBarcodeUseCase(serialNumber);
      if (result == null) {
        _errors.emit("ไม่พบสินค้า");
        return;
      }
      _loaded.emit(result);
    } on Exception catch (e) {
      _errors.emit(toFailure(e).getMessage());
    } finally {
      _state.value = _state.value.copyWith(loading: false);
    }
  }

  void dispose() {
    _state.dispose();
    _loaded.dispose();
    _errors.dispose();
  }
}
