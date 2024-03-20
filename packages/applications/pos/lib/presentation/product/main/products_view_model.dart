// Dart imports:
import 'dart:async';

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:um/domain/repositories/login_repository.dart';

// Project imports:
import 'package:pos/domain/model/category/category.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/category_repository.dart';
import 'package:pos/domain/repositories/product_repository.dart';
import 'package:pos/presentation/order/core/export_csv.dart';
import 'products_state.dart';
import 'products_ui_model.dart';

class ProductsViewModel {
  final ProductRepository productRepo;
  final LoginRepository loginRepo;
  final CategoryRepository categoryRepo;

  ProductsViewModel({
    required this.productRepo,
    required this.loginRepo,
    required this.categoryRepo,
  });

  final _states = StreamController<ProductsState>();

  StreamController<ProductsState> get states => _states;

  final _products = StreamController<List<Product>>();

  StreamController<List<Product>> get products => _products;

  final _dropdownItems = StreamController<List<ListItem>>();

  StreamController<List<ListItem>> get dropdownItems => _dropdownItems;

  Category all() {
    return Category(
      id: "",
      name: "ทั้งหมด",
      value: "",
      description: "",
      isDefault: false,
      requireCustomerOrder: false,
    );
  }

  void initData() async {
    final dropdownItems = [
      ListItem(SortProduct.createdAsc, "Created: Old to New"),
      ListItem(SortProduct.createdDesc, "Created: New to Old"),
      ListItem(SortProduct.nameAsc, "Name: A-Z"),
      ListItem(SortProduct.nameDesc, "Name: Z-A"),
      ListItem(SortProduct.priceAsc, "Price: Low to High"),
      ListItem(SortProduct.priceDesc, "Price: High to Low"),
      ListItem(SortProduct.quantityAsc, "Quantity: Low to High"),
      ListItem(SortProduct.quantityDesc, "Quantity: High to Low"),
      ListItem(SortProduct.serialNoAsc, "Serial No.: Low to High"),
      ListItem(SortProduct.serialNoDesc, "Serial No.: High to Low"),
    ];
    if (!_dropdownItems.isClosed) {
      _dropdownItems.sink.add(dropdownItems);
    }
    try {
      final categories = await categoryRepo.getLocalCategories();
      _onGetCategoriesSuccess(categories);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  void checkLogin() async {
    try {
      final result = await loginRepo.getRole();
      _onCheckRole(result == "ADMIN");
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  void searchProduct(String text) async {
    try {
      final result = await productRepo.getLocalProducts();
      _onListProducts(text, result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  void getProducts(SortProduct sort, String category) async {
    _onLoading();
    try {
      final result = await productRepo.getProducts();
      _onProductsResult(sort, category, result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  void downloadProducts() async {
    try {
      final result = await productRepo.getLocalProducts();
      ExportCsv.downloadProducts(result);
    } on Exception catch (_) {}
  }

  void removeProduct(String productId) async {
    _onLoading();
    try {
      final result = await productRepo.removeProductById(productId);
      _onRemoveProduct(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  void setProducts(List<Product> data) {
    _products.sink.add(data);
  }

  _onLoading() {
    _states.sink.add(LoadingState());
  }

  _onCheckRole(bool isAdmin) {
    if (!_states.isClosed) {
      _states.sink.add((LoggedState(isAdmin)));
    }
  }

  _onListProducts(String text, List<Product> data) {
    if (!_states.isClosed) {
      _states.sink.add(ListProductsState(data: _searchProduct(text, data)));
    }
  }

  _onProductsResult(SortProduct sort, String category, List<Product> data) {
    if (!_states.isClosed) {
      _states.sink.add(ProductsResultState(
        data: _sortProduct(sort, category, data),
        totalCost: _calculateTotalCost(data),
      ));
    }
  }

  _onRemoveProduct(Product data) {
    if (!_states.isClosed) {
      _states.sink.add(RemoveProductState(data: data));
    }
  }

  _onGetCategoriesSuccess(List<Category> data) {
    if (!_states.isClosed) {
      final copied = List<Category>.from(data).toList();
      copied.insert(0, all());
      _states.sink.add(GetCategoryState(data: copied));
    }
  }

  _onError(Failure failure) {
    if (!_states.isClosed) {
      _states.sink.add(ErrorState(message: failure.getMessage()));
    }
  }

  dispose() {
    _states.close();
    _products.close();
    _dropdownItems.close();
  }

  double _calculateTotalCost(List<Product> data) {
    double price = 0;
    for (var x in data) {
      if (x.quantity > 0) {
        price += x.costPrice * x.quantity;
      }
    }
    return price;
  }

  List<Product> _sortProduct(SortProduct sort, String category, List<Product> data) {
    final filtered = data.where((element) => element.category == category).toList();
    switch (sort) {
      case SortProduct.nameAsc:
        filtered.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        return filtered;
      case SortProduct.nameDesc:
        filtered.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        return filtered;
      case SortProduct.priceAsc:
        filtered.sort((a, b) => a.price.compareTo(b.price));
        return filtered;
      case SortProduct.priceDesc:
        filtered.sort((a, b) => b.price.compareTo(a.price));
        return filtered;
      case SortProduct.costPriceAsc:
        filtered.sort((a, b) => a.costPrice.compareTo(b.costPrice));
        return filtered;
      case SortProduct.costPriceDesc:
        filtered.sort((a, b) => b.costPrice.compareTo(a.costPrice));
        return filtered;
      case SortProduct.quantityAsc:
        filtered.sort((a, b) => a.quantity.compareTo(b.quantity));
        return filtered;
      case SortProduct.quantityDesc:
        filtered.sort((a, b) => b.quantity.compareTo(a.quantity));
        return filtered;
      case SortProduct.createdAsc:
        return filtered;
      case SortProduct.createdDesc:
        return filtered.reversed.toList();
      case SortProduct.serialNoAsc:
        filtered.sort((a, b) => a.serialNumber.compareTo(b.serialNumber));
        return filtered;
      case SortProduct.serialNoDesc:
        filtered.sort((a, b) => b.serialNumber.compareTo(a.serialNumber));
        return filtered;
    }
  }

  List<Product> _searchProduct(String param, List<Product> data) {
    if (param.isEmpty) {
      return data;
    } else {
      List<Product> filtered = [];
      for (var item in data) {
        if (item.name.toLowerCase().contains(param.toLowerCase()) || item.serialNumber.contains(param)) {
          filtered.add(item);
        }
      }
      return filtered;
    }
  }
}
