// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:common/core/ext/widget_ext.dart';
import 'package:common/core/widgets/title_bar.dart';

// Project imports:
import 'package:pos/container.dart';
import 'package:pos/domain/model/core/core.dart';
import 'package:pos/domain/model/customer/customer.dart';
import 'package:pos/domain/model/customer/param.dart';
import 'package:pos/presentation/constants.dart';
import 'package:pos/presentation/core/core_widget.dart';
import 'package:pos/presentation/customer/edit/customer_edit_view_model.dart';

class CustomerEditPage extends StatefulWidget {
  final Customer customer;
  final Function() onBack;
  final Function() onEdit;
  final Function() onRemove;

  const CustomerEditPage({
    super.key,
    required this.customer,
    required this.onBack,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  State<StatefulWidget> createState() => _CustomerEditPageState();
}

class _CustomerEditPageState extends State<CustomerEditPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameEditingController = TextEditingController();
  final _addressEditingController = TextEditingController();
  final _phoneEditingController = TextEditingController();
  final _emailEditingController = TextEditingController();

  final _nameNode = FocusNode();
  final _addressNode = FocusNode();
  final _phoneNode = FocusNode();
  final _emailNode = FocusNode();

  late CustomerEditViewModel _viewModel;

  ItemType? _customer = customerTypes.first;
  final List<ItemType> _customers = customerTypes;

  bool _loadingShown = false;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<CustomerEditViewModel>();
    _viewModel.state.addListener(_onStateChanged);
    _setupData(widget.customer);
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
      showAlertDialog(context, state.error!, () {});
      _viewModel.consumeError();
    }
    if (state.updated != null) {
      _viewModel.consumeUpdated();
      widget.onEdit();
    }
    if (state.removed != null) {
      _viewModel.consumeRemoved();
      widget.onRemove();
    }
  }

  @override
  void dispose() {
    _viewModel.state.removeListener(_onStateChanged);
    _nameNode.dispose();
    _addressNode.dispose();
    _phoneNode.dispose();
    _emailNode.dispose();

    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TitleBar(
          title: widget.customer.name,
          onBack: () {
            widget.onBack();
          },
          action: "ยืนยัน",
          onAction: () {
            if (_formKey.currentState!.validate()) {
              _viewModel.updateCustomerById(widget.customer.id, _getCustomerParam());
            }
          },
        ),
        const Divider(height: 1),
        Expanded(
          child: _buildBody(),
        )
      ],
    );
  }

  _setupData(Customer data) {
    _nameEditingController.text = data.name;
    _addressEditingController.text = data.address;
    _emailEditingController.text = data.email;
    _phoneEditingController.text = data.phone;
  }

  _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(defaultPagePadding),
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
                    'โปรดระบุข้อมูลลูกค้า',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildForm(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          const SizedBox(height: 60),
          TextButton(
            onPressed: () => _showRemoveConfirm(context, widget.customer),
            child: const Text(
              "ลบลูกค้า",
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

  _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          DropdownButtonFormField<ItemType>(
            validator: (value) {
              return value == null ? 'โปรดเลือกประเภทลูกค้า' : null;
            },
            decoration: buildInputDecoration(
              labelText: 'ประเภทลูกค้า',
              hintText: 'โปรดเลือกประเภทลูกค้า',
            ),
            value: _customer,
            onChanged: (value) {
              setState(() {
                _customer = value;
              });
            },
            items: _customers.map((ItemType value) {
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
              labelText: 'ชื่อลูกค้า',
              hintText: 'โปรดระบุชื่อลูกค้า',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'โปรดระบุชื่อลูกค้า';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            inputFormatters: [
              LengthLimitingTextInputFormatter(100),
            ],
            focusNode: _addressNode,
            controller: _addressEditingController,
            minLines: 2,
            maxLines: 2,
            keyboardType: TextInputType.text,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            textAlignVertical: TextAlignVertical.top,
            decoration: buildInputDecoration(
              labelText: 'ที่อยู่',
              hintText: 'โปรดระบุที่อยู่',
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            inputFormatters: [
              LengthLimitingTextInputFormatter(10),
            ],
            focusNode: _phoneNode,
            controller: _phoneEditingController,
            keyboardType: TextInputType.phone,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: buildInputDecoration(
              labelText: 'โทรศัพท์',
              hintText: 'โปรดระบุเบอร์โทรศัพท์',
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            inputFormatters: [
              LengthLimitingTextInputFormatter(50),
            ],
            focusNode: _emailNode,
            controller: _emailEditingController,
            keyboardType: TextInputType.emailAddress,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: buildInputDecoration(
              labelText: 'อีเมล',
              hintText: 'โปรดระบุอีเมล',
            ),
          ),
        ],
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
      customerType: _customer?.type ?? "",
    );
  }
}
