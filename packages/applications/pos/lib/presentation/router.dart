// Flutter imports:
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

// Package imports:
import 'package:um/presentation/constants.dart';
import 'package:um/presentation/router.dart';

// Project imports:
import 'package:pos/presentation/category/add/category_add_page.dart';
import 'package:pos/presentation/category/argument.dart';
import 'package:pos/presentation/category/edit/category_edit_page.dart';
import 'package:pos/presentation/category/main/category_page.dart';
import 'package:pos/presentation/constants.dart';
import 'package:pos/presentation/home/main/home_page.dart';
import 'package:pos/presentation/home/scanner/scanner_page.dart';
import 'package:pos/presentation/order/argument.dart';
import 'package:pos/presentation/order/detail/order_detail_page.dart';
import 'package:pos/presentation/order/history/order_history_page.dart';
import 'package:pos/presentation/order/main/order_page.dart';
import 'package:pos/presentation/product/argument.dart';
import 'package:pos/presentation/product/expired/products_expired_page.dart';
import 'package:pos/presentation/product/lot_edit/product_lot_edit_page.dart';
import 'package:pos/presentation/product/main/product_page.dart';
import 'package:pos/presentation/receive/argument.dart';
import 'package:pos/presentation/receive/main/receive_page.dart';
import 'package:pos/presentation/receive/manage/receive_manage_page.dart';
import 'package:pos/presentation/stock_count/argument.dart';
import 'package:pos/presentation/stock_count/main/stock_counts_page.dart';
import 'package:pos/presentation/stock_count/manage/stock_count_manage_page.dart';
import 'package:pos/presentation/supplier/add/supplier_add_page.dart';
import 'package:pos/presentation/supplier/argument.dart';
import 'package:pos/presentation/supplier/edit/supplier_edit_page.dart';
import 'package:pos/presentation/supplier/info/supplier_info_page.dart';
import 'package:pos/presentation/supplier/main/suppliers_page.dart';

class RouterApp {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    if (settings.name?.startsWith('/um') ?? false) {
      return RouterUm.generateRoute(settings);
    } else {
      switch (settings.name) {
        case homeRoute:
          return MaterialPageRoute(builder: (_) => const HomePage());
        case productsRoute:
          final args = settings.arguments as ProductsArgument?;
          return MaterialPageRoute(
              builder: (_) => ProductsPage(mode: args?.mode));
        case productExpiredRoute:
          return MaterialPageRoute(builder: (_) => const ProductsExpiredPage());
        case productLotEditRoute:
          final args = settings.arguments as ProductLotArgument;
          return MaterialPageRoute(
              builder: (_) => ProductLotEditPage(productLot: args.productLot));
        case ordersRoute:
          return MaterialPageRoute(builder: (_) => const OrderPage());
        case orderDetailRoute:
          final args = settings.arguments as OrderArgument;
          return MaterialPageRoute(
              builder: (_) => OrderDetailPage(orderId: args.orderId));
        case orderHistoryRoute:
          final args = settings.arguments as OrderHistoryArgument;
          return MaterialPageRoute(
              builder: (_) => OrderHistoryPage(product: args.product));
        case categoriesRoute:
          return MaterialPageRoute(builder: (_) => const CategoryPage());
        case categoryAddRoute:
          return MaterialPageRoute(builder: (_) => const CategoryAddPage());
        case categoryEditRoute:
          final args = settings.arguments as CategoryArgument;
          return MaterialPageRoute(
              builder: (_) => CategoryEditPage(category: args.category));
        case supplierRoute:
          return MaterialPageRoute(builder: (_) => const SupplierInfoPage());
        case suppliersRoute:
          return MaterialPageRoute(builder: (_) => const SuppliersPage());
        case supplierAddRoute:
          return MaterialPageRoute(builder: (_) => const SupplierAddPage());
        case supplierEditRoute:
          final args = settings.arguments as SupplierArgument;
          return MaterialPageRoute(
              builder: (_) => SupplierEditPage(supplier: args.supplier));
        case receivesRoute:
          return MaterialPageRoute(builder: (_) => const ReceivePage());
        case receiveManageRoute:
          final args = settings.arguments as ReceiveManageArgument?;
          return MaterialPageRoute(
              builder: (_) => ReceiveManagePage(receiveId: args?.receiveId));
        case stockCountsRoute:
          return MaterialPageRoute(builder: (_) => const StockCountsPage());
        case stockCountManageRoute:
          final args = settings.arguments as StockCountManageArgument?;
          return MaterialPageRoute(
              builder: (_) =>
                  StockCountManagePage(stockCountId: args?.stockCountId));
        case scanRoute:
          if (kIsWeb) {
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                appBar: AppBar(
                  title: const Text('Scanner'),
                ),
                body: const Center(
                  child: Text('Scanner is not available on web'),
                ),
              ),
            );
          }
          return MaterialPageRoute(
              builder: (_) => const ScannerPage(mode: "SCAN"));
        case rootRoute:
          return RouterUm.generateRoute(
              RouteSettings(name: routeSplash, arguments: settings.arguments));
        default:
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(
                title: const Text('Error'),
              ),
              body: const Center(
                child: Text('Page Not Found'),
              ),
            ),
          );
      }
    }
  }
}
