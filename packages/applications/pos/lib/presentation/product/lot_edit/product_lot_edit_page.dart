// Flutter imports:
import 'package:common/core/widgets/appbar_widget.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:common/core/ext/widget_ext.dart';
import 'package:common/core/widgets/button_widget.dart';
import 'package:common/core/widgets/custom_snack_bar.dart';

// Project imports:
import 'package:pos/container.dart';
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product_lot.dart';
import 'package:pos/localizations/language/languages.dart';
import 'package:pos/presentation/constants.dart';
import 'product_lot_edit_state.dart';
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

  @override
  void initState() {
    super.initState();
    _viewModel = sl<ProductLotEditViewModel>();
    _viewModel.states.listen((state) {
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
      } else if (state is GetProductLotState) {
        _nameEditingController.text = state.data.product?.name ?? "-";
        _costPriceEditingController.text = state.data.costPrice.toString();
        _quantityEditingController.text = state.data.quantity.toString();
        _lotNumberEditingController.text = state.data.lotNumber;
        _expireDateEditingController.text = state.data.getExpireDate();

        FocusScope.of(context).requestFocus(_quantityNode);
      } else if (state is UpdateProductLotState) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _snackBar.hideAll();
          _snackBar.showSnackBar(text: "Update success");
        });
        hideLoadingDialog(context);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.getProductLot(widget.productLot);
    });
  }

  @override
  void dispose() {
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

  _buildBody(BuildContext context) {
    return SingleChildScrollView(
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
    );
  }

  _buildForm(BuildContext context) {
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

  _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ButtonWidget(
        key: const Key("update"),
        onClicked: () {
          _viewModel.updateProductLot(
            widget.productLot.id,
            _getUpdateProductLotQuantityParam(),
          );
        },
        text: "Update",
      ),
    );
  }

  _getUpdateProductLotQuantityParam() {
    var quantity = 0;
    if (_quantityEditingController.text.trim().isNotEmpty) {
      quantity = int.parse(_quantityEditingController.text);
    }
    return UpdateProductLotQuantityParam(
      quantity: quantity,
    );
  }
}
