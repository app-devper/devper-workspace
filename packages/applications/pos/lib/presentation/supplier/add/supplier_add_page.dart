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
import 'package:pos/domain/model/supplier/supplier.dart';
import 'package:pos/domain/model/supplier/param.dart';
import 'package:pos/localizations/language/languages.dart';
import 'package:pos/presentation/constants.dart';
import 'package:pos/presentation/supplier/add/supplier_add_view_model.dart';

class SupplierAddPage extends StatefulWidget {
  const SupplierAddPage({super.key});

  @override
  State<StatefulWidget> createState() => _SupplierAddPageState();
}

class _SupplierAddPageState extends State<SupplierAddPage> {
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
  late SupplierAddViewModel _viewModel;
  late StreamSubscription<String> _errors;
  late StreamSubscription<Supplier> _created;

  bool _loadingShown = false;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<SupplierAddViewModel>();
    _viewModel.state.addListener(_onStateChanged);
    _errors = _viewModel.errors.listen(_showError);
    _created = _viewModel.created.listen(_onCreated);
  }

  void _showError(String message) {
    _snackBar.hideAll();
    _snackBar.showErrorSnackBar(message);
  }

  void _onCreated(Supplier supplier) {
    _snackBar.hideAll();
    _snackBar.showSnackBar(text: "Add ${supplier.name} success");
    _nameEditingController.text = "";
    _addressEditingController.text = "";
    _phoneEditingController.text = "";
    _taxIdEditingController.text = "";
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
  }

  @override
  void dispose() {
    _viewModel.state.removeListener(_onStateChanged);
    _errors.cancel();
    _created.cancel();
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
        Languages.of(context).supplierAddTitle,
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
              padding: EdgeInsets.only(top: defaultPagePadding),
            ),
            _buildAddButton(),
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

  SizedBox _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ButtonWidget(
        key: const Key("add"),
        onClicked: () {
          _viewModel.createSupplier(_getSupplierParam());
        },
        text: "Add",
      ),
    );
  }

  SupplierParam _getSupplierParam() {
    return SupplierParam(
      name: _nameEditingController.text,
      address: _addressEditingController.text,
      phone: _phoneEditingController.text,
      taxId: _taxIdEditingController.text,
    );
  }
}
