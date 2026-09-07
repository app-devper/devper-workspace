// Flutter imports:
import 'package:common/core/ext/date_ext.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:design_system/widgets/responsive.dart';

// Project imports:
import 'package:pos/container.dart';
import 'package:pos/domain/model/receive/receive.dart';
import 'package:pos/presentation/receive/main/receive_state.dart';
import 'package:pos/presentation/receive/main/receives_view_model.dart';
import 'package:design_system/theme/color.dart';

class ReceivesWidget extends StatefulWidget {
  final Function(Receive) onSelected;
  final Function() onMenu;

  const ReceivesWidget({
    super.key,
    required this.onSelected,
    required this.onMenu,
  });

  @override
  State<StatefulWidget> createState() => _ReceivesWidgetState();
}

class _ReceivesWidgetState extends State<ReceivesWidget> {
  final _searchEditingController = TextEditingController();
  final _searchNode = FocusNode();
  final _viewNode = FocusNode();

  late ReceivesViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<ReceivesViewModel>();
    _viewModel.searchReceive('');
  }

  @override
  void dispose() {
    _searchEditingController.dispose();
    _searchNode.dispose();
    _viewNode.dispose();

    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  _buildBody() {
    final isMobile = Responsive.isMobile(context);
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  focusNode: _searchNode,
                  controller: _searchEditingController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(0),
                    hintText: 'ค้นหาเลขที่ใบรับสินค้า...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    fillColor: Colors.grey[200],
                    filled: true,
                    suffixIcon: IconButton(
                      splashRadius: 20,
                      onPressed: () {
                        FocusScope.of(context).requestFocus(_viewNode);
                        _searchEditingController.text = "";
                        _viewModel.searchReceive("");
                      },
                      icon: const Icon(Icons.clear),
                    ),
                  ),
                  onChanged: (value) {
                    _viewModel.searchReceive(value);
                  },
                  onSubmitted: (value) {},
                ),
              ),
            ),
            if (isMobile) ...[
              IconButton(
                splashRadius: 20,
                onPressed: () {
                  widget.onMenu();
                },
                icon: const Icon(Icons.menu),
                color: CustomColor.primary,
              ),
              const SizedBox(width: 8),
            ]
          ],
        ),
        const Divider(height: 1),
        _buildProductList(),
      ],
    );
  }

  _buildProductList() {
    return ValueListenableBuilder<ReceivesState>(
      valueListenable: _viewModel.state,
      builder: (BuildContext context, ReceivesState state, _) {
        if (state.loading && state.items.isEmpty) {
          return const Expanded(
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 6,
                color: CustomColor.primary,
                strokeCap: StrokeCap.round,
              ),
            ),
          );
        }
        if (state.error != null) {
          return Expanded(
              child: Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(state.error!),
            TextButton(
                onPressed: _viewModel.getReceives,
                child: const Text('ลองอีกครั้ง')),
          ])));
        }
        return _buildReceives(state.items);
      },
    );
  }

  _buildReceives(List<Receive> item) {
    return Expanded(
      child: ListView.builder(
        itemCount: item.length,
        itemBuilder: (context, index) {
          final content = item[index];
          return Column(children: [
            ListTile(
              title: Text(content.code),
              subtitle: Text(
                "มูลค่า: ฿${content.totalCost.toStringAsFixed(2)}, วันที่: ${content.createdDate.formatDate()}",
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
              onTap: () {
                widget.onSelected(content);
              },
            ),
            const Divider(height: 1),
          ]);
        },
      ),
    );
  }
}
