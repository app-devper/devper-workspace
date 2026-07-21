// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:common/core/ext/widget_ext.dart';
import 'package:design_system/widgets/title_bar.dart';

// Project imports:
import 'package:pos/container.dart';
import 'package:pos/domain/model/core/core.dart';
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/presentation/core/core_widget.dart';
import 'product_add_view_model.dart';

class ProductAddPage extends StatefulWidget {
  final Function() onBack;
  final Function() onAdd;

  const ProductAddPage({
    super.key,
    required this.onBack,
    required this.onAdd,
  });

  @override
  State<StatefulWidget> createState() => _ProductAddPageState();
}

class _ProductAddPageState extends State<ProductAddPage> {
  final _formKey = GlobalKey<FormState>();

  final _serialNumberEditingController = TextEditingController();
  final _nameEditingController = TextEditingController();
  final _descriptionEditingController = TextEditingController();
  final _priceEditingController = TextEditingController();
  final _unitEditingController = TextEditingController();
  final _costPriceEditingController = TextEditingController();
  final _minStockEditingController = TextEditingController();

  final _viewNode = FocusNode();
  final _serialNumberNode = FocusNode();
  final _nameNode = FocusNode();
  final _descriptionNode = FocusNode();
  final _priceNode = FocusNode();
  final _unitNode = FocusNode();
  final _costPriceNode = FocusNode();

  late ProductAddViewModel _viewModel;

  ItemType? _category = categoryTypes.first;
  final List<ItemType> _categories = categoryTypes;

  ItemType? _status;
  final List<ItemType> _productStatus = productStatus;

  bool _loadingShown = false;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<ProductAddViewModel>();
    _viewModel.state.addListener(_onStateChanged);
    _viewModel.getCategories();
  }

  void _onStateChanged() {
    final state = _viewModel.state.value;
    if (state.saving && !_loadingShown) {
      _loadingShown = true;
      showLoadingDialog(context);
    } else if (!state.saving && _loadingShown) {
      _loadingShown = false;
      hideLoadingDialog(context);
    }
    if (state.error != null) {
      final message = state.error!;
      _viewModel.consumeError();
      showAlertDialog(context, message, () {});
    }
    if (state.created != null) {
      _viewModel.consumeCreated();
      widget.onAdd();
    }
    if (state.serialNumber != null) {
      final serialNumber = state.serialNumber!;
      _viewModel.consumeSerialNumber();
      _serialNumberEditingController.text = serialNumber;
      FocusScope.of(context).requestFocus(_serialNumberNode);
    }
  }

  @override
  void dispose() {
    _viewModel.state.removeListener(_onStateChanged);
    _viewNode.dispose();
    _serialNumberNode.dispose();
    _nameNode.dispose();
    _descriptionNode.dispose();
    _priceNode.dispose();
    _costPriceNode.dispose();
    _unitNode.dispose();

    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TitleBar(
          title: "เพิ่มสินค้า",
          onBack: () {
            widget.onBack();
          },
          action: "เพิ่มสินค้า",
          onAction: () {
            if (_formKey.currentState!.validate()) {
              _viewModel.addProduct(_getProductParam());
            }
          },
        ),
        const Divider(height: 1),
        Expanded(
          child: _buildBody(),
        )
      ],
    );
  }

  _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Form(
        key: _formKey,
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
            const SizedBox(height: 16),
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
                      'ข้อมูลหน่วยนับ และการจำหน่าย',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildFormUnit(),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
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

  _buildFormUnit() {
    return Column(
      children: <Widget>[
        TextFormField(
          inputFormatters: [
            LengthLimitingTextInputFormatter(10),
          ],
          focusNode: _unitNode,
          controller: _unitEditingController,
          keyboardType: TextInputType.text,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: buildInputDecoration(
            labelText: 'ชื่อหน่วยนับ',
            hintText: 'โปรดระบุชื่อหน่วยนับ',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'โปรดระบุชื่อหน่วยนับ';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 1,
              child: TextFormField(
                inputFormatters: [
                  LengthLimitingTextInputFormatter(10),
                ],
                focusNode: _priceNode,
                controller: _priceEditingController,
                keyboardType: TextInputType.number,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: buildInputDecoration(
                  labelText: 'ราคาขายต่อหน่วย (ค่าเริ่มต้น)',
                  hintText: '',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'โปรดระบุราคาขายต่อหน่วย';
                  }
                  if (double.tryParse(value) == null) {
                    return 'ราคาขายต่อหน่วยต้องเป็นตัวเลขเท่านั้น';
                  } else if (double.tryParse(value)! < 0) {
                    return 'ราคาขายต่อหน่วยต้องมากกว่า 0';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Flexible(
              flex: 1,
              child: TextFormField(
                inputFormatters: [
                  LengthLimitingTextInputFormatter(10),
                ],
                focusNode: _costPriceNode,
                controller: _costPriceEditingController,
                keyboardType: TextInputType.number,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: buildInputDecoration(
                  labelText: 'ราคาทุนต่อหน่วย (ค่าเริ่มต้น)',
                  hintText: '',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'โปรดระบุราคาทุนต่อหน่วย';
                  }
                  if (double.tryParse(value) == null) {
                    return 'ราคาทุนต่อหน่วยต้องเป็นตัวเลขเท่านั้น';
                  } else if (double.tryParse(value)! < 0) {
                    return 'ราคาทุนต่อหน่วยต้องมากกว่า 0';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
                child: TextFormField(
              inputFormatters: [
                LengthLimitingTextInputFormatter(20),
              ],
              focusNode: _serialNumberNode,
              controller: _serialNumberEditingController,
              keyboardType: TextInputType.text,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: buildInputDecoration(
                labelText: 'บาร์โค้ด',
                hintText: 'โปรดระบุบาร์โค้ด',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'โปรดระบุบาร์โค้ด';
                }
                return null;
              },
            )),
            const SizedBox(width: 16),
            Flexible(
              child: TextFormField(
                inputFormatters: [
                  LengthLimitingTextInputFormatter(10),
                ],
                controller: _minStockEditingController,
                keyboardType: TextInputType.number,
                decoration: buildInputDecoration(
                  labelText: 'สต็อกขั้นต่ำ',
                  hintText: '0',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  _getProductParam() {
    var price = 0.0;
    if (_priceEditingController.text.trim().isNotEmpty) {
      price = double.parse(_priceEditingController.text);
    }
    var costPrice = 0.0;
    if (_costPriceEditingController.text.trim().isNotEmpty) {
      costPrice = double.parse(_costPriceEditingController.text);
    }
    final minStock = int.tryParse(_minStockEditingController.text) ?? 0;
    return CreateProductParam(
      name: _nameEditingController.text,
      nameEn: null,
      description: _descriptionEditingController.text,
      price: price,
      costPrice: costPrice,
      unit: _unitEditingController.text,
      serialNumber: _serialNumberEditingController.text,
      category: _category?.type ?? "",
      status: _status?.type ?? "",
      minStock: minStock,
    );
  }
}
