// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:common/core/ext/widget_ext.dart';
import 'package:common/core/widgets/title_bar.dart';

// Project imports:
import 'package:pos/container.dart';
import 'package:pos/domain/model/core/core.dart';
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/presentation/core/core_widget.dart';
import 'product_edit_state.dart';
import 'product_edit_view_model.dart';

class ProductEditPage extends StatefulWidget {
  final Product product;
  final Function() onBack;
  final Function() onEdit;
  final Function() onRemove;

  const ProductEditPage({
    super.key,
    required this.product,
    required this.onBack,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  State<StatefulWidget> createState() => _ProductEditPageState();
}

class _ProductEditPageState extends State<ProductEditPage> {
  final _nameEditingController = TextEditingController();
  final _descriptionEditingController = TextEditingController();

  final _nameNode = FocusNode();
  final _descriptionNode = FocusNode();

  late ProductEditViewModel _viewModel;

  ItemType? _category;
  final List<ItemType> _categories = categoryTypes;

  ItemType? _status;
  final List<ItemType> _productStatus = productStatus;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<ProductEditViewModel>();
    _viewModel.states.listen((state) {
      if (state is ErrorState) {
        hideLoadingDialog(context);
      } else if (state is LoadingState) {
        showLoadingDialog(context);
      } else if (state is GetProductState) {
        setState(() {
          _category = findCategoryType(state.data.category);
          _status = findProductStatus(state.data.status);
        });
        _setupProduct(state.data);
      } else if (state is UpdateProductState) {
        hideLoadingDialog(context);
        widget.onEdit();
      } else if (state is RemoveProductState) {
        hideLoadingDialog(context);
        widget.onRemove();
      } else if (state is GetSerialNumberState) {
        hideLoadingDialog(context);
      }
    });

    _viewModel.getProductById(widget.product.id);
    _setupProduct(widget.product);
  }

  @override
  void dispose() {
    _nameNode.dispose();
    _descriptionNode.dispose();

    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TitleBar(
          title: widget.product.name,
          onBack: () {
            widget.onBack();
          },
          action: "ยืนยัน",
          onAction: () {
            _viewModel.updateProductById(widget.product.id, _getProductParam());
          },
        ),
        const Divider(height: 1),
        Expanded(
          child: _buildBody(),
        )
      ],
    );
  }

  void _setupProduct(Product product) {
    _nameEditingController.text = product.name;
    _descriptionEditingController.text = product.description ?? "";
  }

  _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'ข้อมูลทั่วไป',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'โปรดระบุข้อมูลสินค้า',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildFormInfo(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          const SizedBox(height: 60),
          TextButton(
            onPressed: () => _showConfirmDialog(context),
            child: const Text(
              "ลบสินค้า",
              style: TextStyle(
                color: Colors.red,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }

  _buildFormInfo() {
    return Column(
      children: <Widget>[
        DropdownButtonFormField<ItemType>(
          validator: (value) {
            return null;
          },
          decoration: buildInputDecoration(
            labelText: 'ประเภทสินค้า',
            hintText: 'โปรดเลือกประเภทสินค้า',
          ),
          value: _category,
          onChanged: (value) {
            setState(() {
              _category = value;
            });
          },
          items: _categories.map((ItemType value) {
            return DropdownMenuItem<ItemType>(
              value: value,
              child: Text(value.name),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        TextFormField(
          inputFormatters: [
            LengthLimitingTextInputFormatter(50),
          ],
          focusNode: _nameNode,
          controller: _nameEditingController,
          keyboardType: TextInputType.text,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: buildInputDecoration(
            labelText: 'ชื่อสินค้า',
            hintText: 'โปรดระบุชื่อสินค้า',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'โปรดระบุชื่อสินค้า';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          inputFormatters: [
            LengthLimitingTextInputFormatter(100),
          ],
          focusNode: _descriptionNode,
          controller: _descriptionEditingController,
          keyboardType: TextInputType.text,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: buildInputDecoration(
            labelText: 'คำอธิบายสินค้า',
            hintText: 'โปรดระบุคำอธิบายสินค้า',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return null;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<ItemType>(
          validator: (value) {
            return null;
          },
          decoration: buildInputDecoration(
            labelText: 'การแสดงข้อมูลสินค้า',
            hintText: 'โปรดเลือกการแสดงข้อมูลสินค้า',
          ),
          value: _status,
          onChanged: (value) {
            setState(() {
              _status = value;
            });
          },
          items: _productStatus.map((ItemType value) {
            return DropdownMenuItem<ItemType>(
              value: value,
              child: Text(value.name),
            );
          }).toList(),
        ),
      ],
    );
  }

  _getProductParam() {
    return ProductParam(
      name: _nameEditingController.text,
      nameEn: null,
      description: _descriptionEditingController.text,
      price: 0,
      costPrice: 0,
      quantity: 0,
      unit: "",
      serialNumber: "",
      lotNumber: null,
      category: _category?.type ?? "",
      expireDate: null,
      receiveId: null,
      status: _status?.type ?? "",
    );
  }

  _showConfirmDialog(BuildContext context) {
    showConfirmDialog(context, "ต้องการลบสินค้าใช่หรือไม่", () {
      _viewModel.removeProductById(widget.product.id);
    });
  }
}
