// Package imports:
import 'package:common/injection.dart';

// Project imports:
import 'package:pos/data/datasource/network/pos_service.dart';
import 'package:pos/data/repositories/category_repository_impl.dart';
import 'package:pos/data/repositories/customer_repository_impl.dart';
import 'package:pos/data/repositories/order_repository_impl.dart';
import 'package:pos/data/repositories/product_repository_impl.dart';
import 'package:pos/data/repositories/receive_repository_impl.dart';
import 'package:pos/data/repositories/supplier_repository_impl.dart';
import 'package:pos/domain/repositories/category_repository.dart';
import 'package:pos/domain/repositories/customer_repository.dart';
import 'package:pos/domain/repositories/order_repository.dart';
import 'package:pos/domain/repositories/product_repository.dart';
import 'package:pos/domain/repositories/receive_repository.dart';
import 'package:pos/domain/repositories/supplier_repository.dart';
import 'package:pos/presentation/category/add/category_add_view_model.dart';
import 'package:pos/presentation/category/edit/category_edit_view_model.dart';
import 'package:pos/presentation/category/main/category_view_model.dart';
import 'package:pos/presentation/customer/add/customer_add_view_model.dart';
import 'package:pos/presentation/customer/edit/customer_edit_view_model.dart';
import 'package:pos/presentation/customer/main/customer_view_model.dart';
import 'package:pos/presentation/home/main/home_view_model.dart';
import 'package:pos/presentation/home/scanner/scanner_view_model.dart';
import 'package:pos/presentation/order/detail/order_detail_view_model.dart';
import 'package:pos/presentation/order/history/order_history_view_model.dart';
import 'package:pos/presentation/order/main/order_view_model.dart';
import 'package:pos/presentation/product/add/product_add_view_model.dart';
import 'package:pos/presentation/product/edit/product_edit_view_model.dart';
import 'package:pos/presentation/product/expired/products_expired_view_model.dart';
import 'package:pos/presentation/product/lot_edit/product_lot_edit_view_model.dart';
import 'package:pos/presentation/product/main/products_view_model.dart';
import 'package:pos/presentation/receive/main/receives_view_model.dart';
import 'package:pos/presentation/receive/manage/receive_manage_view_model.dart';
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
      orderRepo: sl(),
      productRepo: sl(),
      categoryRepo: sl(),
      customerRepo: sl(),
    ),
  );

  sl.registerFactory(
    () => ProductsViewModel(
      productRepo: sl(),
      categoryRepo: sl(),
      loginRepo: sl(),
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
      supplierRepo: sl(),
    ),
  );
  sl.registerFactory(
    () => ReceiveManageViewModel(
      receiveRepo: sl(),
      supplierRepo: sl(),
      productRepo: sl(),
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

  sl.registerLazySingleton(
    () => PosService(
      networkConfig: sl(),
      client: sl(),
    ),
  );
}
