// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:common/core/ext/widget_ext.dart';
import 'package:common/core/error/failure.dart';
import 'package:design_system/widgets/app_bar.dart';
import 'package:design_system/widgets/buttons.dart';
import 'package:design_system/widgets/snack_bar.dart';
import 'package:design_system/widgets/dropdown_input.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:pos/container.dart';
import 'package:pos/domain/model/receive/param.dart';
import 'package:pos/domain/model/receive/receive.dart';
import 'package:pos/domain/model/receive/receive_item.dart';
import 'package:pos/domain/model/supplier/supplier.dart';
import 'package:pos/localizations/language/languages.dart';
import 'package:pos/presentation/constants.dart';
import 'package:pos/domain/usecase/product/get_products_use_case.dart';
import 'receive_item_dialog.dart';
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
  bool _loadingShown = false;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<ReceiveManageViewModel>();
    _viewModel.state.addListener(_onStateChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.getReceiveById(widget.receiveId);
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
    if (state.receiveLoaded) {
      _viewModel.consumeReceiveLoaded();
      setState(() {
        _receive = state.receive;
        _suppliers = state.receiveSuppliers;
        _supplier = _suppliers
            .where((item) => item.id == state.receive?.supplierId)
            .firstOrNull;
      });
      _referenceEditingController.text = state.receive?.reference ?? "";
    }
    if (state.suppliersEvent != null) {
      final suppliers = state.suppliersEvent!;
      _viewModel.consumeSuppliersEvent();
      setState(() {
        _suppliers = suppliers;
        _supplier =
            _suppliers.where((item) => item.id == _supplier?.id).firstOrNull;
      });
    }
    if (state.itemsLoaded) {
      _viewModel.consumeItemsLoaded();
      setState(() {
        _totalCost = state.totalCost;
        _receiveItems = state.items;
      });
    }
    if (state.created != null) {
      final data = state.created!;
      _viewModel.consumeCreated();
      _snackBar.hideAll();
      _snackBar.showSnackBar(text: "Add success");
      setState(() {
        _receive = data;
      });
    }
    if (state.updated != null) {
      final data = state.updated!;
      _viewModel.consumeUpdated();
      _snackBar.hideAll();
      _snackBar.showSnackBar(
          text: data.isImported ? "นำเข้าสต็อกสำเร็จ" : "Update success");
      setState(() {
        _receive = data;
      });
    }
    if (state.removed != null) {
      final data = state.removed!;
      _viewModel.consumeRemoved();
      Navigator.pop(context, data);
      return;
    }
  }

  @override
  void dispose() {
    _viewModel.state.removeListener(_onStateChanged);
    _referenceEditingController.dispose();
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
              if (_receive != null && !_receive!.isImported) {
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
    final button =
        _receive == null ? _buildAddButton() : _buildAddProductButton();
    return Container(
      padding: const EdgeInsets.all(defaultPagePadding),
      child: Column(
        children: <Widget>[
          if (_receive != null && !_viewModel.state.value.itemsReady)
            TextButton(
                onPressed: () => _viewModel.getReceiveItemsById(_receive!.id),
                child: const Text('โหลดรายการอีกครั้ง')),
          AbsorbPointer(
              absorbing: _receive?.isImported == true,
              child: _buildForm(context)),
          const SizedBox(height: 12),
          if (_receive?.isImported == true)
            const Text('นำเข้าสต็อกแล้ว', key: Key('receive-imported'))
          else
            button,
          const SizedBox(height: 12),
          _buildProductLots(),
          _buildTotalCost(),
          if (_receive != null &&
              !_receive!.isImported &&
              _receiveItems.isNotEmpty)
            TextButton(
              key: const Key('import-receive'),
              onPressed: () => showConfirmDialog(
                  context, 'ยืนยันนำใบรับสินค้าเข้าสต็อก?', () async {
                final saved = await _viewModel.updateReceiveById(
                    _receive!.id, _getUpdateReceiveParam());
                if (saved) await _viewModel.importReceive(_receive!.id);
              }),
              child: const Text('นำเข้าสต็อก'),
            ),
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
                child: Icon(
                    _receive?.isImported == true ? Icons.lock : Icons.delete),
                onTap: () {
                  if (!_receive!.isImported) {
                    _showRemoveItemAlertDialog(context, index);
                  }
                },
              ),
            ),
            title: Text('Name: ${content.product?.name ?? "-"}'),
            subtitle: Text(
                'Quantity: ${content.quantity} Cost: ${_format.format(content.costPrice)}'),
            trailing:
                Text(_format.format(content.costPrice * content.quantity)),
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
        if (_receive != null && !_receive!.isImported) _buildUpdateButton()
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
            _viewModel.updateReceiveById(
                _receive!.id, _getUpdateReceiveParam());
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
            _addReceiveItem();
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

  UpdateReceiveParam _getUpdateReceiveParam({List<ReceiveItem>? items}) {
    return UpdateReceiveParam(
      supplierId: _supplier?.id ?? "",
      reference: _referenceEditingController.text,
      totalCost: _totalCost,
      items: items ?? _receiveItems,
    );
  }

  _showRemoveAlertDialog(BuildContext context) {
    showConfirmDialog(context, "ต้องการลบใบรับสินค้าใช่หรือไม่", () {
      if (_receive != null) {
        _viewModel.removeReceiveById(_receive!.id);
      }
    });
  }

  _showRemoveItemAlertDialog(BuildContext context, int index) {
    showConfirmDialog(context, "ต้องการลบสินค้าใช่หรือไม่", () {
      final items = List<ReceiveItem>.of(_receiveItems)..removeAt(index);
      _viewModel.updateReceiveById(
          _receive!.id, _getUpdateReceiveParam(items: items));
    });
  }

  Future<void> _addReceiveItem() async {
    if (_viewModel.state.value.loading || !_viewModel.state.value.itemsReady) {
      return;
    }
    try {
      final products = await sl<GetProductsUseCase>()();
      if (!mounted) return;
      final item = await showDialog<ReceiveItem>(
        context: context,
        builder: (_) =>
            ReceiveItemDialog(receiveId: _receive!.id, products: products),
      );
      if (!mounted || item == null) return;
      await _viewModel.updateReceiveById(_receive!.id,
          _getUpdateReceiveParam(items: [..._receiveItems, item]));
    } on Exception catch (e) {
      if (mounted) _snackBar.showErrorSnackBar(toFailure(e).getMessage());
    }
  }

  _nextToSupplierAdd(BuildContext context) async {
    var _ = await Navigator.pushNamed(context, supplierAddRoute);
    _viewModel.getSuppliers();
  }
}
