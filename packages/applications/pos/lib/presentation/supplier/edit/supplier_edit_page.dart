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
import 'package:pos/domain/model/supplier/param.dart';
import 'package:pos/domain/model/supplier/supplier.dart';
import 'package:pos/localizations/language/languages.dart';
import 'package:pos/presentation/constants.dart';
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

  bool _loadingShown = false;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<SupplierEditViewModel>();
    _viewModel.state.addListener(_onStateChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupData(widget.supplier);
    });
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
      _snackBar.hideAll();
      _snackBar.showErrorSnackBar(state.error!);
      _viewModel.consumeError();
    }
    if (state.updated != null) {
      _snackBar.hideAll();
      _snackBar.showSnackBar(text: "Update ${state.updated!.name} success");
      _viewModel.consumeUpdated();
    }
    if (state.removed != null) {
      Navigator.pop(context, state.removed);
    }
  }

  @override
  void dispose() {
    _viewModel.state.removeListener(_onStateChanged);
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

  void _setupData(Supplier data) {
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

  SizedBox _buildUpdateButton() {
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

  void _showRemoveConfirm(BuildContext context, Supplier data) {
    showConfirmDialog(context, "ต้องการลบร้านค้าใช่หรือไม่?", () {
      _viewModel.removeSupplierById(data.id);
    });
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
