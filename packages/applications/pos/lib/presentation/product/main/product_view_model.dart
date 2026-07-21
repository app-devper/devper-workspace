// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/usecase/product/clear_quantity_sold_first_by_id_use_case.dart';
import 'package:pos/domain/usecase/product/get_local_product_by_id_use_case.dart';
import 'package:pos/domain/usecase/product/get_local_products_use_case.dart';
import 'package:pos/domain/usecase/product/import_product_csv_use_case.dart';
import 'package:pos/presentation/order/core/export_csv.dart';
import 'package:pos/presentation/product/main/product_state.dart';

class ProductViewModel {
  final GetLocalProductByIdUseCase getLocalProductByIdUseCase;
  final GetLocalProductsUseCase getLocalProductsUseCase;
  final ImportProductCSVUseCase importProductCSVUseCase;
  final ClearQuantitySoldFirstByIdUseCase clearQuantitySoldFirstByIdUseCase;

  ProductViewModel({
    required this.getLocalProductByIdUseCase,
    required this.getLocalProductsUseCase,
    required this.importProductCSVUseCase,
    required this.clearQuantitySoldFirstByIdUseCase,
  });

  final _state = ValueNotifier<ProductState>(const ProductState());

  ValueListenable<ProductState> get state => _state;

  Future<void> getProduct(String productId) async {
    try {
      final data = await getLocalProductByIdUseCase(productId);
      if (data == null) {
        _state.value = _state.value.copyWith(error: "Product not found");
      } else {
        _state.value = _state.value.copyWith(loaded: data);
      }
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(error: toFailure(e).getMessage());
    }
  }

  Future<void> exportProducts() async {
    try {
      final result = await getLocalProductsUseCase();
      ExportCsv.downloadProducts(result);
    } on Exception catch (_) {}
  }

  Future<void> importCSV({required List<int> bytes, required String filename}) async {
    _state.value = _state.value.copyWith(loading: true, clearError: true, clearImportResult: true);
    try {
      final result = await importProductCSVUseCase(
        ImportProductCSVParam(bytes: bytes, filename: filename),
      );
      _state.value = _state.value.copyWith(loading: false, importResult: result);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(loading: false, error: toFailure(e).getMessage());
    }
  }

  Future<void> clearSoldFirst(String productId) async {
    _state.value = _state.value.copyWith(loading: true, clearError: true, clearLoaded: true);
    try {
      final result = await clearQuantitySoldFirstByIdUseCase(productId);
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

  void consumeImportResult() {
    if (_state.value.importResult != null) {
      _state.value = _state.value.copyWith(clearImportResult: true);
    }
  }

  void dispose() {
    _state.dispose();
  }
}
