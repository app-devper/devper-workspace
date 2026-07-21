// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:um/presentation/constants.dart';

// Project imports:
import 'package:pos/container.dart';
import 'package:pos/localizations/language/languages.dart';
import 'package:pos/presentation/home/main/home_view_model.dart';
import 'package:pos/presentation/home/main/home_widget.dart';
import 'package:pos/presentation/home/main/menu_event.dart';
import 'package:design_system/theme/color.dart';

class HomeMenu extends StatefulWidget {
  final MenuEvent menuEvent;
  final Function(MenuEvent) onMenuTap;

  const HomeMenu({
    super.key,
    required this.onMenuTap,
    required this.menuEvent,
  });

  @override
  State<StatefulWidget> createState() {
    return _HomeMenuState();
  }
}

class _HomeMenuState extends State<HomeMenu> {
  late HomeViewModel _viewModel;

  bool _isAdmin = false;

  @override
  void initState() {
    _viewModel = sl<HomeViewModel>();
    _viewModel.state.addListener(_onStateChanged);
    _viewModel.prepareData();
    super.initState();
  }

  void _onStateChanged() {
    final state = _viewModel.state.value;
    if (state.isAdmin != null) {
      final isAdmin = state.isAdmin!;
      _viewModel.consumeIsAdmin();
      setState(() {
        _isAdmin = isAdmin;
      });
    }
    if (state.loggedOut) {
      _viewModel.consumeLoggedOut();
      Navigator.popAndPushNamed(context, routeLogin);
    }
  }

  @override
  void dispose() {
    _viewModel.state.removeListener(_onStateChanged);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _buildHome(),
    );
  }

  _buildHome() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              MenuItem(
                active: false,
                onTap: () {
                  _showProfileMenu();
                },
                icon: Icons.account_box,
                defaultColor: CustomColor.primary,
              ),
              const Divider(height: 1),
              if (_isAdmin) ...[
                MenuItem(
                  active: widget.menuEvent == MenuEvent.home,
                  onTap: () {
                    widget.onMenuTap(MenuEvent.home);
                  },
                  icon: Icons.shopping_cart,
                ),
                MenuItem(
                  active: widget.menuEvent == MenuEvent.order,
                  onTap: () {
                    widget.onMenuTap(MenuEvent.order);
                  },
                  icon: Icons.receipt,
                ),
                MenuItem(
                  active: widget.menuEvent == MenuEvent.product,
                  onTap: () {
                    widget.onMenuTap(MenuEvent.product);
                  },
                  icon: Icons.medical_information,
                ),
                MenuItem(
                  active: isDatabaseMenu(widget.menuEvent),
                  onTap: () {
                    widget.onMenuTap(MenuEvent.database);
                  },
                  icon: Icons.storage,
                ),
              ] else ...[
                MenuItem(
                  active: widget.menuEvent == MenuEvent.home,
                  onTap: () {
                    widget.onMenuTap(MenuEvent.home);
                  },
                  icon: Icons.shopping_cart,
                ),
                MenuItem(
                  active: widget.menuEvent == MenuEvent.order,
                  onTap: () {
                    widget.onMenuTap(MenuEvent.order);
                  },
                  icon: Icons.receipt,
                ),
              ],
            ],
          ),
        ),
        const Divider(height: 1),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MenuItem(
              height: 80,
              defaultColor: Colors.red,
              active: false,
              onTap: () {
                _viewModel.logout();
              },
              icon: Icons.logout,
            ),
          ],
        ),
      ],
    );
  }

  _showProfileMenu() async {
    final item = await showMenu(context: context, position: const RelativeRect.fromLTRB(0, 50, 0, 0), items: [
      PopupMenuItem<int>(value: 0, child: Text(Languages.of(context).userInfoTitle)),
      PopupMenuItem<int>(value: 1, child: Text(Languages.of(context).changePasswordTitle)),
    ]);
    _handleClick(item);
  }

  void _handleClick(int? item) {
    switch (item) {
      case 0:
        Navigator.pushNamed(context, routeUserInfo);
        break;
      case 1:
        Navigator.pushNamed(context, routeChangePassword);
        break;
    }
  }
}
