// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:pos/domain/model/core/core.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/product_repository.dart';
import 'package:pos/presentation/stock_count/manage/stock_count_item_picker_state.dart';

class StockCountItemPickerViewModel {
  final ProductRepository productRepo;

  StockCountItemPickerViewModel({
    required this.productRepo,
  });

  final _state = ValueNotifier<StockCountItemPickerState>(
      const StockCountItemPickerState());

  ValueListenable<StockCountItemPickerState> get state => _state;

  List<ProductUnitItem> _all = [];

  Future<void> getProducts() async {
    _state.value = _state.value.copyWith(loading: true, clearError: true);
    try {
      final products = await productRepo.getProducts();
      _all = [];
      for (var item in products) {
        if (item.status == productStatusActive) {
          _all.addAll(item.toProductItems());
        }
      }
      _state.value = _state.value
          .copyWith(loading: false, products: List<ProductUnitItem>.of(_all));
    } on Exception catch (_) {
      _state.value = _state.value
          .copyWith(loading: false, error: "โหลดสินค้าไม่สำเร็จ กรุณาลองใหม่");
    }
  }

  void searchProduct(String text) {
    if (text.isEmpty) {
      _state.value =
          _state.value.copyWith(products: List<ProductUnitItem>.of(_all));
    } else {
      final lower = text.toLowerCase();
      _state.value = _state.value.copyWith(
        products: _all
            .where((item) => item.name.toLowerCase().contains(lower))
            .toList(),
      );
    }
  }

  void selectProduct(ProductUnitItem product) {
    _state.value = _state.value.copyWith(selectedProduct: product);
  }

  void clearSelection() {
    _state.value = _state.value.copyWith(clearSelectedProduct: true);
  }

  void dispose() {
    _state.dispose();
  }
}
