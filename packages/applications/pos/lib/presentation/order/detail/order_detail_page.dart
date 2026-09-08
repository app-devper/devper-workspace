// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:common/core/ext/widget_ext.dart';
import 'package:design_system/widgets/app_bar.dart';
import 'package:design_system/widgets/snack_bar.dart';
import 'package:design_system/widgets/status_badge.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:pos/container.dart';
import 'package:pos/domain/model/customer/customer.dart';
import 'package:pos/domain/model/order/order_detail.dart';
import 'package:pos/domain/model/order/order_item_detail.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/model/receipt/receipt.dart';
import 'package:pos/domain/model/supplier/supplier.dart';
import 'package:pos/localizations/language/languages.dart';
import 'package:pos/presentation/constants.dart';
import 'package:design_system/widgets/dialogs.dart';
import 'package:pos/presentation/order/argument.dart';
import 'package:pos/presentation/order/core/export_pdf.dart';
import 'package:pos/presentation/order/return/product_return_widget.dart';
import 'package:pos/presentation/order/return/product_returns_history_widget.dart';
import 'package:pos/presentation/product/argument.dart';
import 'package:design_system/theme/color.dart';
import 'order_detail_view_model.dart';

class OrderDetailPage extends StatefulWidget {
  final String orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  State<StatefulWidget> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  final _nameEditingController = TextEditingController();
  final _addressEditingController = TextEditingController();

  final _viewNode = FocusNode();
  final _nameNode = FocusNode();
  final _addressNode = FocusNode();

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final format = NumberFormat("#,##0.00", "en_US");

  late CustomSnackBar _snackBar;
  late OrderDetailViewModel _viewModel;

  List<OrderItemDetail> orderItem = [];

  OrderDetail? order;

  double change = 0;

  bool isAdmin = false;

  bool _loadingShown = false;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<OrderDetailViewModel>();
    _viewModel.state.addListener(_onStateChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.checkLogin();
      _viewModel.getOrderById(widget.orderId);
    });
  }

  void _onStateChanged() {
    final state = _viewModel.state.value;
    if (state.loading && !_loadingShown) {
      _loadingShown = true;
      _snackBar.hideAll();
      _snackBar.showLoadingSnackBar();
    } else if (!state.loading && _loadingShown) {
      _loadingShown = false;
      _snackBar.hideAll();
    }
    if (state.error != null) {
      final message = state.error!;
      _viewModel.consumeError();
      _snackBar.hideAll();
      _snackBar.showErrorSnackBar(message);
    }
    if (state.logged != null) {
      final value = state.logged!;
      _viewModel.consumeLogged();
      setState(() {
        isAdmin = value;
      });
    }
    if (state.loaded != null) {
      final data = state.loaded!;
      _viewModel.consumeLoaded();
      setState(() {
        order = data;
        orderItem = data.items;
      });
    }
    if (state.removedOrder != null) {
      final data = state.removedOrder!;
      _viewModel.consumeRemovedOrder();
      Navigator.pop(context, data);
    }
    if (state.removedItem != null) {
      _viewModel.consumeRemovedItem();
      _viewModel.getOrderById(widget.orderId);
    }
    if (state.totalCostUpdated) {
      _viewModel.consumeTotalCostUpdated();
      _viewModel.getOrderById(widget.orderId);
    }
    if (state.supplierResult != null) {
      final result = state.supplierResult!;
      _viewModel.consumeSupplierResult();
      _showCustomerDialog(result.supplier, result.customer);
    }
    if (state.supplierError != null) {
      _viewModel.consumeSupplierError();
      _nextToSupplier(context);
    }
  }

  @override
  void dispose() {
    _viewModel.state.removeListener(_onStateChanged);
    _viewModel.dispose();

    _nameNode.dispose();
    _addressNode.dispose();
    _viewNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _snackBar = CustomSnackBar(key: const Key("snackbar"), context: context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: buildAppBar(
        Languages.of(context).orderDetailTitle,
        actions: _buildAction(context),
      ),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: CustomColor.statusBarColor,
        ),
        child: _buildBody(context),
      ),
    );
  }

  List<Widget> _buildAction(BuildContext context) {
    if (isAdmin) {
      return <Widget>[
        IconButton(
          splashRadius: 20,
          onPressed: () {
            _viewModel.getSupplier(order?.customerCode ?? "");
          },
          icon: const Icon(Icons.picture_as_pdf),
        ),
        IconButton(
          splashRadius: 20,
          onPressed: () {
            _viewModel.updateTotalCost();
          },
          icon: const Icon(Icons.sync),
        ),
        IconButton(
          splashRadius: 20,
          onPressed: () {
            _showProductReturnsHistoryDialog(context);
          },
          icon: const Icon(Icons.assignment_return),
        ),
        IconButton(
          splashRadius: 20,
          onPressed: () {
            _showRemoveOrderConfirm(context);
          },
          icon: const Icon(Icons.delete),
        ),
      ];
    } else {
      return <Widget>[
        IconButton(
          splashRadius: 20,
          onPressed: () {
            _viewModel.getSupplier(order?.customerCode ?? "");
          },
          icon: const Icon(Icons.picture_as_pdf),
        ),
      ];
    }
  }

  Widget _buildBody(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height,
      width: size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildOrderHeader(),
          _buildOrderItem(context),
          _buildSummaryTotal(),
        ],
      ),
    );
  }

  Widget _buildOrderHeader() {
    final Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      padding: const EdgeInsets.all(defaultPagePadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Flexible(
            child: _buildOrderDetail(),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetail() {
    return Container(
      height: 50,
      alignment: Alignment.centerLeft,
      child: Text(
        "${order?.code ?? ""} ${(order?.getCreatedDate() ?? "-")}",
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: orderItem.length,
        itemBuilder: (context, index) {
          final content = orderItem[index];
          return ListTile(
            leading: _buildListMenu(context, content),
            title: Text(content.product?.name ?? ""),
            trailing: Text(format.format(content.price)),
            subtitle: isAdmin
                ? Text(
                    "Cost : ${format.format(content.costPrice)}  Profit : ${format.format(content.price - content.costPrice)}")
                : null,
            onTap: () {
              if (isAdmin) {
                _nextToProductEdit(context, content.product);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildQuantityColumn(OrderItemDetail content) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text('${content.quantity}'),
        if (content.oversoldQty > 0)
          StatusBadge(label: 'เกิน ${content.oversoldQty}', color: Colors.orange),
        if (content.returnedQty > 0)
          StatusBadge(label: 'คืน ${content.returnedQty}', color: Colors.grey),
      ],
    );
  }

  Widget _buildListMenu(BuildContext context, OrderItemDetail content) {
    if (isAdmin) {
      return SizedBox(
          width: 130,
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              InkWell(
                onTap: () {
                  _showRemoveOrderItemConfirm(context, content);
                },
                child: const Icon(Icons.delete),
              ),
              InkWell(
                onTap: () {
                  _nextToOrderHistory(context, content.product);
                },
                child: const Icon(Icons.history),
              ),
              if (content.quantity - content.returnedQty > 0)
                InkWell(
                  onTap: () {
                    _showProductReturnDialog(context, content);
                  },
                  child: const Icon(Icons.keyboard_return),
                ),
              _buildQuantityColumn(content),
            ],
          ));
    } else {
      return _buildQuantityColumn(content);
    }
  }

  Widget _buildSummaryTotal() {
    return Container(
      padding: const EdgeInsets.all(defaultPagePadding),
      child: Column(
        children: <Widget>[
          _buildPrice(),
          _buildCostPrice(),
          _buildProfit(),
        ],
      ),
    );
  }

  Widget _buildPrice() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        const Text(
          'Total',
        ),
        Text(
          '฿ ${format.format(getTotalPrice())}',
        ),
      ],
    );
  }

  Widget _buildCostPrice() {
    if (isAdmin) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const Text(
            'Total Cost',
          ),
          Text(
            '฿ ${format.format(getTotalCostPrice())}',
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  Widget _buildProfit() {
    if (isAdmin) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const Text(
            'Total Profit',
          ),
          Text(
            '฿ ${format.format(getTotalPrice() - getTotalCostPrice())}',
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  double getTotalPrice() {
    double price = 0;
    for (var x in orderItem) {
      price += x.price;
    }
    return price;
  }

  double getTotalCostPrice() {
    double price = 0;
    for (var x in orderItem) {
      price += x.costPrice;
    }
    return price;
  }

  void _showRemoveOrderConfirm(BuildContext context) {
    showConfirmDialog(context, "ต้องการลบรายการใช่หรือไม่?", () {
      _viewModel.removeOrderById(widget.orderId);
    });
  }

  void _showRemoveOrderItemConfirm(BuildContext context, OrderItemDetail orderItem) {
    showConfirmDialog(context, "ต้องการลบสินค้าใช่หรือไม่?", () {
      _viewModel.removeOrderItem(orderItem.id);
    });
  }

  Future<void> _nextToProductEdit(BuildContext context, Product? product) async {
    if (product != null) {
      var result = await Navigator.pushNamed(context, productEditRoute,
          arguments: ProductArgument(product));
      if (result != null) {
        _viewModel.getOrderById(widget.orderId);
      }
    }
  }

  Future<void> _nextToOrderHistory(BuildContext context, Product? product) async {
    if (product != null) {
      var result = await Navigator.pushNamed(context, orderHistoryRoute,
          arguments: OrderHistoryArgument(product));
      if (result != null) {
        _viewModel.getOrderById(widget.orderId);
      }
    }
  }

  void _showProductReturnDialog(BuildContext context, OrderItemDetail content) {
    showCenterDialog(
      minWidth: 360,
      minHeight: 560,
      maxHeight: 560,
      maxWidth: 360,
      context: context,
      builder: (context) => ProductReturnWidget(
        orderId: widget.orderId,
        orderItemId: content.id,
        productName: content.product?.name ?? "",
        price: content.price,
        maxReturnable: content.quantity - content.returnedQty,
        onComplete: () {
          _viewModel.getOrderById(widget.orderId);
        },
      ),
    );
  }

  void _showProductReturnsHistoryDialog(BuildContext context) {
    showCenterDialog(
      context: context,
      builder: (context) => ProductReturnsHistoryWidget(orderId: widget.orderId),
    );
  }

  Future<void> _generateReceipt(Supplier supplier) async {
    final receipt = Receipt(
      supplier: supplier,
      customer: _getCustomer(),
      info: ReceiptInfo(
        date: order?.getDate() ?? "",
        number: order?.code ?? "",
      ),
      items: orderItem,
    );

    if (kIsWeb) {
      ExportPdf.download(receipt);
    } else {
      ExportPdf.generate(receipt);
    }
  }

  Future<void> _nextToSupplier(BuildContext context) async {
    var _ = await Navigator.pushNamed(context, supplierRoute);
  }

  void _showCustomerDialog(Supplier supplier, Customer? customer) {
    _nameEditingController.text = customer?.name ?? order?.customerName ?? "";
    _addressEditingController.text = customer?.address ?? "";

    AlertDialog alert = AlertDialog(
      title: const Text("Input Customer"),
      contentPadding: const EdgeInsets.all(16.0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
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
            _viewNode,
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: const Text('Confirm'),
          onPressed: () {
            Navigator.pop(context);
            _generateReceipt(supplier);
          },
        ),
      ],
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Customer _getCustomer() {
    return Customer(
      id: "",
      name: _nameEditingController.text,
      address: _addressEditingController.text,
      phone: "",
      email: "",
      code: '',
      status: '',
      type: '',
    );
  }
}
