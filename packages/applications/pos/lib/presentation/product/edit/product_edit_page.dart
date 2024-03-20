// Flutter imports:
import 'package:common/core/widgets/appbar_widget.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:common/core/ext/widget_ext.dart';
import 'package:common/core/widgets/button_widget.dart';
import 'package:common/core/widgets/custom_snack_bar.dart';
import 'package:common/core/widgets/dropdown_widget.dart';

// Project imports:
import 'package:pos/container.dart';
import 'package:pos/domain/model/category/category.dart';
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/localizations/language/languages.dart';
import 'package:pos/presentation/constants.dart';
import 'package:pos/presentation/order/argument.dart';
import 'package:pos/presentation/theme.dart';
import 'product_edit_state.dart';
import 'product_edit_view_model.dart';

class ProductEditPage extends StatefulWidget {
  final Product product;

  const ProductEditPage({super.key, required this.product});

  @override
  State<StatefulWidget> createState() => _ProductEditPageState();
}

class _ProductEditPageState extends State<ProductEditPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _serialNumberEditingController = TextEditingController();
  final _nameEditingController = TextEditingController();
  final _descriptionEditingController = TextEditingController();
  final _priceEditingController = TextEditingController();
  final _unitEditingController = TextEditingController();
  final _quantityEditingController = TextEditingController();
  final _costPriceEditingController = TextEditingController();

  final _viewNode = FocusNode();
  final _serialNumberNode = FocusNode();
  final _nameNode = FocusNode();
  final _descriptionNode = FocusNode();
  final _priceNode = FocusNode();
  final _unitNode = FocusNode();
  final _quantityNode = FocusNode();
  final _costPriceNode = FocusNode();

  late CustomSnackBar _snackBar;
  late ProductEditViewModel _viewModel;

  Category? _category;
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _viewModel = sl<ProductEditViewModel>();
    _viewModel.states.stream.listen((state) {
      if (state is ErrorState) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _snackBar.hideAll();
          _snackBar.showErrorSnackBar(state.message);
        });
        hideLoadingDialog(context);
      } else if (state is LoadingState) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _snackBar.hideAll();
        });
        showLoadingDialog(context);
      } else if (state is GetProductState) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _snackBar.hideAll();
        });
        hideLoadingDialog(context);
        setState(() {
          _categories = state.categories;
          _category = _categories.where((element) => element.value == state.data.category).firstOrNull;
        });
        _setupProduct(state.data);
      } else if (state is UpdateProductState) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _snackBar.hideAll();
          _snackBar.showSnackBar(text: "Update ${state.data.name} success");
        });
        hideLoadingDialog(context);
        Navigator.pop(context, state.data);
      } else if (state is RemoveProductState) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _snackBar.hideAll();
        });
        hideLoadingDialog(context);
        Navigator.pop(context, state.data);
      } else if (state is GetSerialNumberState) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _snackBar.hideAll();
        });
        hideLoadingDialog(context);
        FocusScope.of(context).requestFocus(_serialNumberNode);
        _serialNumberEditingController.text = state.serialNumber;
        _serialNumberEditingController.selection = TextSelection.collapsed(offset: state.serialNumber.length);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.getProductById(widget.product.id);
    });
  }

  @override
  void dispose() {
    _serialNumberNode.dispose();
    _nameNode.dispose();
    _descriptionNode.dispose();
    _priceNode.dispose();
    _costPriceNode.dispose();
    _quantityNode.dispose();
    _unitNode.dispose();

    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _snackBar = CustomSnackBar(key: const Key("snackbar"), context: context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: buildAppBar(
          Languages.of(context).productEditTitle,
        actions: [
          IconButton(
            splashRadius: 20,
            onPressed: () {
              _nextToOrderHistory(context, widget.product);
            },
            icon: const Icon(Icons.history),
          ),
          IconButton(
            splashRadius: 20,
            onPressed: () {
              _showConfirmDialog(context);
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  void _setupProduct(Product product) {
    _serialNumberEditingController.text = product.serialNumber;
    _nameEditingController.text = product.name;
    _descriptionEditingController.text = product.description ?? "";
    _priceEditingController.text = product.price.toString();
    _costPriceEditingController.text = product.costPrice.toString();
    _quantityEditingController.text = product.quantity.toString();
    _unitEditingController.text = product.unit;
  }

  _buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(defaultPagePadding),
      child: Column(
        children: <Widget>[
          _buildSerialNumber(context),
          _buildForm(context),
          const Padding(
            padding: EdgeInsets.only(top: 20),
          ),
          _buildUpdateButton(),
        ],
      ),
    );
  }

  _buildSerialNumber(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width,
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Flexible(child: _buildSerialNumberField(context)),
          const SizedBox(width: 12),
          SizedBox(
            width: 60,
            height: 50,
            child: ButtonIconWidget(
              key: const Key("gen"),
              onClicked: () {
                _viewModel.generateSerialNumber();
              },
              icon: const Icon(Icons.abc),
            ),
          ),
        ],
      ),
    );
  }

  _buildForm(BuildContext context) {
    return Column(
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.only(top: 12),
        ),
        buildTextFormField(
          context,
          _nameNode,
          _nameEditingController,
          "Name*",
          TextInputType.text,
          _descriptionNode,
        ),
        const Padding(
          padding: EdgeInsets.only(top: 12),
        ),
        buildTextFormField(
          context,
          _descriptionNode,
          _descriptionEditingController,
          "Description",
          TextInputType.text,
          _priceNode,
        ),
        const Padding(
          padding: EdgeInsets.only(top: 12),
        ),
        buildTextFormField(
          context,
          _priceNode,
          _priceEditingController,
          "Price*",
          const TextInputType.numberWithOptions(decimal: true),
          _costPriceNode,
        ),
        const Padding(
          padding: EdgeInsets.only(top: 12),
        ),
        buildTextFormField(
          context,
          _costPriceNode,
          _costPriceEditingController,
          "Cost Price*",
          const TextInputType.numberWithOptions(decimal: true),
          _quantityNode,
        ),
        const Padding(
          padding: EdgeInsets.only(top: 12),
        ),
        buildTextFormField(
          context,
          _quantityNode,
          _quantityEditingController,
          "Quantity",
          const TextInputType.numberWithOptions(),
          _unitNode,
        ),
        const Padding(
          padding: EdgeInsets.only(top: 12),
        ),
        buildTextFormField(
          context,
          _unitNode,
          _unitEditingController,
          "Unit",
          TextInputType.text,
          _viewNode,
        ),
        const Padding(
          padding: EdgeInsets.only(top: 12),
        ),
        _buildCategory(),
      ],
    );
  }

  _buildSerialNumberField(BuildContext context) {
    return TextFormField(
      focusNode: _serialNumberNode,
      controller: _serialNumberEditingController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: const BorderSide(
            color: CustomColor.textFieldBackground,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: const BorderSide(
            color: CustomColor.textFieldBackground,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: const BorderSide(
            color: CustomColor.textFieldBackground,
          ),
        ),
        focusColor: CustomColor.hintColor,
        hoverColor: CustomColor.textFieldBackground,
        fillColor: CustomColor.textFieldBackground,
        filled: true,
        labelText: "SerialNumber*",
      ),
      cursorColor: CustomColor.hintColor,
    );
  }

  _buildCategory() {
    return SizedBox(
      height: 50,
      child: DropdownInput<Category>(
        hintText: "Category",
        options: _categories,
        value: _category,
        onChanged: (Category? value) {
          setState(() {
            _category = value;
          });
        },
        getLabel: (Category value) => value.name,
      ),
    );
  }

  _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ButtonWidget(
        key: const Key("update"),
        onClicked: () {
          _viewModel.updateProductById(widget.product.id, _getProductParam());
        },
        text: "Update",
      ),
    );
  }

  _getProductParam() {
    return ProductParam(
      name: _nameEditingController.text,
      nameEn: null,
      description: _descriptionEditingController.text,
      price: double.parse(_priceEditingController.text),
      costPrice: double.parse(_costPriceEditingController.text),
      quantity: int.parse(_quantityEditingController.text),
      unit: _unitEditingController.text,
      serialNumber: _serialNumberEditingController.text,
      lotNumber: null,
      category: _category?.value,
      expireDate: null,
      receiveId: null,
    );
  }

  _showConfirmDialog(BuildContext context) {
    showConfirmDialog(context, "ต้องการลบสินค้าใช่หรือไม่", () {
      _viewModel.removeProductById(widget.product.id);
    });
  }

  _nextToOrderHistory(BuildContext context, Product? product) async {
    if (product != null) {
      var _ = await Navigator.pushNamed(context, ORDER_HISTORY_ROUTE, arguments: OrderHistoryArgument(product));
    }
  }
}
