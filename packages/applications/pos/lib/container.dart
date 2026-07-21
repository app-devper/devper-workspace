// Package imports:
import 'package:common/injection.dart';

// Project imports:
import 'package:pos/data/datasource/network/pos_service.dart';
import 'package:pos/data/repositories/category_repository_impl.dart';
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
import 'package:pos/domain/usecase/category/create_category_use_case.dart';
import 'package:pos/domain/usecase/category/get_categories_use_case.dart';
import 'package:pos/domain/usecase/category/get_category_by_id_use_case.dart';
import 'package:pos/domain/usecase/category/remove_category_by_id_use_case.dart';
import 'package:pos/domain/usecase/category/update_category_by_id_use_case.dart';
import 'package:pos/domain/usecase/category/update_default_category_by_id_use_case.dart';
import 'package:pos/domain/usecase/customer/create_customer_use_case.dart';
import 'package:pos/domain/usecase/customer/get_customer_by_id_use_case.dart';
import 'package:pos/domain/usecase/customer/get_local_customers_use_case.dart';
import 'package:pos/domain/usecase/customer/remove_customer_by_id_use_case.dart';
import 'package:pos/domain/usecase/customer/update_customer_by_id_use_case.dart';
import 'package:pos/domain/usecase/product/get_local_product_by_id_use_case.dart';
import 'package:pos/domain/usecase/product_return/create_product_return_use_case.dart';
import 'package:pos/domain/usecase/product_return/get_product_returns_by_order_id_use_case.dart';
import 'package:pos/domain/usecase/receive/create_receive_use_case.dart';
import 'package:pos/domain/usecase/receive/get_receive_by_id_use_case.dart';
import 'package:pos/domain/usecase/receive/get_receive_items_by_id_use_case.dart';
import 'package:pos/domain/usecase/receive/get_receives_use_case.dart';
import 'package:pos/domain/usecase/receive/remove_receive_by_id_use_case.dart';
import 'package:pos/domain/usecase/receive/remove_receive_item_by_lot_id_use_case.dart';
import 'package:pos/domain/usecase/receive/update_receive_by_id_use_case.dart';
import 'package:pos/domain/usecase/stock_adjustment/create_stock_adjustment_use_case.dart';
import 'package:pos/domain/usecase/stock_adjustment/get_stock_adjustments_by_product_id_use_case.dart';
import 'package:pos/domain/usecase/stock_count/create_stock_count_use_case.dart';
import 'package:pos/domain/usecase/stock_count/get_stock_count_by_id_use_case.dart';
import 'package:pos/domain/usecase/stock_count/get_stock_counts_use_case.dart';
import 'package:pos/domain/usecase/supplier/create_supplier_use_case.dart';
import 'package:pos/domain/usecase/supplier/get_local_suppliers_use_case.dart';
import 'package:pos/domain/usecase/supplier/get_supplier_info_use_case.dart';
import 'package:pos/domain/usecase/supplier/get_suppliers_use_case.dart';
import 'package:pos/domain/usecase/supplier/remove_supplier_by_id_use_case.dart';
import 'package:pos/domain/usecase/supplier/update_supplier_by_id_use_case.dart';
import 'package:pos/domain/usecase/supplier/update_supplier_info_use_case.dart';
import 'package:pos/presentation/category/add/category_add_view_model.dart';
import 'package:pos/presentation/category/edit/category_edit_view_model.dart';
import 'package:pos/presentation/category/main/category_view_model.dart';
import 'package:pos/presentation/customer/add/customer_add_view_model.dart';
import 'package:pos/presentation/customer/edit/customer_edit_view_model.dart';
import 'package:pos/presentation/customer/main/customer_view_model.dart';
import 'package:pos/presentation/customer/main/customers_view_model.dart';
import 'package:pos/presentation/home/main/cart_store.dart';
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
      loginRepo: sl(),
    ),
  );

  sl.registerSingleton(CartStore());

  sl.registerFactory(
    () => CartViewModel(
      cartStore: sl(),
      orderRepo: sl(),
      productRepo: sl(),
      categoryRepo: sl(),
    ),
  );

  sl.registerFactory(
    () => CustomerSearchViewModel(
      customerRepo: sl(),
    ),
  );

  sl.registerFactory(
    () => CustomersViewModel(
      getLocalCustomersUseCase: sl(),
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
      productRepo: sl(),
      categoryRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => ProductEditViewModel(
      productRepo: sl(),
      categoryRepo: sl(),
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
      loginRepo: sl(),
      orderRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => OrderDetailViewModel(
      loginRepo: sl(),
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
      getCategoriesUseCase: sl(),
      updateDefaultCategoryByIdUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => CategoryAddViewModel(
      createCategoryUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => CategoryEditViewModel(
      getCategoryByIdUseCase: sl(),
      updateCategoryByIdUseCase: sl(),
      removeCategoryByIdUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => ScannerViewModel(
      productRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => CustomerViewModel(
      getCustomerByIdUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => CustomerAddViewModel(
      createCustomerUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => CustomerEditViewModel(
      updateCustomerByIdUseCase: sl(),
      removeCustomerByIdUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => SupplierInfoViewModel(
      getSupplierInfoUseCase: sl(),
      updateSupplierInfoUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => SupplierAddViewModel(
      createSupplierUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => SupplierEditViewModel(
      updateSupplierByIdUseCase: sl(),
      removeSupplierByIdUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => SuppliersViewModel(
      getSuppliersUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => ReceivesViewModel(
      getReceivesUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => ReceiveManageViewModel(
      getReceiveByIdUseCase: sl(),
      createReceiveUseCase: sl(),
      updateReceiveByIdUseCase: sl(),
      removeReceiveByIdUseCase: sl(),
      getReceiveItemsByIdUseCase: sl(),
      removeReceiveItemByLotIdUseCase: sl(),
      getLocalSuppliersUseCase: sl(),
      getSuppliersUseCase: sl(),
      getLocalProductByIdUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => StockAdjustmentViewModel(
      createStockAdjustmentUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => StockAdjustmentHistoryViewModel(
      getStockAdjustmentsByProductIdUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => StockCountsViewModel(
      getStockCountsUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => StockCountManageViewModel(
      createStockCountUseCase: sl(),
      getStockCountByIdUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => StockCountItemPickerViewModel(
      productRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => ProductReturnViewModel(
      createProductReturnUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => ProductReturnsHistoryViewModel(
      getProductReturnsByOrderIdUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => GetCategoriesUseCase(
      categoryRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => CreateCategoryUseCase(
      categoryRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => GetCategoryByIdUseCase(
      categoryRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => UpdateCategoryByIdUseCase(
      categoryRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => RemoveCategoryByIdUseCase(
      categoryRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => UpdateDefaultCategoryByIdUseCase(
      categoryRepo: sl(),
    ),
  );

  sl.registerFactory(
    () => GetSuppliersUseCase(
      supplierRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => CreateSupplierUseCase(
      supplierRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => GetSupplierInfoUseCase(
      supplierRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => UpdateSupplierInfoUseCase(
      supplierRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => UpdateSupplierByIdUseCase(
      supplierRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => RemoveSupplierByIdUseCase(
      supplierRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => GetLocalSuppliersUseCase(
      supplierRepo: sl(),
    ),
  );

  sl.registerFactory(
    () => GetReceivesUseCase(
      receiveRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => GetReceiveByIdUseCase(
      receiveRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => CreateReceiveUseCase(
      receiveRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => UpdateReceiveByIdUseCase(
      receiveRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => RemoveReceiveByIdUseCase(
      receiveRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => GetReceiveItemsByIdUseCase(
      receiveRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => RemoveReceiveItemByLotIdUseCase(
      receiveRepo: sl(),
    ),
  );

  sl.registerFactory(
    () => CreateStockAdjustmentUseCase(
      stockAdjustmentRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => GetStockAdjustmentsByProductIdUseCase(
      stockAdjustmentRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => CreateStockCountUseCase(
      stockCountRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => GetStockCountsUseCase(
      stockCountRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => GetStockCountByIdUseCase(
      stockCountRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => CreateProductReturnUseCase(
      productReturnRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => GetProductReturnsByOrderIdUseCase(
      productReturnRepo: sl(),
    ),
  );

  sl.registerFactory(
    () => GetLocalProductByIdUseCase(
      productRepo: sl(),
    ),
  );

  sl.registerFactory(
    () => CreateCustomerUseCase(
      customerRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => GetLocalCustomersUseCase(
      customerRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => GetCustomerByIdUseCase(
      customerRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => UpdateCustomerByIdUseCase(
      customerRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => RemoveCustomerByIdUseCase(
      customerRepo: sl(),
    ),
  );

  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      posService: sl(),
    ),
  );
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(
      posService: sl(),
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
    ),
  );
  sl.registerLazySingleton<StockAdjustmentRepository>(
    () => StockAdjustmentRepositoryImpl(
      posService: sl(),
    ),
  );
  sl.registerLazySingleton<StockCountRepository>(
    () => StockCountRepositoryImpl(
      posService: sl(),
    ),
  );
  sl.registerLazySingleton<ProductReturnRepository>(
    () => ProductReturnRepositoryImpl(
      posService: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => PosService(
      networkConfig: sl(),
      client: sl(),
    ),
  );
}
