import 'package:common/core/error/exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/category/category.dart';
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/model/product/product_history.dart';
import 'package:pos/domain/repositories/category_repository.dart';
import 'package:pos/domain/repositories/product_repository.dart';
import 'package:pos/domain/usecase/category/get_local_categories_use_case.dart';
import 'package:pos/domain/usecase/product/add_product_use_case.dart';
import 'package:pos/domain/usecase/product/clear_quantity_sold_first_by_id_use_case.dart';
import 'package:pos/domain/usecase/product/generate_serial_number_use_case.dart';
import 'package:pos/domain/usecase/product/get_local_product_by_id_use_case.dart';
import 'package:pos/domain/usecase/product/get_local_products_use_case.dart';
import 'package:pos/domain/usecase/product/get_product_prices_by_product_id_use_case.dart';
import 'package:pos/domain/usecase/product/get_product_units_by_product_id_use_case.dart';
import 'package:pos/domain/usecase/product/import_product_csv_use_case.dart';
import 'package:pos/domain/usecase/product/remove_product_by_id_use_case.dart';
import 'package:pos/domain/usecase/product/update_product_by_id_use_case.dart';
import 'package:pos/presentation/product/add/product_add_view_model.dart';
import 'package:pos/presentation/product/edit/product_edit_view_model.dart';
import 'package:pos/presentation/product/main/product_view_model.dart';

class FakeCategoryRepository implements CategoryRepository {
  final List<Category> categories;
  final Object? error;

  FakeCategoryRepository({this.categories = const [], this.error});

  @override
  Future<List<Category>> getLocalCategories() async {
    if (error != null) throw error!;
    return categories;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class FakeProductRepository implements ProductRepository {
  final Product? product;
  final Object? error;
  final CSVImportResult importResult;
  var unitLoadCalls = 0;
  var priceLoadCalls = 0;

  FakeProductRepository({
    this.product,
    this.error,
    CSVImportResult? importResult,
  }) : importResult = importResult ??
            CSVImportResult(total: 1, success: 1, failed: 0, errors: const []);

  void _throwIfNeeded() {
    if (error != null) throw error!;
  }

  @override
  Future<Product> addProduct(CreateProductParam param) async {
    _throwIfNeeded();
    return product!;
  }

  @override
  Future<Product?> getLocalProductById(String productId) async {
    _throwIfNeeded();
    return product;
  }

  @override
  Future<List<Product>> getLocalProducts() async {
    _throwIfNeeded();
    return product == null ? [] : [product!];
  }

  @override
  Future<String> generateSerialNumber() async {
    _throwIfNeeded();
    return 'SN-1';
  }

  @override
  Future<List<ProductUnit>> getProductUnitsByProductId(String productId) async {
    _throwIfNeeded();
    unitLoadCalls++;
    return const [];
  }

  @override
  Future<List<ProductPrice>> getProductPricesByProductId(
      String productId) async {
    _throwIfNeeded();
    priceLoadCalls++;
    return const [];
  }

  @override
  Future<Product> updateProductById(
      String productId, ProductParam param) async {
    _throwIfNeeded();
    return product!;
  }

  @override
  Future<Product> removeProductById(String productId) async {
    _throwIfNeeded();
    return product!;
  }

  @override
  Future<CSVImportResult> importProductCSV({
    required List<int> bytes,
    required String filename,
  }) async {
    _throwIfNeeded();
    return importResult;
  }

  @override
  Future<Product> clearQuantitySoldFirstById(String productId) async {
    _throwIfNeeded();
    return product!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

Product buildProduct() {
  return Product(
    id: 'p1',
    name: 'พาราเซตามอล',
    status: 'Active',
    category: 'Medicine',
    createdDate: '2026-01-01',
    units: const [],
    prices: const [],
    stocks: const [],
  );
}

Category buildCategory() {
  return Category(
    id: 'c1',
    name: 'ยา',
    value: 'Medicine',
    description: '',
    isDefault: true,
    requireCustomerOrder: false,
  );
}

CreateProductParam buildCreateParam() {
  return CreateProductParam(
    name: 'พาราเซตามอล',
    price: 10,
    costPrice: 5,
    unit: 'เม็ด',
    serialNumber: 'SN-1',
    category: 'Medicine',
    status: 'Active',
  );
}

ProductAddViewModel buildAddViewModel(
  ProductRepository productRepository,
  CategoryRepository categoryRepository,
) {
  return ProductAddViewModel(
    getLocalCategoriesUseCase: GetLocalCategoriesUseCase(
      categoryRepo: categoryRepository,
    ),
    generateSerialNumberUseCase: GenerateSerialNumberUseCase(
      productRepo: productRepository,
    ),
    addProductUseCase: AddProductUseCase(productRepo: productRepository),
    getProductUnitsByProductIdUseCase: GetProductUnitsByProductIdUseCase(
      productRepo: productRepository,
    ),
    getProductPricesByProductIdUseCase: GetProductPricesByProductIdUseCase(
      productRepo: productRepository,
    ),
  );
}

ProductEditViewModel buildEditViewModel(
  ProductRepository productRepository,
  CategoryRepository categoryRepository,
) {
  return ProductEditViewModel(
    getLocalProductByIdUseCase: GetLocalProductByIdUseCase(
      productRepo: productRepository,
    ),
    getLocalCategoriesUseCase: GetLocalCategoriesUseCase(
      categoryRepo: categoryRepository,
    ),
    updateProductByIdUseCase: UpdateProductByIdUseCase(
      productRepo: productRepository,
    ),
    removeProductByIdUseCase: RemoveProductByIdUseCase(
      productRepo: productRepository,
    ),
    generateSerialNumberUseCase: GenerateSerialNumberUseCase(
      productRepo: productRepository,
    ),
  );
}

ProductViewModel buildProductViewModel(ProductRepository repository) {
  return ProductViewModel(
    getLocalProductByIdUseCase: GetLocalProductByIdUseCase(
      productRepo: repository,
    ),
    getLocalProductsUseCase: GetLocalProductsUseCase(productRepo: repository),
    importProductCSVUseCase: ImportProductCSVUseCase(productRepo: repository),
    clearQuantitySoldFirstByIdUseCase: ClearQuantitySoldFirstByIdUseCase(
      productRepo: repository,
    ),
  );
}

void main() {
  group('ProductAddViewModel', () {
    test('getCategories maps a typed exception to state.error', () async {
      final vm = buildAddViewModel(
        FakeProductRepository(product: buildProduct()),
        FakeCategoryRepository(
          error: const NetworkException(message: 'offline'),
        ),
      );

      await vm.getCategories();

      expect(vm.state.value.categories, isEmpty);
      expect(vm.state.value.error, isNotNull);
    });

    test('addProduct loads generated units and prices', () async {
      final repository = FakeProductRepository(product: buildProduct());
      final vm = buildAddViewModel(repository, FakeCategoryRepository());

      await vm.addProduct(buildCreateParam());

      expect(vm.state.value.saving, isFalse);
      expect(vm.state.value.created?.id, 'p1');
      expect(repository.unitLoadCalls, 1);
      expect(repository.priceLoadCalls, 1);
    });
  });

  group('ProductEditViewModel', () {
    test('getProductById loads product and categories', () async {
      final vm = buildEditViewModel(
        FakeProductRepository(product: buildProduct()),
        FakeCategoryRepository(categories: [buildCategory()]),
      );

      await vm.getProductById('p1');

      expect(vm.state.value.loading, isFalse);
      expect(vm.state.value.loaded?.id, 'p1');
      expect(vm.state.value.categories.single.id, 'c1');
    });

    test('getProductById maps a typed exception to state.error', () async {
      final vm = buildEditViewModel(
        FakeProductRepository(
          error: const NetworkException(message: 'offline'),
        ),
        FakeCategoryRepository(),
      );

      await vm.getProductById('p1');

      expect(vm.state.value.loading, isFalse);
      expect(vm.state.value.loaded, isNull);
      expect(vm.state.value.error, isNotNull);
    });
  });

  group('ProductViewModel', () {
    test('getProduct reports a missing local product', () async {
      final vm = buildProductViewModel(FakeProductRepository());

      await vm.getProduct('missing');

      expect(vm.state.value.loaded, isNull);
      expect(vm.state.value.error, isNotNull);
    });

    test('importCSV exposes the import summary', () async {
      final vm = buildProductViewModel(
        FakeProductRepository(product: buildProduct()),
      );

      await vm.importCSV(bytes: [1, 2, 3], filename: 'products.csv');

      expect(vm.state.value.loading, isFalse);
      expect(vm.state.value.importResult?.success, 1);
      expect(vm.state.value.error, isNull);
    });

    test('importCSV maps a typed exception to state.error', () async {
      final vm = buildProductViewModel(
        FakeProductRepository(
          error: const NetworkException(message: 'offline'),
        ),
      );

      await vm.importCSV(bytes: [1], filename: 'products.csv');

      expect(vm.state.value.loading, isFalse);
      expect(vm.state.value.importResult, isNull);
      expect(vm.state.value.error, isNotNull);
    });
  });
}
