import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:common/core/ext/widget_ext.dart';
import 'package:design_system/widgets/app_bar.dart';
import 'package:design_system/widgets/buttons.dart';
import 'package:design_system/widgets/snack_bar.dart';

import 'package:design_system/widgets/page_container.dart';

// Project imports:
import 'package:pos/container.dart';
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product_lot.dart';
import 'package:pos/localizations/language/languages.dart';
import 'package:pos/presentation/constants.dart';
import 'product_lot_edit_view_model.dart';

class ProductLotEditPage extends StatefulWidget {
  final ProductLot productLot;

  const ProductLotEditPage({super.key, required this.productLot});

  @override
  State<StatefulWidget> createState() => _ProductLotEditPageState();
}

class _ProductLotEditPageState extends State<ProductLotEditPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _nameEditingController = TextEditingController();
  final _quantityEditingController = TextEditingController();
  final _lotNumberEditingController = TextEditingController();
  final _expireDateEditingController = TextEditingController();
  final _costPriceEditingController = TextEditingController();

  final _viewNode = FocusNode();
  final _nameNode = FocusNode();
  final _quantityNode = FocusNode();
  final _lotNumberNode = FocusNode();
  final _costPriceNode = FocusNode();
  final _expireDateNode = FocusNode();

  late CustomSnackBar _snackBar;
  late ProductLotEditViewModel _viewModel;
  late StreamSubscription<String> _errors;
  late StreamSubscription<ProductLot> _loaded;
  late StreamSubscription<ProductLot> _updated;

  bool _loadingShown = false;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<ProductLotEditViewModel>();
    _viewModel.state.addListener(_onStateChanged);
    _errors = _viewModel.errors.listen(_showError);
    _loaded = _viewModel.loaded.listen(_onLoaded);
    _updated = _viewModel.updated.listen(_onUpdated);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.getProductLot(widget.productLot);
    });
  }

  void _showError(String message) {
    _snackBar.hideAll();
    _snackBar.showErrorSnackBar(message);
  }

  void _onLoaded(ProductLot data) {
    _nameEditingController.text = data.product?.name ?? "-";
    _costPriceEditingController.text = data.costPrice.toString();
    _quantityEditingController.text = data.quantity.toString();
    _lotNumberEditingController.text = data.lotNumber;
    _expireDateEditingController.text = data.getExpireDate();
    FocusScope.of(context).requestFocus(_quantityNode);
  }

  void _onUpdated(ProductLot data) {
    _snackBar.hideAll();
    _snackBar.showSnackBar(text: "Update success");
  }

  void _onStateChanged() {
    final state = _viewModel.state.value;
    if (state.loading && !_loadingShown) {
      _loadingShown = true;
      _snackBar.hideAll();
      showLoadingDialog(context);
    } else if (!state.loading && _loadingShown) {
      _loadingShown = false;
      hideLoadingDialog(context);
    }
  }

  @override
  void dispose() {
    _viewModel.state.removeListener(_onStateChanged);
    _errors.cancel();
    _loaded.cancel();
    _updated.cancel();
    _viewNode.dispose();
    _nameNode.dispose();
    _costPriceNode.dispose();
    _quantityNode.dispose();
    _expireDateNode.dispose();

    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _snackBar = CustomSnackBar(key: const Key("snackbar"), context: context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: buildAppBar(
        Languages.of(context).productLotEditTitle,
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: PageContainer(
        maxWidth: 640,
        padding: const EdgeInsets.all(defaultPagePadding),
        child: Column(
          children: <Widget>[
            _buildForm(context),
            const Padding(
              padding: EdgeInsets.only(top: 20),
            ),
            _buildUpdateButton(),
          ],
        ),
      ),
    );
  }

  Column _buildForm(BuildContext context) {
    return Column(
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.only(top: 12),
        ),
        buildTextFormFieldReadOnly(
          context,
          _nameNode,
          _nameEditingController,
          "Name*",
          TextInputType.text,
          _viewNode,
        ),
        const Padding(
          padding: EdgeInsets.only(top: 12),
        ),
        buildTextFormFieldReadOnly(
          context,
          _costPriceNode,
          _costPriceEditingController,
          "Cost Price*",
          const TextInputType.numberWithOptions(decimal: true),
          _viewNode,
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
          _viewNode,
        ),
        const Padding(
          padding: EdgeInsets.only(top: 12),
        ),
        buildTextFormFieldReadOnly(
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
        buildTextFormFieldReadOnly(
          context,
          _expireDateNode,
          _expireDateEditingController,
          "Expire Date*",
          TextInputType.text,
          _viewNode,
        ),
      ],
    );
  }

  SizedBox _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ButtonWidget(
        key: const Key("update"),
        onClicked: () {
          final quantity = int.tryParse(_quantityEditingController.text.trim());
          if (quantity == null || quantity < 0) {
            _snackBar.showErrorSnackBar('ระบุจำนวนเต็มตั้งแต่ 0 ขึ้นไป');
            return;
          }
          _viewModel.updateProductLot(
            widget.productLot.id,
            UpdateProductLotQuantityParam(quantity: quantity),
          );
        },
        text: "Update",
      ),
    );
  }
}
