// Flutter imports:
import 'package:common/core/widgets/appbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:common/core/widgets/custom_snack_bar.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:pos/container.dart';
import 'package:pos/domain/model/order/order_item_detail.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/localizations/language/languages.dart';
import 'package:pos/presentation/constants.dart';
import 'package:pos/presentation/order/core/export_csv.dart';
import 'package:pos/presentation/theme.dart';
import 'order_history_state.dart';
import 'order_history_view_model.dart';

class OrderHistoryPage extends StatefulWidget {
  final Product product;

  const OrderHistoryPage({
    super.key,
    required this.product,
  });

  @override
  State<StatefulWidget> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _format = NumberFormat("#,##0.00", "en_US");

  late CustomSnackBar _snackBar;
  late OrderHistoryViewModel _viewModel;

  double change = 0;

  bool isAdmin = true;
  List<OrderItemDetail> orderItems = [];

  @override
  void initState() {
    super.initState();
    _viewModel = sl<OrderHistoryViewModel>();
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
      } else if (state is OrderItemState) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _snackBar.hideAll();
        });
        setState(() {
          orderItems = state.items;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.getOrderItemByProductId(widget.product.id);
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _snackBar = CustomSnackBar(key: const Key("snackbar"), context: context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: buildAppBar(
        Languages.of(context).orderHistoryTitle,
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

  Widget _buildBody(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height,
      width: size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 50,
            padding: const EdgeInsets.only(left: defaultPagePadding),
            alignment: Alignment.centerLeft,
            child: Text(
              widget.product.name,
              textAlign: TextAlign.justify,
            ),
          ),
          _buildOrderItem(context),
          _buildSummaryTotal(),
        ],
      ),
    );
  }

  _buildAction(BuildContext context) {
    return <Widget>[
      IconButton(
        splashRadius: 20,
        onPressed: () {
          ExportCsv.downloadOrderItems(widget.product, orderItems);
        },
        icon: const Icon(Icons.download),
      ),
    ];
  }

  _buildOrderItem(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: orderItems.length,
        itemBuilder: (context, index) {
          final item = orderItems[index];
          final customerName = item.order?.customerName ?? "";
          return ListTile(
            leading: Text(
              '${item.quantity}',
            ),
            title: Text(item.getCreatedDate() + (customerName.isNotEmpty ? " Name: $customerName" : "")),
            trailing: Text(_format.format(item.price)),
            subtitle: Text("Cost: ${_format.format(item.costPrice)}  Profit: ${_format.format(item.price - item.costPrice)}"),
          );
        },
      ),
    );
  }

  _buildSummaryTotal() {
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
          '฿ ${_format.format(getTotalPrice())}',
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
            '฿ ${_format.format(getTotalCostPrice())}',
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
            '฿ ${_format.format(getTotalPrice() - getTotalCostPrice())}',
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  double getTotalPrice() {
    double price = 0;
    for (var x in orderItems) {
      price += x.price;
    }
    return price;
  }

  double getTotalCostPrice() {
    double price = 0;
    for (var x in orderItems) {
      price += x.costPrice;
    }
    return price;
  }
}
