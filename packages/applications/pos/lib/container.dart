// Package imports:
import 'package:common/injection.dart';

// Project imports:
import 'package:pos/data/datasource/network/pos_service.dart';
import 'package:pos/data/repositories/category_repository_impl.dart';
import 'package:pos/data/repositories/cached_list.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/data/repositories/customer_repository_impl.dart';
import 'package:pos/data/repositories/order_repository_impl.dart';
import 'package:pos/data/repositories/product_repository_impl.dart';
import 'package:pos/data/repositories/product_return_repository_impl.dart';
import 'package:pos/data/repositories/receive_repository_impl.dart';
import 'package:pos/data/repositories/stock_adjustment_repository_impl.dart';
import 'package:pos/data/repositories/stock_count_repository_impl.dart';
import 'package:pos/data/repositories/supplier_repository_impl.dart';
import 'package:pos/domain/repositories/category_repository.dart';
import 'package:pos/domain/repositories/customer_repository.dart';
import 'package:pos/domain/repositories/order_repository.dart';
import 'package:pos/domain/repositories/product_repository.dart';
import 'package:pos/domain/repositories/product_return_repository.dart';
import 'package:pos/domain/repositories/receive_repository.dart';
import 'package:pos/domain/repositories/stock_adjustment_repository.dart';
import 'package:pos/domain/repositories/stock_count_repository.dart';
import 'package:pos/domain/repositories/supplier_repository.dart';
import 'package:pos/domain/usecase/order/checkout_sale_use_case.dart';
import 'package:pos/presentation/category/add/category_add_view_model.dart';
import 'package:pos/presentation/category/edit/category_edit_view_model.dart';
import 'package:pos/presentation/category/main/category_view_model.dart';
import 'package:pos/presentation/customer/add/customer_add_view_model.dart';
import 'package:pos/presentation/customer/edit/customer_edit_view_model.dart';
import 'package:pos/presentation/customer/main/customer_view_model.dart';
import 'package:pos/presentation/customer/main/customers_view_model.dart';
import 'package:pos/domain/model/sale/till.dart';
import 'package:pos/presentation/home/main/cart_view_model.dart';
import 'package:pos/presentation/home/main/customer_search_view_model.dart';
import 'package:pos/presentation/home/main/home_view_model.dart';
import 'package:pos/presentation/home/main/product_search_view_model.dart';
import 'package:pos/presentation/home/scanner/scanner_view_model.dart';
import 'package:pos/presentation/order/detail/order_detail_view_model.dart';
import 'package:pos/presentation/order/history/order_history_view_model.dart';
import 'package:pos/presentation/order/main/order_view_model.dart';
import 'package:pos/presentation/order/return/product_return_view_model.dart';
import 'package:pos/presentation/order/return/product_returns_history_view_model.dart';
import 'package:pos/presentation/product/add/product_add_view_model.dart';
import 'package:pos/presentation/product/edit/product_edit_view_model.dart';
import 'package:pos/presentation/product/expired/products_expired_view_model.dart';
import 'package:pos/presentation/product/history/product_history_view_model.dart';
import 'package:pos/presentation/product/lot_edit/product_lot_edit_view_model.dart';
import 'package:pos/presentation/product/main/product_view_model.dart';
import 'package:pos/presentation/product/main/products_view_model.dart';
import 'package:pos/presentation/product/price/product_price_view_model.dart';
import 'package:pos/presentation/product/stock/product_stock_quantity_view_model.dart';
import 'package:pos/presentation/product/stock/product_stock_sequence_view_model.dart';
import 'package:pos/presentation/product/stock/product_stock_view_model.dart';
import 'package:pos/presentation/product/stock/stock_adjustment_history_view_model.dart';
import 'package:pos/presentation/product/stock/stock_adjustment_view_model.dart';
import 'package:pos/presentation/product/unit/product_unit_view_model.dart';
import 'package:pos/presentation/receive/main/receives_view_model.dart';
import 'package:pos/presentation/receive/manage/receive_manage_view_model.dart';
import 'package:pos/presentation/stock_count/main/stock_counts_view_model.dart';
import 'package:pos/presentation/stock_count/manage/stock_count_item_picker_view_model.dart';
import 'package:pos/presentation/stock_count/manage/stock_count_manage_view_model.dart';
import 'package:pos/presentation/supplier/add/supplier_add_view_model.dart';
import 'package:pos/presentation/supplier/edit/supplier_edit_view_model.dart';
import 'package:pos/presentation/supplier/info/supplier_info_view_model.dart';
import 'package:pos/presentation/supplier/main/suppliers_view_model.dart';

final sl = getIt();

// Dependency injection
Future<void> initPos() async {
  // ViewModel

  sl.registerFactory(
    () => HomeViewModel(
      logoutUseCase: sl(),
      getRoleUseCase: sl(),
    ),
  );

  sl.registerSingleton(Till());

  sl.registerFactory(
    () => CartViewModel(
      till: sl(),
      checkoutSaleUseCase: sl(),
      productRepo: sl(),
    ),
  );

  sl.registerFactory(
    () => CustomerSearchViewModel(
      customerRepo: sl(),
    ),
  );

  sl.registerFactory(
    () => CustomersViewModel(
      customerRepo: sl(),
    ),
  );

  sl.registerFactory(
    () => ProductSearchViewModel(
      productRepo: sl(),
    ),
  );

  sl.registerFactory(
    () => ProductViewModel(
      productRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => ProductsViewModel(
      productRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => ProductUnitViewModel(
      productRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => ProductPriceViewModel(
      productRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => ProductStockViewModel(
      productRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => ProductStockQuantityViewModel(
      productRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => ProductStockSequenceViewModel(
      productRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => ProductAddViewModel(
      categoryRepo: sl(),
      productRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => ProductEditViewModel(
      productRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => ProductsExpiredViewModel(
      productRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => ProductLotEditViewModel(
      productRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => ProductHistoryViewModel(
      productRepo: sl(),
    ),
  );

  sl.registerFactory(
    () => OrderViewModel(
      getRoleUseCase: sl(),
      orderRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => OrderDetailViewModel(
      getRoleUseCase: sl(),
      orderRepo: sl(),
      supplierRepo: sl(),
      customerRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => OrderHistoryViewModel(
      orderRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => CategoryViewModel(
      categoryRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => CategoryAddViewModel(
      categoryRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => CategoryEditViewModel(
      categoryRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => ScannerViewModel(
      productRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => CustomerViewModel(
      customerRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => CustomerAddViewModel(
      customerRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => CustomerEditViewModel(
      customerRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => SupplierInfoViewModel(
      supplierRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => SupplierAddViewModel(
      supplierRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => SupplierEditViewModel(
      supplierRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => SuppliersViewModel(
      supplierRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => ReceivesViewModel(
      receiveRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => ReceiveManageViewModel(
      receiveRepo: sl(),
      supplierRepo: sl(),
      productRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => StockAdjustmentViewModel(
      stockAdjustmentRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => StockAdjustmentHistoryViewModel(
      stockAdjustmentRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => StockCountsViewModel(
      stockCountRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => StockCountManageViewModel(
      stockCountRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => StockCountItemPickerViewModel(
      productRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => ProductReturnViewModel(
      productReturnRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => ProductReturnsHistoryViewModel(
      productReturnRepo: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => CheckoutSaleUseCase(
      orderRepo: sl(),
    ),
  );

  // One catalogue cache, shared by the repositories whose writes can change it.
  sl.registerLazySingleton<CachedList<Product>>(() => CachedList<Product>());

  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      posService: sl(),
      cache: sl(),
    ),
  );
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(
      posService: sl(),
      productCache: sl(),
    ),
  );
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(
      posService: sl(),
    ),
  );
  sl.registerLazySingleton<CustomerRepository>(
    () => CustomerRepositoryImpl(
      posService: sl(),
    ),
  );
  sl.registerLazySingleton<SupplierRepository>(
    () => SupplierRepositoryImpl(
      posService: sl(),
    ),
  );
  sl.registerLazySingleton<ReceiveRepository>(
    () => ReceiveRepositoryImpl(
      posService: sl(),
      productCache: sl(),
    ),
  );
  sl.registerLazySingleton<StockAdjustmentRepository>(
    () => StockAdjustmentRepositoryImpl(
      posService: sl(),
      productCache: sl(),
    ),
  );
  sl.registerLazySingleton<StockCountRepository>(
    () => StockCountRepositoryImpl(
      posService: sl(),
      productCache: sl(),
    ),
  );
  sl.registerLazySingleton<ProductReturnRepository>(
    () => ProductReturnRepositoryImpl(
      posService: sl(),
      productCache: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => PosService(
      networkConfig: sl(),
      client: sl(),
    ),
  );
}
