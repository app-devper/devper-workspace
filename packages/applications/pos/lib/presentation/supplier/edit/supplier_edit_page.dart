// Flutter imports:
import 'package:common/core/widgets/appbar_widget.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:common/core/ext/widget_ext.dart';
import 'package:common/core/widgets/button_widget.dart';
import 'package:common/core/widgets/custom_snack_bar.dart';

// Project imports:
import 'package:pos/container.dart';
import 'package:pos/domain/model/supplier/param.dart';
import 'package:pos/domain/model/supplier/supplier.dart';
import 'package:pos/localizations/language/languages.dart';
import 'package:pos/presentation/constants.dart';
import 'package:pos/presentation/supplier/edit/supplier_edit_state.dart';
import 'package:pos/presentation/supplier/edit/supplier_edit_view_model.dart';

class SupplierEditPage extends StatefulWidget {
  final Supplier supplier;

  const SupplierEditPage({super.key, required this.supplier});

  @override
  State<StatefulWidget> createState() => _SupplierEditPageState();
}

class _SupplierEditPageState extends State<SupplierEditPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _nameEditingController = TextEditingController();
  final _addressEditingController = TextEditingController();
  final _phoneEditingController = TextEditingController();
  final _taxIdEditingController = TextEditingController();

  final _viewNode = FocusNode();
  final _nameNode = FocusNode();
  final _addressNode = FocusNode();
  final _phoneNode = FocusNode();
  final _taxIdNode = FocusNode();

  late CustomSnackBar _snackBar;

  late SupplierEditViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<SupplierEditViewModel>();
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
      } else if (state is UpdateSupplierState) {
        hideLoadingDialog(context);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _snackBar.hideAll();
          _snackBar.showSnackBar(text: "Update ${state.data.name} success");
        });
      } else if (state is RemoveSupplierState) {
        hideLoadingDialog(context);
        Navigator.pop(context, state.data);
      } else if (state is GetSupplierState) {
        _setupData(state.data);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.getSupplier(widget.supplier);
    });
  }

  @override
  void dispose() {
    _viewNode.dispose();
    _nameNode.dispose();
    _addressNode.dispose();
    _phoneNode.dispose();
    _taxIdNode.dispose();

    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _snackBar = CustomSnackBar(key: const Key("snackbar"), context: context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: buildAppBar(
        Languages.of(context).supplierEditTitle,
        actions: _buildAction(context),
      ),
      body: _buildBody(context),
    );
  }

  _setupData(Supplier data) {
    _nameEditingController.text = data.name;
    _addressEditingController.text = data.address;
    _phoneEditingController.text = data.phone;
    _taxIdEditingController.text = data.taxId;
  }

  List<Widget> _buildAction(BuildContext context) {
    return [
      IconButton(
        splashRadius: 20,
        onPressed: () {
          _showRemoveConfirm(context, widget.supplier);
        },
        icon: const Icon(Icons.delete),
      ),
    ];
  }

  _buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(defaultPagePadding),
      child: Column(
        children: <Widget>[
          _buildForm(context),
          const Padding(
            padding: EdgeInsets.only(top: defaultPagePadding),
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
        buildTextFormField(
          context,
          _nameNode,
          _nameEditingController,
          "Name*",
          TextInputType.text,
          _addressNode,
        ),
        const Padding(
          padding: EdgeInsets.only(top: 12),
        ),
        buildAddressFormField(
          context,
          _addressNode,
          _addressEditingController,
          "Address*",
          TextInputType.text,
          _phoneNode,
        ),
        const Padding(
          padding: EdgeInsets.only(top: 12),
        ),
        buildTextFormField(
          context,
          _phoneNode,
          _phoneEditingController,
          "Phone",
          TextInputType.phone,
          _taxIdNode,
        ),
        const Padding(
          padding: EdgeInsets.only(top: 12),
        ),
        buildTextFormField(
          context,
          _taxIdNode,
          _taxIdEditingController,
          "Tax Id",
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
          _viewModel.updateSupplierById(widget.supplier.id, _getSupplierParam());
        },
        text: "Update",
      ),
    );
  }

  _showRemoveConfirm(BuildContext context, Supplier data) {
    showConfirmDialog(context, "ต้องการลบร้านค้าใช่หรือไม่?", () {
      _viewModel.removeSupplierById(data.id);
    });
  }

  _getSupplierParam() {
    return SupplierParam(
      name: _nameEditingController.text,
      address: _addressEditingController.text,
      phone: _phoneEditingController.text,
      taxId: _taxIdEditingController.text,
    );
  }
}
