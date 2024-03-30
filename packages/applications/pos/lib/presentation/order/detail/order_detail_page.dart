// Flutter imports:
import 'package:common/core/widgets/appbar_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:common/core/ext/widget_ext.dart';
import 'package:common/core/widgets/custom_snack_bar.dart';
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
import 'package:pos/presentation/order/argument.dart';
import 'package:pos/presentation/order/core/export_pdf.dart';
import 'package:pos/presentation/product/argument.dart';
import 'package:pos/presentation/theme.dart';
import 'order_detail_state.dart';
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

  @override
  void initState() {
    super.initState();
    _viewModel = sl<OrderDetailViewModel>();
    _viewModel.states.stream.listen((state) {
      if (state is ErrorState) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _snackBar.hideAll();
          _snackBar.showErrorSnackBar(state.message);
        });
      } else if (state is LoadingState) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _snackBar.hideAll();
          _snackBar.showLoadingSnackBar();
        });
      } else if (state is OrderState) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _snackBar.hideAll();
        });
        setState(() {
          order = state.order;
          orderItem = state.order.items;
        });
      } else if (state is RemoveOrderState) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _snackBar.hideAll();
        });
        Navigator.pop(context, state.order);
      } else if (state is RemoveOrderItemState) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _snackBar.hideAll();
        });
        _viewModel.getOrderById(widget.orderId);
      } else if (state is LoggedState) {
        setState(() {
          isAdmin = state.isAdmin;
        });
      } else if (state is UpdateTotalCostState) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _snackBar.hideAll();
        });
        _viewModel.getOrderById(widget.orderId);
      } else if (state is GetSupplierState) {
        _showCustomerDialog(state.supplier, state.customer);
      } else if (state is GetSupplierErrorState) {
        _nextToSupplier(context);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.checkLogin();
      _viewModel.getOrderById(widget.orderId);
    });
  }

  @override
  void dispose() {
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
            _viewModel.updateTotalCost(widget.orderId);
          },
          icon: const Icon(Icons.sync),
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
            subtitle: isAdmin ? Text("Cost : ${format.format(content.costPrice)}  Profit : ${format.format(content.price - content.costPrice)}") : null,
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

  Widget _buildListMenu(BuildContext context, OrderItemDetail content) {
    if (isAdmin) {
      return SizedBox(
          width: 90,
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
              Text(
                '${content.quantity}',
              ),
            ],
          ));
    } else {
      return Text(
        '${content.quantity}',
      );
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

  _showRemoveOrderConfirm(BuildContext context) {
    showConfirmDialog(context, "ต้องการลบรายการใช่หรือไม่?", () {
      _viewModel.removeOrderById(widget.orderId);
    });
  }

  _showRemoveOrderItemConfirm(BuildContext context, OrderItemDetail orderItem) {
    showConfirmDialog(context, "ต้องการลบสินค้าใช่หรือไม่?", () {
      _viewModel.removeOrderItem(orderItem.id);
    });
  }

  _nextToProductEdit(BuildContext context, Product? product) async {
    if (product != null) {
      var result = await Navigator.pushNamed(context, PRODUCT_EDIT_ROUTE, arguments: ProductArgument(product));
      if (result != null) {
        _viewModel.getOrderById(widget.orderId);
      }
    }
  }

  _nextToOrderHistory(BuildContext context, Product? product) async {
    if (product != null) {
      var result = await Navigator.pushNamed(context, ORDER_HISTORY_ROUTE, arguments: OrderHistoryArgument(product));
      if (result != null) {
        _viewModel.getOrderById(widget.orderId);
      }
    }
  }

  _generateReceipt(Supplier supplier) async {
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

  _nextToSupplier(BuildContext context) async {
    var _ = await Navigator.pushNamed(context, SUPPLIER_ROUTE);
  }

  _showCustomerDialog(Supplier supplier, Customer? customer) {
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

  _getCustomer() {
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
