// Flutter imports:
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

// Package imports:
import 'package:design_system/theme/color.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

// Project imports:
import 'package:pos/container.dart';
import 'package:pos/domain/model/core/core.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/presentation/constants.dart';
import 'package:pos/presentation/home/main/cart_widget.dart';
import 'package:pos/presentation/home/main/product_search_view_model.dart';

class ProductSearch extends StatefulWidget {
  final Function(String) onSelected;

  const ProductSearch({
    super.key,
    required this.onSelected,
  });

  @override
  State<StatefulWidget> createState() {
    return _ProductSearchState();
  }
}

class _ProductSearchState extends State<ProductSearch> {
  final _widthCard = 300;
  final _serialNumberEditingController = TextEditingController();
  final _serialNumberNode = FocusNode();

  late ProductSearchViewModel _viewModel;

  @override
  void initState() {
    _viewModel = sl<ProductSearchViewModel>();
    _viewModel.prepareData();
    super.initState();
  }

  @override
  void dispose() {
    _serialNumberEditingController.dispose();
    _serialNumberNode.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildProducts();
  }

  LayoutBuilder _buildProducts() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        int countRow = constraints.maxWidth ~/ _widthCard;
        if (countRow == 0) countRow = 1;
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              child: TextField(
                autofocus: true,
                focusNode: _serialNumberNode,
                controller: _serialNumberEditingController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(0),
                  hintText: 'ค้นหาชื่อสินค้า หรือสแกนบาร์โค้ด',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: kIsWeb
                      ? null
                      : IconButton(
                          tooltip: 'สแกนบาร์โค้ด',
                          icon: const Icon(Icons.qr_code_scanner),
                          onPressed: () => _scanBarcode(context),
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  fillColor: Colors.grey[200],
                  filled: true,
                ),
                onChanged: (value) {
                  _viewModel.searchProduct(value);
                },
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    widget.onSelected(value);
                    _serialNumberEditingController.text = "";
                    _serialNumberNode.requestFocus();
                    _viewModel.searchProduct("");
                  }
                },
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ValueListenableBuilder<List<ProductUnitItem>?>(
                valueListenable: _viewModel.items,
                builder: (context, items, _) {
                  if (items == null) {
                    return const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 6,
                        color: CustomColor.primary,
                        strokeCap: StrokeCap.round,
                      ),
                    );
                  }
                  if (items.isEmpty) {
                    return const Center(
                        child: Text(
                            "ไม่พบสินค้า\nลองค้นหาด้วยชื่อหรือบาร์โค้ดอื่น",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color(0xFF687588), height: 1.8)));
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: countRow,
                      childAspectRatio: 2,
                      mainAxisExtent: 158,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    shrinkWrap: true,
                    itemBuilder: (context, i) => ProductItem(
                      name: items[i].name,
                      price: items[i].getPrice(priceTypeStock).price,
                      quantity: items[i].getQuantity(),
                      unit: items[i].unit.unit,
                      barcode: items[i].unit.barcode,
                      onTap: () {
                        widget.onSelected(items[i].unit.barcode);
                      },
                    ),
                    itemCount: items.length,
                  );
                },
              ),
            )
          ],
        );
      },
    );
  }

  Future<void> _scanBarcode(BuildContext context) async {
    final result = await Navigator.pushNamed(context, scanRoute);
    if (result is Barcode) {
      final code = result.code;
      if (code != null && code.isNotEmpty) {
        widget.onSelected(code);
      }
    }
  }
}
