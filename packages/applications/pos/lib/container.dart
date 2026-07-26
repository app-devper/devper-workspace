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
import 'package:pos/domain/usecase/category/get_local_categories_use_case.dart';
import 'package:pos/domain/usecase/category/get_category_by_id_use_case.dart';
import 'package:pos/domain/usecase/category/remove_category_by_id_use_case.dart';
import 'package:pos/domain/usecase/category/update_category_by_id_use_case.dart';
import 'package:pos/domain/usecase/category/update_default_category_by_id_use_case.dart';
import 'package:pos/domain/usecase/customer/create_customer_use_case.dart';
import 'package:pos/domain/usecase/customer/get_customer_by_id_use_case.dart';
import 'package:pos/domain/usecase/customer/get_local_customers_use_case.dart';
import 'package:pos/domain/usecase/customer/remove_customer_by_id_use_case.dart';
import 'package:pos/domain/usecase/customer/update_customer_by_id_use_case.dart';
import 'package:pos/domain/usecase/order/create_order_use_case.dart';
import 'package:pos/domain/usecase/order/get_order_by_id_use_case.dart';
import 'package:pos/domain/usecase/order/get_order_item_by_product_id_use_case.dart';
import 'package:pos/domain/usecase/order/get_order_range_use_case.dart';
import 'package:pos/domain/usecase/order/remove_order_by_id_use_case.dart';
import 'package:pos/domain/usecase/order/remove_order_item_by_id_use_case.dart';
import 'package:pos/domain/usecase/product/add_product_price_use_case.dart';
import 'package:pos/domain/usecase/product/add_product_stock_use_case.dart';
import 'package:pos/domain/usecase/product/add_product_unit_use_case.dart';
import 'package:pos/domain/usecase/product/add_product_use_case.dart';
import 'package:pos/domain/usecase/product/clear_quantity_sold_first_by_id_use_case.dart';
import 'package:pos/domain/usecase/product/generate_serial_number_use_case.dart';
import 'package:pos/domain/usecase/product/get_local_product_by_id_use_case.dart';
import 'package:pos/domain/usecase/product/get_local_products_use_case.dart';
import 'package:pos/domain/usecase/product/get_product_by_barcode_use_case.dart';
import 'package:pos/domain/usecase/product/get_product_histories_by_product_id_use_case.dart';
import 'package:pos/domain/usecase/product/get_product_lots_use_case.dart';
import 'package:pos/domain/usecase/product/get_product_prices_by_product_id_use_case.dart';
import 'package:pos/domain/usecase/product/get_product_stocks_by_product_id_use_case.dart';
import 'package:pos/domain/usecase/product/get_product_units_by_product_id_use_case.dart';
import 'package:pos/domain/usecase/product/import_product_csv_use_case.dart';
import 'package:pos/domain/usecase/product/remove_product_by_id_use_case.dart';
import 'package:pos/domain/usecase/product/remove_product_price_by_id_use_case.dart';
import 'package:pos/domain/usecase/product/remove_product_stock_by_id_use_case.dart';
import 'package:pos/domain/usecase/product/remove_product_unit_by_id_use_case.dart';
import 'package:pos/domain/usecase/product/update_product_by_id_use_case.dart';
import 'package:pos/domain/usecase/product/update_product_lot_quantity_by_lot_id_use_case.dart';
import 'package:pos/domain/usecase/product/update_product_price_by_id_use_case.dart';
import 'package:pos/domain/usecase/product/update_product_stock_by_id_use_case.dart';
import 'package:pos/domain/usecase/product/update_product_stock_quantity_by_id_use_case.dart';
import 'package:pos/domain/usecase/product/update_product_stock_sequence_use_case.dart';
import 'package:pos/domain/usecase/product/update_product_stock_use_case.dart';
import 'package:pos/domain/usecase/product/update_product_unit_by_id_use_case.dart';
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
      getRoleUseCase: sl(),
      logoutUseCase: sl(),
    ),
  );

  sl.registerSingleton(CartStore());

  sl.registerFactory(
    () => CartViewModel(
      cartStore: sl(),
      createOrderUseCase: sl(),
      getProductByBarcodeUseCase: sl(),
      updateProductStockUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => CustomerSearchViewModel(
      getLocalCustomersUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => CustomersViewModel(
      getLocalCustomersUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => ProductSearchViewModel(
      getLocalProductsUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => ProductViewModel(
      getLocalProductByIdUseCase: sl(),
      getLocalProductsUseCase: sl(),
      importProductCSVUseCase: sl(),
      clearQuantitySoldFirstByIdUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => ProductsViewModel(
      getLocalProductsUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => ProductUnitViewModel(
      addProductUnitUseCase: sl(),
      updateProductUnitByIdUseCase: sl(),
      removeProductUnitByIdUseCase: sl(),
      getProductUnitsByProductIdUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => ProductPriceViewModel(
      addProductPriceUseCase: sl(),
      updateProductPriceByIdUseCase: sl(),
      removeProductPriceByIdUseCase: sl(),
      getProductPricesByProductIdUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => ProductStockViewModel(
      addProductStockUseCase: sl(),
      updateProductStockByIdUseCase: sl(),
      removeProductStockByIdUseCase: sl(),
      getProductStocksByProductIdUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => ProductStockQuantityViewModel(
      updateProductStockQuantityByIdUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => ProductStockSequenceViewModel(
      updateProductStockSequenceUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => ProductAddViewModel(
      getLocalCategoriesUseCase: sl(),
      generateSerialNumberUseCase: sl(),
      addProductUseCase: sl(),
      getProductUnitsByProductIdUseCase: sl(),
      getProductPricesByProductIdUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => ProductEditViewModel(
      getLocalProductByIdUseCase: sl(),
      getLocalCategoriesUseCase: sl(),
      updateProductByIdUseCase: sl(),
      removeProductByIdUseCase: sl(),
      generateSerialNumberUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => ProductsExpiredViewModel(
      getProductLotsUseCase: sl(),
      getLocalProductByIdUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => ProductLotEditViewModel(
      updateProductLotQuantityByLotIdUseCase: sl(),
      getLocalProductByIdUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => ProductHistoryViewModel(
      getProductHistoriesByProductIdUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => OrderViewModel(
      getRoleUseCase: sl(),
      getOrderRangeUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => OrderDetailViewModel(
      getRoleUseCase: sl(),
      getOrderByIdUseCase: sl(),
      removeOrderByIdUseCase: sl(),
      removeOrderItemByIdUseCase: sl(),
      getSupplierInfoUseCase: sl(),
      getLocalCustomersUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => OrderHistoryViewModel(
      getOrderItemByProductIdUseCase: sl(),
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
      getProductByBarcodeUseCase: sl(),
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
      getLocalProductsUseCase: sl(),
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
    () => CreateOrderUseCase(
      orderRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => GetOrderRangeUseCase(
      orderRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => GetOrderByIdUseCase(
      orderRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => GetOrderItemByProductIdUseCase(
      orderRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => RemoveOrderByIdUseCase(
      orderRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => RemoveOrderItemByIdUseCase(
      orderRepo: sl(),
    ),
  );

  sl.registerFactory(
    () => GetLocalProductByIdUseCase(
      productRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => GetLocalProductsUseCase(
      productRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => GetProductByBarcodeUseCase(
      productRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => UpdateProductStockUseCase(
      productRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => ImportProductCSVUseCase(
      productRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => ClearQuantitySoldFirstByIdUseCase(
      productRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => GenerateSerialNumberUseCase(
      productRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => AddProductUseCase(
      productRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => UpdateProductByIdUseCase(
      productRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => RemoveProductByIdUseCase(
      productRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => AddProductUnitUseCase(
      productRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => UpdateProductUnitByIdUseCase(
      productRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => RemoveProductUnitByIdUseCase(
      productRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => GetProductUnitsByProductIdUseCase(
      productRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => AddProductPriceUseCase(
      productRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => UpdateProductPriceByIdUseCase(
      productRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => RemoveProductPriceByIdUseCase(
      productRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => GetProductPricesByProductIdUseCase(
      productRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => AddProductStockUseCase(
      productRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => UpdateProductStockByIdUseCase(
      productRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => RemoveProductStockByIdUseCase(
      productRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => GetProductStocksByProductIdUseCase(
      productRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => UpdateProductStockQuantityByIdUseCase(
      productRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => UpdateProductStockSequenceUseCase(
      productRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => UpdateProductLotQuantityByLotIdUseCase(
      productRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => GetProductLotsUseCase(
      productRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => GetProductHistoriesByProductIdUseCase(
      productRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => GetLocalCategoriesUseCase(
      categoryRepo: sl(),
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
