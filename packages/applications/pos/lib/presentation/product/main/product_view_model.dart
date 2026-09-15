// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:common/core/state/one_shot.dart';

// Project imports:
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/model/product/product_history.dart';
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

  /// Each is acted on once: the product opens a panel, the tally and the
  /// failures flash a snackbar.
  final _loaded = OneShot<Product>();
  final _importResults = OneShot<CSVImportResult>();
  final _errors = OneShot<String>();

  ValueListenable<ProductState> get state => _state;

  Stream<Product> get loaded => _loaded.stream;

  Stream<CSVImportResult> get importResults => _importResults.stream;

  Stream<String> get errors => _errors.stream;

  Future<void> getProduct(String productId) async {
    try {
      final data = await getLocalProductByIdUseCase(productId);
      if (data == null) {
        _errors.emit('Product not found');
        return;
      }
      _loaded.emit(data);
    } on Exception catch (e) {
      _errors.emit(toFailure(e).getMessage());
    }
  }

  Future<void> exportProducts() async {
    try {
      final result = await getLocalProductsUseCase();
      ExportCsv.downloadProducts(result);
    } on Exception catch (e) {
      _errors.emit(toFailure(e).getMessage());
    }
  }

  Future<void> importCSV(
      {required List<int> bytes, required String filename}) async {
    if (_state.value.loading) return;
    _state.value = _state.value.copyWith(loading: true);
    try {
      _importResults.emit(await importProductCSVUseCase(
        ImportProductCSVParam(bytes: bytes, filename: filename),
      ));
    } on Exception catch (e) {
      _errors.emit(toFailure(e).getMessage());
    } finally {
      _state.value = _state.value.copyWith(loading: false);
    }
  }

  Future<void> clearSoldFirst(String productId) async {
    if (_state.value.loading) return;
    _state.value = _state.value.copyWith(loading: true);
    try {
      _loaded.emit(await clearQuantitySoldFirstByIdUseCase(productId));
    } on Exception catch (e) {
      _errors.emit(toFailure(e).getMessage());
    } finally {
      _state.value = _state.value.copyWith(loading: false);
    }
  }

  void dispose() {
    _state.dispose();
    _loaded.dispose();
    _importResults.dispose();
    _errors.dispose();
  }
}
