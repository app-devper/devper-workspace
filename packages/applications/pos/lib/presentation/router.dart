// Flutter imports:
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
        case HOME_ROUTE:
          return MaterialPageRoute(builder: (_) => const HomePage());
        case PRODUCTS_ROUTE:
          final args = settings.arguments as ProductsArgument?;
          return MaterialPageRoute(
              builder: (_) => ProductsPage(mode: args?.mode));
        case PRODUCT_EXPIRED_ROUTE:
          return MaterialPageRoute(builder: (_) => const ProductsExpiredPage());
        case PRODUCT_LOT_EDIT_ROUTE:
          final args = settings.arguments as ProductLotArgument;
          return MaterialPageRoute(
              builder: (_) => ProductLotEditPage(productLot: args.productLot));
        case ORDERS_ROUTE:
          return MaterialPageRoute(builder: (_) => const OrderPage());
        case ORDER_DETAIL_ROUTE:
          final args = settings.arguments as OrderArgument;
          return MaterialPageRoute(
              builder: (_) => OrderDetailPage(orderId: args.orderId));
        case ORDER_HISTORY_ROUTE:
          final args = settings.arguments as OrderHistoryArgument;
          return MaterialPageRoute(
              builder: (_) => OrderHistoryPage(product: args.product));
        case CATEGORIES_ROUTE:
          return MaterialPageRoute(builder: (_) => const CategoryPage());
        case CATEGORY_ADD_ROUTE:
          return MaterialPageRoute(builder: (_) => const CategoryAddPage());
        case CATEGORY_EDIT_ROUTE:
          final args = settings.arguments as CategoryArgument;
          return MaterialPageRoute(
              builder: (_) => CategoryEditPage(category: args.category));
        case SUPPLIER_ROUTE:
          return MaterialPageRoute(builder: (_) => const SupplierInfoPage());
        case SUPPLIERS_ROUTE:
          return MaterialPageRoute(builder: (_) => const SuppliersPage());
        case SUPPLIER_ADD_ROUTE:
          return MaterialPageRoute(builder: (_) => const SupplierAddPage());
        case SUPPLIER_EDIT_ROUTE:
          final args = settings.arguments as SupplierArgument;
          return MaterialPageRoute(
              builder: (_) => SupplierEditPage(supplier: args.supplier));
        case RECEIVES_ROUTE:
          return MaterialPageRoute(builder: (_) => const ReceivePage());
        case RECEIVE_MANAGE_ROUTE:
          final args = settings.arguments as ReceiveManageArgument?;
          return MaterialPageRoute(
              builder: (_) => ReceiveManagePage(receiveId: args?.receiveId));
        case STOCK_COUNTS_ROUTE:
          return MaterialPageRoute(builder: (_) => const StockCountsPage());
        case STOCK_COUNT_MANAGE_ROUTE:
          final args = settings.arguments as StockCountManageArgument?;
          return MaterialPageRoute(
              builder: (_) => StockCountManagePage(stockCountId: args?.stockCountId));
        case SCAN_ROUTE:
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
        case ROOT_ROUTE:
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
