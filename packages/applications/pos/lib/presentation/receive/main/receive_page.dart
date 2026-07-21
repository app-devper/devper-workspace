// Flutter imports:
import 'package:design_system/widgets/responsive.dart';
import 'package:design_system/widgets/title_bar.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:pos/presentation/constants.dart';
import 'package:design_system/widgets/dialogs.dart';
import 'package:pos/presentation/receive/main/receive_menu_widget.dart';
import 'package:pos/presentation/receive/main/receives_widget.dart';

class ReceivePage extends StatefulWidget {
  const ReceivePage({super.key});

  @override
  State<StatefulWidget> createState() => _ReceivePageState();
}

class _ReceivePageState extends State<ReceivePage> {
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
            onSelected: (value) {},
          ),
        ),
        Container(width: 1, color: Colors.grey[200]),
        Expanded(
          child: ReceiveMenuWidget(
            onAdd: () {
              _nextToReceiveManage();
            },
          ),
        ),
      ],
    );
  }

  _buildMobile() {
    return Row(
      children: [
        Expanded(
          child: ReceivesWidget(
            onMenu: () {
              _showProductMenuDialog();
            },
            onSelected: (value) {},
          ),
        ),
      ],
    );
  }

  _nextToReceiveManage() {
    Navigator.pushNamed(context, RECEIVE_MANAGE_ROUTE);
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
                _nextToReceiveManage();
              },
            ),
          ),
        ],
      ),
    );
  }
}
