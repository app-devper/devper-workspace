// Flutter imports:
import 'package:common/core/widgets/appbar_widget.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:common/core/ext/widget_ext.dart';
import 'package:common/core/widgets/button_widget.dart';
import 'package:common/core/widgets/custom_snack_bar.dart';
import 'package:common/core/widgets/dropdown_widget.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:pos/container.dart';
import 'package:pos/domain/model/receive/param.dart';
import 'package:pos/domain/model/receive/receive.dart';
import 'package:pos/domain/model/receive/receive_item.dart';
import 'package:pos/domain/model/supplier/supplier.dart';
import 'package:pos/localizations/language/languages.dart';
import 'package:pos/presentation/constants.dart';
import 'package:pos/presentation/product/argument.dart';
import 'receive_manage_state.dart';
import 'receive_manage_view_model.dart';

class ReceiveManagePage extends StatefulWidget {
  final String? receiveId;

  const ReceiveManagePage({super.key, required this.receiveId});

  @override
  State<StatefulWidget> createState() => _ReceiveManagePageState();
}

class _ReceiveManagePageState extends State<ReceiveManagePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _format = NumberFormat("#,##0.00", "en_US");

  final _referenceEditingController = TextEditingController();

  final _viewNode = FocusNode();
  final _referenceNode = FocusNode();

  late CustomSnackBar _snackBar;
  late ReceiveManageViewModel _viewModel;

  Receive? _receive;
  Supplier? _supplier;

  List<Supplier> _suppliers = [];
  List<ReceiveItem> _receiveItems = [];

  double _totalCost = 0;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<ReceiveManageViewModel>();
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
      } else if (state is GetReceiveState) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _snackBar.hideAll();
        });
        hideLoadingDialog(context);
        setState(() {
          _receive = state.data;
          _suppliers = state.suppliers;
          _supplier = _suppliers.where((item) => item.id == state.data?.supplierId).firstOrNull;
        });
        _referenceEditingController.text = state.data?.reference ?? "";
      } else if (state is UpdateReceiveState) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _snackBar.hideAll();
          _snackBar.showSnackBar(text: "Update success");
        });
        hideLoadingDialog(context);
        setState(() {
          _receive = state.data;
        });
      } else if (state is CreateReceiveState) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _snackBar.hideAll();
          _snackBar.showSnackBar(text: "Add success");
        });
        hideLoadingDialog(context);
        setState(() {
          _receive = state.data;
        });
      } else if (state is RemoveReceiveState) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _snackBar.hideAll();
        });
        hideLoadingDialog(context);
        Navigator.pop(context, state.data);
      } else if (state is RemoveReceiveItemState) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _snackBar.hideAll();
        });
        hideLoadingDialog(context);
        _viewModel.getReceiveItemsById(state.data.receiveId);
      } else if (state is GetReceiveItemsState) {
        setState(() {
          _totalCost = state.totalCost;
          _receiveItems = state.data;
        });
      } else if (state is GetSuppliersState) {
        setState(() {
          _suppliers = state.suppliers;
          _supplier = _suppliers.where((item) => item.id == _supplier?.id).firstOrNull;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.getReceiveById(widget.receiveId);
    });
  }

  @override
  void dispose() {
    _referenceNode.dispose();
    _viewNode.dispose();

    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _snackBar = CustomSnackBar(key: const Key("snackbar"), context: context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: buildAppBar(
        Languages.of(context).receiveManageTitle,
        actions: [
          IconButton(
            splashRadius: 20,
            onPressed: () {
              if (_receive != null) {
                _showRemoveAlertDialog(context);
              }
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    final button = _receive == null ? _buildAddButton() : _buildAddProductButton();
    return Container(
      padding: const EdgeInsets.all(defaultPagePadding),
      child: Column(
        children: <Widget>[
          _buildForm(context),
          const SizedBox(height: 12),
          button,
          const SizedBox(height: 12),
          _buildProductLots(),
          _buildTotalCost(),
        ],
      ),
    );
  }

  _buildForm(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildSuppliers(),
        const SizedBox(height: 12),
        buildTextFormField(
          context,
          _referenceNode,
          _referenceEditingController,
          "หมายเลขอางอิง",
          TextInputType.text,
          _viewNode,
        ),
      ],
    );
  }

  _buildSuppliers() {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Flexible(
            child: DropdownInput<Supplier>(
              hintText: "ร้านขายสินค้า",
              options: _suppliers,
              value: _supplier,
              onChanged: (Supplier? value) {
                setState(() {
                  _supplier = value;
                });
              },
              getLabel: (Supplier value) => value.name,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 60,
            height: 50,
            child: ButtonIconWidget(
              key: const Key("supplier"),
              onClicked: () {
                _nextToSupplierAdd(context);
              },
              icon: const Icon(Icons.add_business),
            ),
          ),
        ],
      ),
    );
  }

  Expanded _buildProductLots() {
    return Expanded(
      child: ListView.builder(
        itemCount: _receiveItems.length,
        itemBuilder: (context, index) {
          final content = _receiveItems[index];
          return ListTile(
            leading: SizedBox(
              width: 50,
              height: 50,
              child: InkWell(
                child: const Icon(Icons.delete),
                onTap: () {
                  _showRemoveItemAlertDialog(context, content.lotId);
                },
              ),
            ),
            title: Text('Name: ${content.product?.name ?? "-"}'),
            subtitle: Text('Quantity: ${content.quantity} Cost: ${_format.format(content.costPrice)}'),
            trailing: Text(_format.format(content.costPrice * content.quantity)),
            onTap: () {},
          );
        },
      ),
    );
  }

  _buildTotalCost() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Total Cost',
        ),
        Expanded(
          child: Text(
            '฿ ${_format.format(_totalCost)}',
            textAlign: TextAlign.end,
          ),
        ),
        const SizedBox(width: 20),
        _buildUpdateButton()
      ],
    );
  }

  _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ButtonWidget(
        key: const Key("add"),
        onClicked: () {
          if (_receive == null) {
            _viewModel.createReceive(_getReceiveParam());
          }
        },
        text: "สร้างใบรับสินค้า",
      ),
    );
  }

  _buildUpdateButton() {
    return SizedBox(
      width: 100,
      height: 50,
      child: ButtonWidget(
        key: const Key("update"),
        onClicked: () {
          if (_receive != null) {
            _viewModel.updateReceiveById(_receive!.id, _getUpdateReceiveParam());
          }
        },
        text: "บันทึก",
      ),
    );
  }

  _buildAddProductButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ButtonWidget(
        key: const Key("product"),
        onClicked: () {
          if (_receive != null) {
            _nextToProductAdd(context, _receive!.id);
          }
        },
        text: "เพิ่มรายการสินค้า",
      ),
    );
  }

  _getReceiveParam() {
    return ReceiveParam(
      supplierId: _supplier?.id ?? "",
      reference: _referenceEditingController.text,
    );
  }

  _getUpdateReceiveParam() {
    return UpdateReceiveParam(
      supplierId: _supplier?.id ?? "",
      reference: _referenceEditingController.text,
      totalCost: _totalCost,
    );
  }

  _showRemoveAlertDialog(BuildContext context) {
    showConfirmDialog(context, "ต้องการลบใบรับสินค้าใช่หรือไม่", () {
      if (_receive != null) {
        _viewModel.removeReceiveById(_receive!.id);
      }
    });
  }

  _showRemoveItemAlertDialog(BuildContext context, String lotId) {
    showConfirmDialog(context, "ต้องการลบสินค้าใช่หรือไม่", () {
      _viewModel.removeReceiveItemById(lotId);
    });
  }

  _nextToProductAdd(BuildContext context, String receiveId) async {
    var _ = await Navigator.pushNamed(context, PRODUCT_ADD_ROUTE, arguments: ProductAddArgument(receiveId));
    _viewModel.getReceiveItemsById(receiveId);
  }

  _nextToSupplierAdd(BuildContext context) async {
    var _ = await Navigator.pushNamed(context, SUPPLIER_ADD_ROUTE);
    _viewModel.getSuppliers();
  }
}
