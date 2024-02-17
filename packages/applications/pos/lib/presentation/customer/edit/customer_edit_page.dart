// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:common/core/ext/widget_ext.dart';
import 'package:common/core/widgets/button_widget.dart';
import 'package:common/core/widgets/custom_snack_bar.dart';

// Project imports:
import 'package:pos/container.dart';
import 'package:pos/domain/model/customer/customer.dart';
import 'package:pos/domain/model/customer/param.dart';
import 'package:pos/localizations/language/languages.dart';
import 'package:pos/presentation/constants.dart';
import 'package:pos/presentation/customer/edit/customer_edit_state.dart';
import 'package:pos/presentation/customer/edit/customer_edit_view_model.dart';
import 'package:pos/presentation/theme.dart';

class CustomerEditPage extends StatefulWidget {
  final Customer customer;

  const CustomerEditPage({super.key, required this.customer});

  @override
  State<StatefulWidget> createState() => _CustomerEditPageState();
}

class _CustomerEditPageState extends State<CustomerEditPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _codeEditingController = TextEditingController();
  final _nameEditingController = TextEditingController();
  final _addressEditingController = TextEditingController();
  final _phoneEditingController = TextEditingController();
  final _emailEditingController = TextEditingController();

  final _viewNode = FocusNode();
  final _codeNode = FocusNode();
  final _nameNode = FocusNode();
  final _addressNode = FocusNode();
  final _phoneNode = FocusNode();
  final _emailNode = FocusNode();

  late CustomSnackBar _snackBar;

  late CustomerEditViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<CustomerEditViewModel>();
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
      } else if (state is UpdateCustomerState) {
        hideLoadingDialog(context);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _snackBar.hideAll();
          _snackBar.showSnackBar(text: "Update ${state.data.name} success");
        });
      } else if (state is RemoveCustomerState) {
        hideLoadingDialog(context);
        Navigator.pop(context, state.data);
      } else if (state is GetCustomerState) {
        hideLoadingDialog(context);
        _setupData(state.data);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.getCustomerById(widget.customer.id);
    });
  }

  @override
  void dispose() {
    _codeNode.dispose();
    _nameNode.dispose();
    _addressNode.dispose();
    _phoneNode.dispose();
    _emailNode.dispose();

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
          Languages.of(context).customerEditTitle,
          style: CustomTheme.mainTheme.textTheme.headlineSmall,
        ),
        actions: _buildAction(context),
      ),
      body: _buildBody(context),
    );
  }

  _setupData(Customer data) {
    _codeEditingController.text = data.code;
    _nameEditingController.text = data.name;
    _addressEditingController.text = data.address;
    _emailEditingController.text = data.email;
    _phoneEditingController.text = data.phone;
  }

  List<Widget> _buildAction(BuildContext context) {
    return [
      IconButton(
        splashRadius: 20,
        onPressed: () {
          _showRemoveConfirm(context, widget.customer);
        },
        icon: const Icon(Icons.delete),
      ),
    ];
  }

  _buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DEFAULT_PAGE_PADDING),
      child: Column(
        children: <Widget>[
          _buildForm(context),
          const Padding(
            padding: EdgeInsets.only(top: DEFAULT_PAGE_PADDING),
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
          _codeNode,
          _codeEditingController,
          "Member Code",
          TextInputType.text,
          _nameNode,
        ),
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
          "Address",
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
          _emailNode,
        ),
        const Padding(
          padding: EdgeInsets.only(top: 12),
        ),
        buildTextFormField(
          context,
          _emailNode,
          _emailEditingController,
          "Email",
          TextInputType.emailAddress,
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
          _viewModel.updateCustomerById(widget.customer.id, _getCustomerParam());
        },
        text: "Update",
      ),
    );
  }

  _showRemoveConfirm(BuildContext context, Customer data) {
    showConfirmDialog(context, "ต้องการลบลูกค้าใช่หรือไม่?", () {
      _viewModel.removeCustomerById(data.id);
    });
  }

  _getCustomerParam() {
    return CustomerParam(
      name: _nameEditingController.text,
      address: _addressEditingController.text,
      phone: _phoneEditingController.text,
      email: _emailEditingController.text,
    );
  }
}
