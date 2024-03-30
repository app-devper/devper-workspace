import 'package:flutter/material.dart';
import 'package:pos/container.dart';
import 'package:pos/localizations/language/languages.dart';
import 'package:pos/presentation/home/main/home_state.dart';
import 'package:pos/presentation/home/main/home_view_model.dart';
import 'package:pos/presentation/home/main/home_widget.dart';
import 'package:pos/presentation/home/main/menu_event.dart';
import 'package:pos/presentation/theme.dart';
import 'package:um/presentation/constants.dart';

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
    _viewModel.prepareData();
    _viewModel.states.listen((event) {
      if (event is CheckRoleState) {
        setState(() {
          _isAdmin = event.isAdmin;
        });
      } else if (event is LogoutState) {
        Navigator.popAndPushNamed(context, routeLogin);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
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
