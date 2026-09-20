import 'package:common/core/error/exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/model/category/category.dart';
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/model/product/product_history.dart';
import 'package:pos/domain/repositories/category_repository.dart';
import 'package:pos/domain/repositories/product_repository.dart';
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
    categoryRepo: categoryRepository,
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

ProductParam buildProductParam() {
  return ProductParam(
    name: 'Paracetamol',
    description: '',
    price: 0,
    costPrice: 0,
    unit: '',
    quantity: 0,
    serialNumber: '',
    category: 'c1',
    status: 'ACTIVE',
    lotNumber: null,
    expireDate: null,
    receiveId: null,
  );
}

ProductEditViewModel buildEditViewModel(ProductRepository productRepository) {
  return ProductEditViewModel(
    getLocalProductByIdUseCase: GetLocalProductByIdUseCase(
      productRepo: productRepository,
    ),
    updateProductByIdUseCase: UpdateProductByIdUseCase(
      productRepo: productRepository,
    ),
    removeProductByIdUseCase: RemoveProductByIdUseCase(
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

      final errors = <String>[];
      vm.errors.listen(errors.add);

      await vm.getCategories();
      await Future<void>.delayed(Duration.zero);

      expect(vm.state.value.categories, isEmpty);
      expect(errors, hasLength(1));
    });

    test('addProduct loads generated units and prices', () async {
      final repository = FakeProductRepository(product: buildProduct());
      final vm = buildAddViewModel(repository, FakeCategoryRepository());

      final created = <Product>[];
      vm.created.listen(created.add);

      await vm.addProduct(buildCreateParam());
      await Future<void>.delayed(Duration.zero);

      expect(vm.state.value.saving, isFalse);
      expect(created.single.id, 'p1');
      expect(repository.unitLoadCalls, 1);
      expect(repository.priceLoadCalls, 1);
    });
  });

  group('ProductEditViewModel', () {
    test('the loaded product reaches the form', () async {
      final vm = buildEditViewModel(
        FakeProductRepository(product: buildProduct()),
      );
      final loaded = <Product>[];
      vm.loaded.listen(loaded.add);

      await vm.getProductById('p1');
      await Future<void>.delayed(Duration.zero);

      expect(vm.state.value.loading, isFalse);
      expect(loaded.single.id, 'p1');
    });

    test('a product that is not there is reported, not left blank', () async {
      final vm = buildEditViewModel(FakeProductRepository());
      final loaded = <Product>[];
      final errors = <String>[];
      vm.loaded.listen(loaded.add);
      vm.errors.listen(errors.add);

      await vm.getProductById('missing');
      await Future<void>.delayed(Duration.zero);

      expect(loaded, isEmpty);
      expect(errors, ['Product not found']);
    });

    test('a failed load is reported and stops the spinner', () async {
      final vm = buildEditViewModel(
        FakeProductRepository(
          error: const NetworkException(message: 'offline'),
        ),
      );
      final errors = <String>[];
      vm.errors.listen(errors.add);

      await vm.getProductById('p1');
      await Future<void>.delayed(Duration.zero);

      expect(vm.state.value.loading, isFalse);
      expect(errors, hasLength(1));
    });

    test('a failed save tells the user instead of looking like it worked',
        () async {
      final vm = buildEditViewModel(
        FakeProductRepository(
          error: const NetworkException(message: 'offline'),
        ),
      );
      final updated = <Product>[];
      final errors = <String>[];
      vm.updated.listen(updated.add);
      vm.errors.listen(errors.add);

      await vm.updateProductById('p1', buildProductParam());
      await Future<void>.delayed(Duration.zero);

      expect(updated, isEmpty);
      expect(errors, hasLength(1),
          reason: 'the page used to consume this error and show nothing');
    });

    test('a save announces the product the server gave back', () async {
      final vm = buildEditViewModel(
        FakeProductRepository(product: buildProduct()),
      );
      final updated = <Product>[];
      vm.updated.listen(updated.add);

      await vm.updateProductById('p1', buildProductParam());
      await Future<void>.delayed(Duration.zero);

      expect(updated.single.id, 'p1');
    });

    test('a delete announces the product it removed', () async {
      final vm = buildEditViewModel(
        FakeProductRepository(product: buildProduct()),
      );
      final removed = <Product>[];
      vm.removed.listen(removed.add);

      await vm.removeProductById('p1');
      await Future<void>.delayed(Duration.zero);

      expect(removed.single.id, 'p1');
    });
  });

  group('ProductViewModel', () {
    test('getProduct reports a missing local product', () async {
      final vm = buildProductViewModel(FakeProductRepository());
      final loaded = <Product>[];
      final errors = <String>[];
      vm.loaded.listen(loaded.add);
      vm.errors.listen(errors.add);

      await vm.getProduct('missing');
      await Future<void>.delayed(Duration.zero);

      expect(loaded, isEmpty);
      expect(errors, hasLength(1));
    });

    test('importCSV exposes the import summary', () async {
      final vm = buildProductViewModel(
        FakeProductRepository(product: buildProduct()),
      );

      final results = <CSVImportResult>[];
      vm.importResults.listen(results.add);

      await vm.importCSV(bytes: [1, 2, 3], filename: 'products.csv');
      await Future<void>.delayed(Duration.zero);

      expect(vm.state.value.loading, isFalse);
      expect(results.single.success, 1);
    });

    test('a failed import emits an error and no summary', () async {
      final vm = buildProductViewModel(
        FakeProductRepository(
          error: const NetworkException(message: 'offline'),
        ),
      );
      final results = <CSVImportResult>[];
      final errors = <String>[];
      vm.importResults.listen(results.add);
      vm.errors.listen(errors.add);

      await vm.importCSV(bytes: [1], filename: 'products.csv');
      await Future<void>.delayed(Duration.zero);

      expect(vm.state.value.loading, isFalse);
      expect(results, isEmpty);
      expect(errors, hasLength(1));
    });
  });

  group('one task at a time', () {
    test('a serial number and a save arrive on their own channels', () async {
      final vm = buildAddViewModel(
          FakeProductRepository(product: buildProduct()),
          FakeCategoryRepository());
      final serials = <String>[];
      final created = <Product>[];
      vm.serialNumbers.listen(serials.add);
      vm.created.listen(created.add);

      await vm.generateSerialNumber();
      await vm.addProduct(buildCreateParam());
      await Future<void>.delayed(Duration.zero);

      expect(serials, ['SN-1']);
      expect(created, hasLength(1),
          reason: 'one slot used to mean the save erased the serial number');
    });

    test('an import and a lookup each reach the view', () async {
      final vm =
          buildProductViewModel(FakeProductRepository(product: buildProduct()));
      final results = <CSVImportResult>[];
      final loaded = <Product>[];
      vm.importResults.listen(results.add);
      vm.loaded.listen(loaded.add);

      await vm.importCSV(bytes: const [1], filename: 'p.csv');
      await vm.getProduct('p1');
      await Future<void>.delayed(Duration.zero);

      expect(results, hasLength(1));
      expect(loaded, hasLength(1),
          reason: 'one slot used to mean the lookup erased the import summary');
    });
  });
}
