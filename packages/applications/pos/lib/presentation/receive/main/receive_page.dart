// Flutter imports:
import 'package:common/core/widgets/responsive.dart';
import 'package:common/core/widgets/title_bar.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:common/core/widgets/appbar_widget.dart';
import 'package:common/core/widgets/custom_snack_bar.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:pos/container.dart';
import 'package:pos/domain/model/receive/receive.dart';
import 'package:pos/localizations/language/languages.dart';
import 'package:pos/presentation/constants.dart';
import 'package:pos/presentation/core/dialog_widget.dart';
import 'package:pos/presentation/receive/add/receive_add_page.dart';
import 'package:pos/presentation/receive/argument.dart';
import 'package:pos/presentation/receive/main/receive_menu_widget.dart';
import 'package:pos/presentation/receive/main/receive_state.dart';
import 'package:pos/presentation/receive/main/receives_view_model.dart';
import 'package:pos/presentation/receive/main/receives_widget.dart';
import 'package:pos/presentation/theme.dart';

class ReceivePage extends StatefulWidget {
  const ReceivePage({super.key});

  @override
  State<StatefulWidget> createState() => _ReceivePageState();
}

class _ReceivePageState extends State<ReceivePage> {
  PageState _pageState = MainPage();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Responsive(
      mobile: _buildMobile(),
      desktop: _buildDesktop(),
    );
  }

  _buildDesktop() {
    return Row(
      children: [
        SizedBox(
          width: 320,
          child: ReceivesWidget(
            onMenu: () {
              _showProductMenuDialog();
            },
            onSelected: (value) {
              //_viewModel.getProduct(value.id);
            },
          ),
        ),
        Container(width: 1, color: Colors.grey[200]),
        Expanded(
          child: _buildPage(),
        ),
      ],
    );
  }

  _buildMobile() {
    return Row(
      children: [
        Expanded(
          child: _buildPage(),
        ),
      ],
    );
  }

  _buildPage() {
    if (_pageState is MainPage) {
      final isMobile = Responsive.isMobile(context);
      if (isMobile) {
        return ReceivesWidget(
          onMenu: () {
            _showProductMenuDialog();
          },
          onSelected: (value) {
            //_viewModel.getProduct(value.id);
          },
        );
      } else {
        return ReceiveMenuWidget(
          onAdd: () {
            setState(() {
              _pageState = AddPage();
            });
          },
        );
      }
    } else if (_pageState is InfoPage) {
      return Container();
    } else if (_pageState is EditPage) {
      final data = (_pageState as EditPage).data;
      return Container();
    } else if (_pageState is AddPage) {
      return ReceiveAddPage(
        onBack: () {
          setState(() {
            _pageState = MainPage();
          });
        },
        onAdd: () {
          setState(() {
            _pageState = MainPage();
          });
        },
      );
    }
  }

  _showProductMenuDialog() {
    showRightDialog(
      context,
      builder: (context) => Column(
        children: [
          TitleBar(
            title: "เมนู",
            onBack: () {
              Navigator.pop(context);
            },
          ),
          const Divider(height: 1),
          Expanded(
            child: ReceiveMenuWidget(
              onAdd: () {
                Navigator.pop(context);
                setState(() {
                  _pageState = AddPage();
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

abstract class PageState {}

class MainPage extends PageState {}

class AddPage extends PageState {}

class InfoPage extends PageState {
  final Receive data;

  InfoPage({
    required this.data,
  });
}

class EditPage extends PageState {
  final Receive data;

  EditPage({
    required this.data,
  });
}
