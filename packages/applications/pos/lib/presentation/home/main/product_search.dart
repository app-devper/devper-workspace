import 'package:common/core/theme/theme.dart';
import 'package:common/core/widgets/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:pos/container.dart';
import 'package:pos/domain/model/product/product.dart';
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
  final widthCard = 200;
  final _serialNumberEditingController = TextEditingController();
  final _serialNumberNode = FocusNode();
  late CustomSnackBar _snackBar;

  late ProductSearchViewModel _viewModel;

  @override
  void initState() {
    _viewModel = sl<ProductSearchViewModel>();
    _viewModel.prepareData();
    super.initState();
  }

  @override
  void dispose() {
    _serialNumberNode.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _snackBar = CustomSnackBar(key: const Key("snackbar"), context: context);
    _serialNumberNode.requestFocus();
    return _buildProducts();
  }

  _buildProducts() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        int countRow = constraints.maxWidth ~/ widthCard;
        if (countRow == 0) countRow = 1;
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              child: TextField(
                focusNode: _serialNumberNode,
                controller: _serialNumberEditingController,
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
              child: StreamBuilder<List<Product>>(
                stream: _viewModel.productItems,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 6,
                        color: CustomColor.primary,
                        strokeCap: StrokeCap.round,
                      ),
                    );
                  }
                  final items = snapshot.data!;
                  return GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: countRow,
                      childAspectRatio: 2,
                      mainAxisExtent: 100,
                      mainAxisSpacing: 2,
                      crossAxisSpacing: 2,
                    ),
                    shrinkWrap: true,
                    itemBuilder: (context, i) => ProductItem(
                      name: items[i].name,
                      price: items[i].price,
                      unit: items[i].unit,
                      barcode: items[i].serialNumber,
                      onTap: () {
                        widget.onSelected(items[i].serialNumber);
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
}
