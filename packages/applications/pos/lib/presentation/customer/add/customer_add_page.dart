// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:common/core/ext/widget_ext.dart';
import 'package:common/core/widgets/button_widget.dart';
import 'package:common/core/widgets/custom_snack_bar.dart';

// Project imports:
import 'package:pos/container.dart';
import 'package:pos/domain/model/customer/param.dart';
import 'package:pos/localizations/language/languages.dart';
import 'package:pos/presentation/constants.dart';
import 'package:pos/presentation/customer/add/customer_add_state.dart';
import 'package:pos/presentation/customer/add/customer_add_view_model.dart';
import 'package:pos/presentation/theme.dart';

class CustomerAddPage extends StatefulWidget {
  const CustomerAddPage({super.key});

  @override
  State<StatefulWidget> createState() => _CustomerAddPageState();
}

class _CustomerAddPageState extends State<CustomerAddPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _nameEditingController = TextEditingController();
  final _addressEditingController = TextEditingController();
  final _phoneEditingController = TextEditingController();
  final _emailEditingController = TextEditingController();

  final _viewNode = FocusNode();
  final _nameNode = FocusNode();
  final _addressNode = FocusNode();
  final _phoneNode = FocusNode();
  final _emailNode = FocusNode();

  late CustomSnackBar _snackBar;

  late CustomerAddViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<CustomerAddViewModel>();
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
      } else if (state is CreateCustomerState) {
        hideLoadingDialog(context);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _snackBar.hideAll();
          _snackBar.showSnackBar(text: "Add ${state.data.name} success");
        });
        _nameEditingController.text = "";
        _addressEditingController.text = "";
        _phoneEditingController.text = "";
        _emailEditingController.text = "";
        FocusScope.of(context).requestFocus(_nameNode);
      }
    });
  }

  @override
  void dispose() {
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
          Languages.of(context).customerAddTitle,
          style: CustomTheme.mainTheme.textTheme.headlineSmall,
        ),
      ),
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DEFAULT_PAGE_PADDING),
      child: Container(
        child: Column(
          children: <Widget>[
            _buildForm(context),
            const Padding(
              padding: EdgeInsets.only(top: DEFAULT_PAGE_PADDING),
            ),
            _buildAddButton(),
          ],
        ),
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

  _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ButtonWidget(
        key: const Key("Add"),
        onClicked: () {
          _viewModel.createCustomer(_getCustomerParam());
        },
        text: "Add",
      ),
    );
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
