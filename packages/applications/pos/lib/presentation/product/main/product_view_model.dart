// Dart imports:
import 'dart:async';

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:http/http.dart' as http;

// Project imports:
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/model/product/product_history.dart';
import 'package:pos/domain/repositories/product_repository.dart';
import 'package:pos/presentation/order/core/export_csv.dart';
import 'package:pos/presentation/product/main/product_state.dart';

class ProductViewModel {
  final ProductRepository productRepo;

  ProductViewModel({
    required this.productRepo,
  });

  final _states = StreamController<ProductState>();

  Stream<ProductState> get states => _states.stream;

  void getProduct(String productId) async {
    try {
      final data = await productRepo.getLocalProductById(productId);
      if (data == null) {
        _onError(Failure(errorCode: "A-000", error: "Product not found"));
      } else {
        _onGetProduct(data);
      }
    } on Failure catch (e) {
      _onError(e);
    }
  }

  void exportProducts() async {
    try {
      final result = await productRepo.getLocalProducts();
      ExportCsv.downloadProducts(result);
    } on Exception catch (_) {}
  }

  void importCSV(http.MultipartFile file) async {
    _onLoading();
    try {
      final result = await productRepo.importProductCSV(file);
      _onImportCSV(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  void clearSoldFirst(String productId) async {
    _onLoading();
    try {
      final result = await productRepo.clearQuantitySoldFirstById(productId);
      _onClearSoldFirst(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  getInit() {
    if (!_states.isClosed) {
      _states.sink.add(InitState());
    }
  }

  _onLoading() {
    if (!_states.isClosed) {
      _states.sink.add(LoadingState());
    }
  }

  _onGetProduct(Product data) {
    if (!_states.isClosed) {
      _states.sink.add(ProductInfoState(data: data));
    }
  }

  _onImportCSV(CSVImportResult data) {
    if (!_states.isClosed) {
      _states.sink.add(ImportCSVState(data: data));
    }
  }

  _onClearSoldFirst(Product data) {
    if (!_states.isClosed) {
      _states.sink.add(ClearSoldFirstState(data: data));
    }
  }

  _onError(Failure failure) {
    if (!_states.isClosed) {
      _states.sink.add(ErrorState(message: failure.getMessage()));
    }
  }

  dispose() {
    _states.close();
  }
}
