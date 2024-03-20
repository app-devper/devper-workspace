// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:pos/presentation/home/main/cart_page.dart';
import 'package:pos/presentation/home/main/home_menu.dart';
import 'package:pos/presentation/home/main/menu_event.dart';
import 'package:pos/presentation/order/main/order_page.dart';
import 'package:pos/presentation/product/main/products_page.dart';
import 'package:pos/presentation/receive/main/receives_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _viewNode = FocusNode();

  MenuEvent _menuEvent = MenuEvent.home;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _viewNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(_viewNode),
      child: Scaffold(
        body: Row(
          children: [
            SizedBox(
              width: 60,
              child: HomeMenu(
                onMenuTap: (event) {
                  setState(() {
                    _menuEvent = event;
                  });
                },
                menuEvent: _menuEvent,
              ),
            ),
            Container(width: 1, color: Colors.grey[200]),
            Expanded(child: _buildPage())
          ],
        ),
      ),
    );
  }

  _buildPage() {
    switch (_menuEvent) {
      case MenuEvent.home:
        return const CartPage();
      case MenuEvent.order:
        return const OrderPage();
      case MenuEvent.product:
        return const ProductsPage();
      case MenuEvent.receive:
        return const ReceivesPage();
      case MenuEvent.setting:
        return Container();
      default:
        return Container();
    }
  }
}
