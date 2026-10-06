import 'package:common/localizations/localizations_delegate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/container.dart';
import 'package:pos/domain/model/core/core.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/product_repository.dart';
import 'package:pos/domain/usecase/product/clear_quantity_sold_first_by_id_use_case.dart';
import 'package:pos/domain/usecase/product/get_local_product_by_id_use_case.dart';
import 'package:pos/domain/usecase/product/get_local_products_use_case.dart';
import 'package:pos/domain/usecase/product/import_product_csv_use_case.dart';
import 'package:pos/domain/usecase/product/remove_product_by_id_use_case.dart';
import 'package:pos/domain/usecase/product/update_product_by_id_use_case.dart';
import 'package:pos/presentation/constants.dart';
import 'package:pos/presentation/product/argument.dart';
import 'package:pos/presentation/product/edit/product_edit_page.dart';
import 'package:pos/presentation/product/edit/product_edit_view_model.dart';
import 'package:pos/presentation/product/main/product_page.dart';
import 'package:pos/presentation/product/main/product_view_model.dart';
import 'package:pos/presentation/product/main/products_view_model.dart';
import 'package:pos/presentation/router.dart';

/// The shop's catalogue, in memory. Removing a Product takes it out, the way
/// the real repository takes it out of its cache.
class Catalogue implements ProductRepository {
  final List<Product> products;

  Catalogue(this.products);

  @override
  Future<List<Product>> getLocalProducts() async => List.of(products);

  @override
  Future<Product?> getLocalProductById(String id) async =>
      products.where((p) => p.id == id).firstOrNull;

  @override
  Future<Product> removeProductById(String productId) async {
    final product = products.firstWhere((p) => p.id == productId);
    products.remove(product);
    return product;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Product _paracetamol() {
  return Product(
    id: 'p-1',
    name: 'Paracetamol',
    status: productStatusActive,
    category: 'General',
    createdDate: '',
    units: [
      ProductUnit(
        id: 'u-1',
        productId: 'p-1',
        costPrice: 4,
        unit: 'เม็ด',
        size: 1,
        barcode: '111',
        volume: 0,
        volumeUnit: '',
      ),
    ],
    prices: [
      ProductPrice(
        id: 'price-1',
        productId: 'p-1',
        unitId: 'u-1',
        customerType: customerTypeGeneral,
        price: 10,
      ),
    ],
    stocks: const [],
  );
}

void main() {
  late Catalogue catalogue;

  setUp(() {
    catalogue = Catalogue([_paracetamol()]);
    sl.registerFactory<ProductViewModel>(() => ProductViewModel(
          getLocalProductByIdUseCase:
              GetLocalProductByIdUseCase(productRepo: catalogue),
          getLocalProductsUseCase:
              GetLocalProductsUseCase(productRepo: catalogue),
          importProductCSVUseCase:
              ImportProductCSVUseCase(productRepo: catalogue),
          clearQuantitySoldFirstByIdUseCase:
              ClearQuantitySoldFirstByIdUseCase(productRepo: catalogue),
        ));
    sl.registerFactory<ProductsViewModel>(() => ProductsViewModel(
          getLocalProductsUseCase:
              GetLocalProductsUseCase(productRepo: catalogue),
        ));
    sl.registerFactory<ProductEditViewModel>(() => ProductEditViewModel(
          getLocalProductByIdUseCase:
              GetLocalProductByIdUseCase(productRepo: catalogue),
          updateProductByIdUseCase:
              UpdateProductByIdUseCase(productRepo: catalogue),
          removeProductByIdUseCase:
              RemoveProductByIdUseCase(productRepo: catalogue),
        ));
  });

  tearDown(() async {
    await sl.reset();
  });

  /// Settles, but fails in seconds rather than hanging if something on
  /// screen never stops animating.
  Future<void> settle(WidgetTester tester) => tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 5));

  void useWideScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets('opening a Line\'s product from an Order reaches the edit form',
      timeout: const Timeout(Duration(seconds: 60)), (tester) async {
    useWideScreen(tester);
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: [CommonLocalizationsDelegate()],
      onGenerateRoute: RouterApp.generateRoute,
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => Navigator.pushNamed(context, productEditRoute,
                arguments: ProductArgument(_paracetamol())),
            child: const Text('open'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('open'));
    await settle(tester);

    expect(find.text('Page Not Found'), findsNothing,
        reason: 'the route was pushed but never handled');
    expect(find.byType(ProductEditPage), findsOneWidget);
  });

  testWidgets('deleting a Product leaves its edit form and its list row',
      timeout: const Timeout(Duration(seconds: 60)), (tester) async {
    useWideScreen(tester);
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: [CommonLocalizationsDelegate()],
      // In the app this panel sits inside HomePage's Scaffold.
      home: const Scaffold(body: ProductsPage()),
    ));
    await settle(tester);

    // list -> detail -> edit
    await tester.tap(find.text('Paracetamol').first);
    await settle(tester);
    await tester.tap(find.text('แก้ไข'));
    await settle(tester);
    expect(find.byType(ProductEditPage), findsOneWidget);

    // delete, and confirm — the button is at the foot of a long form
    await tester.ensureVisible(find.text('ลบสินค้า'));
    await settle(tester);
    await tester.tap(find.text('ลบสินค้า'));
    await settle(tester);
    await tester.tap(find
        .descendant(
            of: find.byType(AlertDialog), matching: find.byType(TextButton))
        .last);
    await settle(tester);

    expect(catalogue.products, isEmpty);
    expect(find.text('Product not found'), findsNothing,
        reason: 'removal used to reload the Product it had just removed');
    expect(find.byType(ProductEditPage), findsNothing,
        reason: 'and leave the cashier on its edit form');
    expect(find.text('Paracetamol'), findsNothing,
        reason: 'the list beside it stayed mounted and never reloaded');
  });
}
