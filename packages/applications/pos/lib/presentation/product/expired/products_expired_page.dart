// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:common/core/widgets/appbar_widget.dart';
import 'package:common/core/widgets/custom_snack_bar.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:pos/container.dart';
import 'package:pos/domain/model/product/product_lot.dart';
import 'package:pos/localizations/language/languages.dart';
import 'package:pos/presentation/constants.dart';
import 'package:pos/presentation/product/argument.dart';
import 'package:pos/presentation/product/expired/products_expired_state.dart';
import 'package:pos/presentation/product/expired/products_expired_view_model.dart';
import 'package:pos/presentation/theme.dart';
import 'products_expire_ui_model.dart';

class ProductsExpiredPage extends StatefulWidget {
  const ProductsExpiredPage({super.key});

  @override
  State<StatefulWidget> createState() => _ProductsExpiredPageState();
}

class _ProductsExpiredPageState extends State<ProductsExpiredPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _format = NumberFormat("#,##0.00", "en_US");

  late CustomSnackBar _snackBar;
  late ProductsExpiredViewModel _viewModel;

  double _totalCost = 0;

  Range _value = Range.before180Days;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<ProductsExpiredViewModel>();
    _viewModel.states.listen((state) {
      if (state is ErrorState) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _snackBar.hideAll();
          _snackBar.showErrorSnackBar(state.message);
        });
      } else if (state is LoadingState) {
      } else if (state is ListExpiresState) {
        _viewModel.setProductLots(state.data);
        setState(() {
          _totalCost = state.totalCost;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.initData();
      _viewModel.selectRange(_value);
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
          Languages.of(context).productsExpiredTitle,
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height,
      width: size.width,
      child: Column(
        children: <Widget>[
          _buildMenu(),
          _buildReceiveList(),
          _buildTotalCost(),
        ],
      ),
    );
  }

  _buildMenu() {
    return Container(
      padding: const EdgeInsets.only(right: defaultPagePadding, left: defaultPagePadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          _buildDropdown(),
        ],
      ),
    );
  }

  _buildDropdown() {
    return StreamBuilder(
      stream: _viewModel.dropdownItem.stream,
      builder: (BuildContext context, AsyncSnapshot<List<ListItem>> snapshot) {
        if (snapshot.hasData) {
          var data = snapshot.data ?? [];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              SizedBox(
                height: 40,
                child: DropdownButton(
                  value: _value,
                  alignment: AlignmentDirectional.center,
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: CustomColor.fontBlack,
                  ),
                  items: data.map((ListItem item) {
                    return DropdownMenuItem<Range>(
                      value: item.value,
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 14.0,
                          color: CustomColor.fontBlack,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _value = value!;
                    });
                    _viewModel.selectRange(value as Range);
                  },
                ),
              ),
            ],
          );
        } else {
          return Container(
            height: 50,
          );
        }
      },
    );
  }

  _buildReceiveList() {
    return StreamBuilder(
      stream: _viewModel.lots,
      builder: (BuildContext context, AsyncSnapshot<List<ProductLot>> snapshot) {
        if (snapshot.hasData) {
          var data = snapshot.data ?? [];
          return _buildProductLots(data);
        } else {
          return const Expanded(
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 6,
                color: CustomColor.primary,
                strokeCap: StrokeCap.round,
              ),
            ),
          );
        }
      },
    );
  }

  _buildProductLots(List<ProductLot> items) {
    return Expanded(
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final data = items[index];
          return ListTile(
            leading: Text("${index + 1}"),
            title: Text(data.getExpireDate() + ("  Name: ${data.product?.name ?? "-"}")),
            subtitle: Text("Lot: ${data.lotNumber}  Quantity: ${data.quantity}  Cost: ${_format.format(data.costPrice)}"),
            trailing: Text(_format.format(data.costPrice * data.quantity)),
            onTap: () {
              _nextToProductLotEdit(context, data);
            },
          );
        },
      ),
    );
  }

  _buildTotalCost() {
    return Container(
      padding: const EdgeInsets.all(defaultPagePadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const Text(
            'Total Cost',
          ),
          Text(
            '฿ ${_format.format(_totalCost)}',
          ),
        ],
      ),
    );
  }

  _nextToProductLotEdit(BuildContext context, ProductLot content) async {
    var _ = await Navigator.pushNamed(context, PRODUCT_LOT_EDIT_ROUTE, arguments: ProductLotArgument(content));
    _viewModel.selectRange(_value);
  }
}
