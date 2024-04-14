// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:common/core/widgets/responsive.dart';

// Project imports:
import 'package:pos/container.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/presentation/theme.dart';
import 'products_view_model.dart';

class ProductsWidget extends StatefulWidget {
  final Function(Product) onSelected;
  final Function() onMenu;

  const ProductsWidget({
    super.key,
    required this.onSelected,
    required this.onMenu,
  });

  @override
  State<StatefulWidget> createState() => _ProductsWidgetState();
}

class _ProductsWidgetState extends State<ProductsWidget> {
  final _searchEditingController = TextEditingController();
  final _searchNumberNode = FocusNode();
  final _viewNode = FocusNode();

  bool _sortBalance = false;

  late ProductsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<ProductsViewModel>();
    _viewModel.searchProduct('', _sortBalance);
  }

  @override
  void dispose() {
    _searchNumberNode.dispose();
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
                  focusNode: _searchNumberNode,
                  controller: _searchEditingController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(0),
                    hintText: 'ค้นหาสิ่งที่คุณต้องการ...',
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
                        _viewModel.searchProduct("", _sortBalance);
                      },
                      icon: const Icon(Icons.clear),
                    ),
                  ),
                  onChanged: (value) {
                    _viewModel.searchProduct(value, _sortBalance);
                  },
                  onSubmitted: (value) {},
                ),
              ),
            ),
            IconButton(
              splashRadius: 20,
              onPressed: () {
                setState(() {
                  _sortBalance = !_sortBalance;
                  _viewModel.searchProduct(_searchEditingController.text, _sortBalance);
                });
              },
              icon: Icon(_sortBalance ? Icons.sort : Icons.balance),
              color: CustomColor.primary,
            ),
            const SizedBox(width: 8),
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
    return StreamBuilder(
      stream: _viewModel.products,
      builder: (BuildContext context, AsyncSnapshot<List<Product>> snapshot) {
        if (snapshot.hasData) {
          var data = snapshot.data;
          return _buildProducts(data ?? []);
        } else {
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
      },
    );
  }

  _buildProducts(List<Product> item) {
    getSubTitle(Product content) {
      if (_sortBalance) {
        return "คงเหลือ ${content.getQuantity()} ${content.units.isNotEmpty ? content.units.first.unit : ""}";
      } else {
        return content.units.isNotEmpty ? content.units.first.unit : "";
      }
    }

    return Expanded(
      child: ListView.builder(
        itemCount: item.length,
        itemBuilder: (context, index) {
          final content = item[index];
          return Column(children: [
            ListTile(
              title: Text(content.name),
              subtitle: Text(
                getSubTitle(content),
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
