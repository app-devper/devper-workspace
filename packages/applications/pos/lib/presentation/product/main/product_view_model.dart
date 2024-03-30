// Dart imports:
import 'dart:async';

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:pos/presentation/order/core/export_csv.dart';
import 'package:pos/presentation/product/main/product_state.dart';

// Project imports:
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/product_repository.dart';

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

  getInit() {
    if (!_states.isClosed) {
      _states.sink.add(InitState());
    }
  }

  _onGetProduct(Product data) {
    if (!_states.isClosed) {
      _states.sink.add(ProductInfoState(data: data));
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
