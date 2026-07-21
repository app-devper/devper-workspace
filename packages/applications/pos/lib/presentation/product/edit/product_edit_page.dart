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
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/model/product/request_drug_info.dart';
import 'package:pos/presentation/core/core_widget.dart';
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
  final _minStockEditingController = TextEditingController();
  final _genericNameController = TextEditingController();
  final _drugTypeController = TextEditingController();
  final _dosageFormController = TextEditingController();
  final _strengthController = TextEditingController();
  final _indicationController = TextEditingController();
  final _dosageController = TextEditingController();
  final _sideEffectsController = TextEditingController();
  final _contraindicationsController = TextEditingController();
  final _storageConditionController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _registrationNoController = TextEditingController();
  final _drugRegistrationsController = TextEditingController();

  final _nameNode = FocusNode();
  final _descriptionNode = FocusNode();
  bool _isControlled = false;

  late ProductEditViewModel _viewModel;

  ItemType? _category;
  final List<ItemType> _categories = categoryTypes;

  ItemType? _status;
  final List<ItemType> _productStatus = productStatus;

  bool _loadingShown = false;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<ProductEditViewModel>();
    _viewModel.state.addListener(_onStateChanged);
    _viewModel.getProductById(widget.product.id);
    _setupProduct(widget.product);
  }

  void _onStateChanged() {
    final state = _viewModel.state.value;
    if (state.loading && !_loadingShown) {
      _loadingShown = true;
      showLoadingDialog(context);
    } else if (!state.loading && _loadingShown) {
      _loadingShown = false;
      hideLoadingDialog(context);
    }
    if (state.error != null) {
      _viewModel.consumeError();
    }
    if (state.loaded != null) {
      final data = state.loaded!;
      _viewModel.consumeLoaded();
      setState(() {
        _category = findCategoryType(data.category);
        _status = findProductStatus(data.status);
      });
      _setupProduct(data);
    }
    if (state.updated != null) {
      _viewModel.consumeUpdated();
      widget.onEdit();
    }
    if (state.removed != null) {
      _viewModel.consumeRemoved();
      widget.onRemove();
    }
    if (state.serialNumber != null) {
      _viewModel.consumeSerialNumber();
    }
  }

  @override
  void dispose() {
    _viewModel.state.removeListener(_onStateChanged);
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
    _minStockEditingController.text = product.minStock.toString();
    _drugRegistrationsController.text = product.drugRegistrations.join(', ');
    final drugInfo = product.drugInfo;
    if (drugInfo != null) {
      _genericNameController.text = drugInfo.genericName ?? '';
      _drugTypeController.text = drugInfo.drugType ?? '';
      _dosageFormController.text = drugInfo.dosageForm ?? '';
      _strengthController.text = drugInfo.strength ?? '';
      _indicationController.text = drugInfo.indication ?? '';
      _dosageController.text = drugInfo.dosage ?? '';
      _sideEffectsController.text = drugInfo.sideEffects ?? '';
      _contraindicationsController.text = drugInfo.contraindications ?? '';
      _storageConditionController.text = drugInfo.storageCondition ?? '';
      _manufacturerController.text = drugInfo.manufacturer ?? '';
      _registrationNoController.text = drugInfo.registrationNo ?? '';
      _isControlled = drugInfo.isControlled ?? false;
    }
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
                    'ข้อมูลสต็อกขั้นต่ำ',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
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
                    'ข้อมูลยา',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDrugInfoForm(),
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
                    'ทะเบียนยา',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _drugRegistrationsController,
                    keyboardType: TextInputType.text,
                    decoration: buildInputDecoration(
                      labelText: 'ทะเบียนยา (คั่นด้วยเครื่องหมาย ,)',
                      hintText: 'เช่น KHY9, KHY10',
                    ),
                  ),
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

  _buildDrugInfoForm() {
    return Column(
      children: <Widget>[
        TextFormField(
          controller: _genericNameController,
          keyboardType: TextInputType.text,
          decoration: buildInputDecoration(
            labelText: 'ชื่อสามัญ (Generic Name)',
            hintText: '',
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _drugTypeController,
          keyboardType: TextInputType.text,
          decoration: buildInputDecoration(
            labelText: 'ประเภทยา (Drug Type)',
            hintText: '',
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _dosageFormController,
          keyboardType: TextInputType.text,
          decoration: buildInputDecoration(
            labelText: 'รูปแบบยา (Dosage Form)',
            hintText: '',
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _strengthController,
          keyboardType: TextInputType.text,
          decoration: buildInputDecoration(
            labelText: 'ความแรง (Strength)',
            hintText: '',
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _indicationController,
          keyboardType: TextInputType.text,
          decoration: buildInputDecoration(
            labelText: 'ข้อบ่งใช้ (Indication)',
            hintText: '',
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _dosageController,
          keyboardType: TextInputType.text,
          decoration: buildInputDecoration(
            labelText: 'ขนาดยา (Dosage)',
            hintText: '',
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _sideEffectsController,
          keyboardType: TextInputType.text,
          decoration: buildInputDecoration(
            labelText: 'ผลข้างเคียง (Side Effects)',
            hintText: '',
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _contraindicationsController,
          keyboardType: TextInputType.text,
          decoration: buildInputDecoration(
            labelText: 'ข้อห้ามใช้ (Contraindications)',
            hintText: '',
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _storageConditionController,
          keyboardType: TextInputType.text,
          decoration: buildInputDecoration(
            labelText: 'เงื่อนไขการเก็บรักษา',
            hintText: '',
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _manufacturerController,
          keyboardType: TextInputType.text,
          decoration: buildInputDecoration(
            labelText: 'ผู้ผลิต (Manufacturer)',
            hintText: '',
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _registrationNoController,
          keyboardType: TextInputType.text,
          decoration: buildInputDecoration(
            labelText: 'เลขทะเบียน (Registration No)',
            hintText: '',
          ),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('ยาควบคุม (Controlled)'),
          value: _isControlled,
          onChanged: (value) {
            setState(() {
              _isControlled = value;
            });
          },
        ),
      ],
    );
  }

  RequestDrugInfo? _getDrugInfo() {
    final hasData = _genericNameController.text.isNotEmpty ||
        _drugTypeController.text.isNotEmpty ||
        _dosageFormController.text.isNotEmpty ||
        _strengthController.text.isNotEmpty ||
        _indicationController.text.isNotEmpty ||
        _dosageController.text.isNotEmpty ||
        _sideEffectsController.text.isNotEmpty ||
        _contraindicationsController.text.isNotEmpty ||
        _storageConditionController.text.isNotEmpty ||
        _manufacturerController.text.isNotEmpty ||
        _registrationNoController.text.isNotEmpty ||
        _isControlled;
    if (!hasData) return null;
    return RequestDrugInfo(
      genericName: _genericNameController.text,
      drugType: _drugTypeController.text,
      dosageForm: _dosageFormController.text,
      strength: _strengthController.text,
      indication: _indicationController.text,
      dosage: _dosageController.text,
      sideEffects: _sideEffectsController.text,
      contraindications: _contraindicationsController.text,
      storageCondition: _storageConditionController.text,
      manufacturer: _manufacturerController.text,
      registrationNo: _registrationNoController.text,
      isControlled: _isControlled,
    );
  }

  List<String> _getDrugRegistrations() {
    final text = _drugRegistrationsController.text.trim();
    if (text.isEmpty) return [];
    return text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  _getProductParam() {
    final minStock = int.tryParse(_minStockEditingController.text) ?? 0;
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
      minStock: minStock,
      drugInfo: _getDrugInfo(),
      drugRegistrations: _getDrugRegistrations(),
    );
  }

  _showConfirmDialog(BuildContext context) {
    showConfirmDialog(context, "ต้องการลบสินค้าใช่หรือไม่", () {
      _viewModel.removeProductById(widget.product.id);
    });
  }
}
