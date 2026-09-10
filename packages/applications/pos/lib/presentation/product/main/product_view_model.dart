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
      _state.value = _state.value.copyWith(
          task: data == null ? const ProductNotFound() : ProductFound(data));
    } on Exception catch (e) {
      _state.value =
          _state.value.copyWith(task: ProductTaskFailed(toFailure(e)));
    }
  }

  Future<void> exportProducts() async {
    _state.value = _state.value.copyWith(task: const ProductTask());
    try {
      final result = await getLocalProductsUseCase();
      ExportCsv.downloadProducts(result);
    } on Exception catch (e) {
      _state.value =
          _state.value.copyWith(task: ProductTaskFailed(toFailure(e)));
    }
  }

  Future<void> importCSV(
      {required List<int> bytes, required String filename}) async {
    if (_state.value.task is ProductTaskRunning) return;
    _state.value = _state.value.copyWith(task: const ProductTaskRunning());
    try {
      final result = await importProductCSVUseCase(
        ImportProductCSVParam(bytes: bytes, filename: filename),
      );
      _state.value = _state.value.copyWith(task: ImportFinished(result));
    } on Exception catch (e) {
      _state.value =
          _state.value.copyWith(task: ProductTaskFailed(toFailure(e)));
    }
  }

  Future<void> clearSoldFirst(String productId) async {
    if (_state.value.task is ProductTaskRunning) return;
    _state.value = _state.value.copyWith(task: const ProductTaskRunning());
    try {
      final result = await clearQuantitySoldFirstByIdUseCase(productId);
      _state.value = _state.value.copyWith(task: ProductFound(result));
    } on Exception catch (e) {
      _state.value =
          _state.value.copyWith(task: ProductTaskFailed(toFailure(e)));
    }
  }

  void consumeError() {
    if (_state.value.task is ProductTaskFailed ||
        _state.value.task is ProductNotFound) {
      _state.value = _state.value.copyWith(task: const ProductTask());
    }
  }

  void consumeLoaded() {
    if (_state.value.task is ProductFound) {
      _state.value = _state.value.copyWith(task: const ProductTask());
    }
  }

  void consumeImportResult() {
    if (_state.value.task is ImportFinished) {
      _state.value = _state.value.copyWith(task: const ProductTask());
    }
  }

  void dispose() {
    _state.dispose();
  }
}
