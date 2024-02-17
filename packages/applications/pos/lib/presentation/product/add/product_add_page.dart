// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:common/core/ext/widget_ext.dart';
import 'package:common/core/utils/device.dart';
import 'package:common/core/widgets/button_widget.dart';
import 'package:common/core/widgets/custom_snack_bar.dart';
import 'package:common/core/widgets/dropdown_widget.dart';
import 'package:intl/intl.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

// Project imports:
import 'package:pos/container.dart';
import 'package:pos/domain/model/category/category.dart';
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/localizations/language/languages.dart';
import 'package:pos/presentation/constants.dart';
import 'package:pos/presentation/home/argument.dart';
import 'package:pos/presentation/product/argument.dart';
import 'package:pos/presentation/theme.dart';
import 'product_add_state.dart';
import 'product_add_view_model.dart';

class ProductAddPage extends StatefulWidget {
  final String? receiveId;

  const ProductAddPage({super.key, required this.receiveId});

  @override
  State<StatefulWidget> createState() => _ProductAddPageState();
}

class _ProductAddPageState extends State<ProductAddPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _serialNumberEditingController = TextEditingController();
  final _nameEditingController = TextEditingController();
  final _descriptionEditingController = TextEditingController();
  final _priceEditingController = TextEditingController();
  final _unitEditingController = TextEditingController();
  final _quantityEditingController = TextEditingController();
  final _lotNumberEditingController = TextEditingController();
  final _expireDateEditingController = TextEditingController();
  final _costPriceEditingController = TextEditingController();

  final _viewNode = FocusNode();
  final _serialNumberNode = FocusNode();
  final _nameNode = FocusNode();
  final _descriptionNode = FocusNode();
  final _priceNode = FocusNode();
  final _unitNode = FocusNode();
  final _quantityNode = FocusNode();
  final _lotNumberNode = FocusNode();
  final _costPriceNode = FocusNode();

  late DateTime? _expireDate;
  late CustomSnackBar _snackBar;
  late ProductAddViewModel _viewModel;

  Category? _category;
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _viewModel = sl<ProductAddViewModel>();
    _viewModel.states.stream.listen((state) {
      if (state is ErrorState) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _snackBar.hideAll();
          _snackBar.showErrorSnackBar(state.message);
        });
      } else if (state is LoadingState) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _snackBar.hideAll();
          _snackBar.showLoadingSnackBar();
        });
      } else if (state is GetProductState) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _snackBar.hideAll();
        });
        var data = state.data;
        if (data != null) {
          _nameEditingController.text = data.name;
          _descriptionEditingController.text = data.description ?? "";
          _priceEditingController.text = data.price.toString();
          _costPriceEditingController.text = data.costPrice.toString();
          _quantityEditingController.text = "";
          _unitEditingController.text = data.unit;
          _lotNumberEditingController.text = "";
          _expireDateEditingController.text = "";
          _expireDate = null;
          setState(() {
            _category = _categories.where((element) => element.value == data.category).firstOrNull;
          });
          FocusScope.of(context).requestFocus(_quantityNode);
        } else {
          _nameEditingController.text = "";
          _descriptionEditingController.text = "";
          _priceEditingController.text = "";
          _costPriceEditingController.text = "";
          _quantityEditingController.text = "";
          _unitEditingController.text = "";
          _lotNumberEditingController.text = "";
          _expireDateEditingController.text = "";
          _expireDate = null;
          FocusScope.of(context).requestFocus(_nameNode);
        }
      } else if (state is CreateProductState) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _snackBar.hideAll();
          _snackBar.showSnackBar(text: "Add ${state.data.name} success");
        });
        _serialNumberEditingController.text = "";
        _nameEditingController.text = "";
        _descriptionEditingController.text = "";
        _priceEditingController.text = "";
        _costPriceEditingController.text = "";
        _quantityEditingController.text = "";
        _unitEditingController.text = "";
        _lotNumberEditingController.text = "";
        _expireDateEditingController.text = "";
        _expireDate = null;
        FocusScope.of(context).requestFocus(_serialNumberNode);
      } else if (state is GetSerialNumberState) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _snackBar.hideAll();
        });
        _serialNumberEditingController.text = state.serialNumber;
        FocusScope.of(context).requestFocus(_serialNumberNode);
      } else if (state is GetCategoryState) {
        setState(() {
          _categories = state.data;
          _category = state.data.firstOrNull;
        });
      }
    });

    _viewModel.getCategories();
  }

  @override
  void dispose() {
    _viewNode.dispose();
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
      appBar: AppBar(
        iconTheme: CustomTheme.mainTheme.iconTheme,
        backgroundColor: CustomColor.white,
        centerTitle: true,
        title: Text(
          Languages.of(context).productAddTitle,
          style: CustomTheme.mainTheme.textTheme.headlineSmall,
        ),
      ),
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DEFAULT_PAGE_PADDING),
      child: Column(
        children: <Widget>[
          _buildSerialNumber(context),
          _buildForm(context),
          const Padding(
            padding: EdgeInsets.only(top: 20),
          ),
          _buildAddButton(),
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
          _lotNumberNode,
        ),
        const Padding(
          padding: EdgeInsets.only(top: 12),
        ),
        _buildCategory(),
        const Padding(
          padding: EdgeInsets.only(top: 12),
        ),
        buildTextFormField(
          context,
          _lotNumberNode,
          _lotNumberEditingController,
          "Lot Number*",
          TextInputType.text,
          _viewNode,
        ),
        const Padding(
          padding: EdgeInsets.only(top: 12),
        ),
        _buildExpireDateField(
          context,
        ),
      ],
    );
  }

  _buildSerialNumber(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    if (Device.isMobile()) {
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
                key: const Key("Scan"),
                onClicked: () {
                  _nextToScan(context);
                },
                icon: const Icon(Icons.qr_code_scanner),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 60,
              height: 50,
              child: ButtonIconWidget(
                key: const Key("Gen"),
                onClicked: () {
                  _viewModel.generateSerialNumber();
                },
                icon: const Icon(Icons.abc),
              ),
            ),
          ],
        ),
      );
    } else {
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
                key: const Key("Gen"),
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
  }

  _buildSerialNumberField(
    BuildContext context,
  ) {
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
        labelStyle: CustomTheme.mainTheme.textTheme.bodyMedium,
        suffixIcon: IconButton(
          splashRadius: 20,
          onPressed: () {
            _nextToFindProduct(context);
          },
          icon: const Icon(Icons.search),
        ),
      ),
      cursorColor: CustomColor.hintColor,

      onFieldSubmitted: (term) {
        final serialNumber = _serialNumberEditingController.text;
        if (serialNumber.isNotEmpty) {
          _viewModel.getProductSerialNumber(serialNumber);
          _serialNumberNode.unfocus();
        }
      },
    );
  }

  _buildExpireDateField(
    BuildContext context,
  ) {
    return TextFormField(
      canRequestFocus: false,
      controller: _expireDateEditingController,
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
        labelText: "Expire Date*",
        labelStyle: CustomTheme.mainTheme.textTheme.bodyMedium,
      ),
      cursorColor: CustomColor.hintColor,
      readOnly: true,
      onTap: () async {
        final now = DateTime.now();
        final lastDate = DateTime(now.year + 10, now.month, now.day);
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: now,
          firstDate: now,
          lastDate: lastDate,
        );

        if (pickedDate != null) {
          var format = DateFormat("dd/MM/yyyy");
          _expireDate = pickedDate;
          setState(() {
            _expireDateEditingController.text = format.format(pickedDate);
          });
        }
      },
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

  _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ButtonWidget(
        key: const Key("Add"),
        onClicked: () {
          _viewModel.addProduct(_getProductParam());
        },
        text: "Add",
      ),
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
    var quantity = 0;
    if (_quantityEditingController.text.trim().isNotEmpty) {
      quantity = int.parse(_quantityEditingController.text);
    }
    return ProductParam(
      name: _nameEditingController.text,
      nameEn: null,
      description: _descriptionEditingController.text,
      price: price,
      costPrice: costPrice,
      quantity: quantity,
      unit: _unitEditingController.text,
      serialNumber: _serialNumberEditingController.text,
      lotNumber: _lotNumberEditingController.text,
      expireDate: _expireDate?.toUtc().toIso8601String(),
      category: _category?.value,
      receiveId: widget.receiveId,
    );
  }

  _nextToScan(BuildContext context) async {
    var result = await Navigator.pushNamed(context, SCAN_ROUTE, arguments: ScannerArgument("SCAN")) as Barcode?;
    if (result != null) {
      _serialNumberEditingController.text = result.code ?? "";
      _viewModel.getProductSerialNumber(result.code ?? "");
    }
  }

  _nextToFindProduct(BuildContext context) async {
    var result = await Navigator.pushNamed(context, PRODUCTS_ROUTE, arguments: ProductsArgument("FIND")) as String?;
    if (result != null) {
      _serialNumberEditingController.text = result;
      _viewModel.getProductSerialNumber(result);
    }
  }
}
