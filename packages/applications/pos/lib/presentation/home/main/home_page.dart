// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:design_system/theme/color.dart';
import 'package:design_system/widgets/app_shell.dart';
import 'package:um/presentation/constants.dart';

// Project imports:
import 'package:pos/container.dart';
import 'package:pos/localizations/language/languages.dart';
import 'package:pos/presentation/customer/main/customer_page.dart';
import 'package:pos/presentation/home/main/cart_page.dart';
import 'package:pos/presentation/home/main/home_database_page.dart';
import 'package:pos/presentation/home/main/home_view_model.dart';
import 'package:pos/presentation/home/main/menu_event.dart';
import 'package:pos/presentation/order/main/order_page.dart';
import 'package:pos/presentation/product/main/product_page.dart';
import 'package:pos/presentation/receive/main/receive_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _viewNode = FocusNode();

  late HomeViewModel _viewModel;

  MenuEvent _menuEvent = MenuEvent.home;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<HomeViewModel>();
    _viewModel.state.addListener(_onStateChanged);
    _viewModel.prepareData();
  }

  void _onStateChanged() {
    final state = _viewModel.state.value;
    if (state.isAdmin != null) {
      final isAdmin = state.isAdmin!;
      _viewModel.consumeIsAdmin();
      setState(() => _isAdmin = isAdmin);
    }
    if (state.loggedOut) {
      _viewModel.consumeLoggedOut();
      if (mounted) Navigator.popAndPushNamed(context, routeLogin);
    }
  }

  @override
  void dispose() {
    _viewModel.state.removeListener(_onStateChanged);
    _viewModel.dispose();
    _viewNode.dispose();
    super.dispose();
  }

  /// Cashiers only sell and review sales; the rest is admin territory.
  List<AppShellItem> get _items {
    return [
      const AppShellItem(
          id: 'home', label: 'ขายสินค้า', icon: Icons.shopping_cart),
      const AppShellItem(id: 'order', label: 'รายการขาย', icon: Icons.receipt),
      if (_isAdmin) ...[
        const AppShellItem(
            id: 'product', label: 'สินค้า', icon: Icons.medical_information),
        const AppShellItem(
            id: 'database', label: 'จัดการ', icon: Icons.storage),
      ],
    ];
  }

  /// Customer and receive live under the "จัดการ" landing page, so they keep
  /// that entry highlighted rather than clearing the selection.
  String get _selectedId {
    if (isDatabaseMenu(_menuEvent)) return 'database';
    return _menuEvent.name;
  }

  void _onSelect(String id) {
    setState(() {
      _menuEvent = switch (id) {
        'order' => MenuEvent.order,
        'product' => MenuEvent.product,
        'database' => MenuEvent.database,
        _ => MenuEvent.home,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(_viewNode),
      child: AppShell(
        brand: 'Devper POS',
        title: '',
        // Each section draws its own header already.
        showTopBar: false,
        // Start as a rail. The selling screen lays out as
        // [ProductSearch (flexible)] | [cart 340-400] | [items 50], so the
        // product picker is the only column that gives, and it absorbs the
        // whole sidebar. On a 1024 shop tablet that is ~560px of search area
        // as a rail against ~372px expanded — a third of it, spent on four
        // labels a cashier already knows by icon. It still opens on demand.
        initiallyExpanded: false,
        items: _items,
        selectedId: _selectedId,
        onSelect: _onSelect,
        sidebarFooter: _buildFooter,
        child: _buildPage(),
      ),
    );
  }

  Widget _buildFooter(bool collapsed) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _footerAction(
          collapsed: collapsed,
          icon: Icons.account_box,
          label: Languages.of(context).userInfoTitle,
          onTap: () => Navigator.pushNamed(context, routeUserInfo),
        ),
        _footerAction(
          collapsed: collapsed,
          icon: Icons.logout,
          label: 'ออกจากระบบ',
          color: CustomColor.error,
          onTap: _viewModel.logout,
        ),
      ],
    );
  }

  Widget _footerAction({
    required bool collapsed,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return AppSidebarAction(
      label: label,
      icon: icon,
      collapsed: collapsed,
      onTap: onTap,
    );
  }

  Widget _buildPage() {
    switch (_menuEvent) {
      case MenuEvent.home:
        return const CartPage();
      case MenuEvent.order:
        return const OrderPage();
      case MenuEvent.product:
        return const ProductsPage();
      case MenuEvent.receive:
        return const ReceivePage();
      case MenuEvent.database:
        return HomeDatabasePage(
          onMenuTap: (event) => setState(() => _menuEvent = event),
        );
      case MenuEvent.customer:
        return CustomerPage(
            onBack: () => setState(() => _menuEvent = MenuEvent.database));
      case MenuEvent.setting:
        return Container();
    }
  }
}
