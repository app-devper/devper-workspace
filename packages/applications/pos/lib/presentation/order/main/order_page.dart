// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:common/core/ext/widget_ext.dart';
import 'package:common/core/widgets/custom_snack_bar.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:pos/container.dart';
import 'package:pos/domain/model/order/order_summary.dart';
import 'package:pos/domain/model/order/param.dart';
import 'package:pos/localizations/language/languages.dart';
import 'package:pos/presentation/constants.dart';
import 'package:pos/presentation/order/argument.dart';
import 'package:pos/presentation/theme.dart';
import 'order_state.dart';
import 'order_ui_model.dart';
import 'order_view_model.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<StatefulWidget> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _format = NumberFormat("#,##0.00", "en_US");
  final _dateFormat = DateFormat("MMM dd");
  final _mountFormat = DateFormat("MMM");

  final _choices = ['All', 'Store', 'Online'];
  int _defaultChoiceIndex = 0;

  final _viewNode = FocusNode();

  late CustomSnackBar _snackBar;
  late OrderViewModel _viewModel;

  late DateTime _startDate = DateTime.now();

  late DateTime _endDate;

  bool _isAdmin = false;

  Range _value = Range.Today;
  double _totalCost = 0;
  double _total = 0;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<OrderViewModel>();
    _viewModel.states.stream.listen((state) {
      if (state is ErrorState) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _snackBar.hideAll();
          _snackBar.showErrorSnackBar(state.message);
        });
      } else if (state is LoadingState) {
        showLoadingDialog(context);
      } else if (state is OrderSummaryState) {
        setState(() {
          _totalCost = state.totalCost;
          _total = state.total;
        });
      } else if (state is LoggedState) {
        setState(() {
          _isAdmin = state.isAdmin;
          _defaultChoiceIndex = state.isAdmin ? 0 : 1;
        });
        _viewModel.initData();
      } else if (state is OrderRangeState) {
        if (state.range == Range.DateRange) {
          _selectRangeDate(state.startDate, state.range);
        } else if (state.range == Range.Date) {
          _selectDate(_startDate, state.range);
        } else {
          setState(() {
            _startDate = state.startDate;
            _endDate = state.endDate;
            _value = state.range;
          });
          _viewModel.getOrderItem(_choices[_defaultChoiceIndex], _getOrderRangeParam());
        }
      } else if (state is InitState) {
        _viewModel.selectRange(_value);
      }
    });

    _viewModel.checkLogin();
  }

  @override
  void dispose() {
    _viewNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _snackBar = CustomSnackBar(key: const Key("snackbar"), context: context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(_viewNode),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          iconTheme: CustomTheme.mainTheme.iconTheme,
          backgroundColor: CustomColor.white,
          centerTitle: true,
          title: Text(
            Languages.of(context).ordersTitle,
            style: CustomTheme.mainTheme.textTheme.headlineSmall,
          ),
        ),
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: CustomColor.statusBarColor,
          ),
          child: _buildBody(context),
        ),
      ),
    );
  }

  _buildBody(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height,
      width: size.width,
      child: Column(
        children: <Widget>[
          _buildMenu(context),
          _buildOrderList(),
          _buildSummaryTotal(),
        ],
      ),
    );
  }

  _buildDropdown(BuildContext context) {
    return StreamBuilder(
      stream: _viewModel.dropdownItem.stream,
      builder: (BuildContext context, AsyncSnapshot<List<ListItem>> snapshot) {
        if (snapshot.hasData && _isAdmin) {
          var data = snapshot.data ?? [];
          return Container(
            child: Column(
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
                      _viewModel.selectRange(value as Range);
                    },
                  ),
                ),
                _buildDate(),
              ],
            ),
          );
        } else {
          return Container(
            height: 50,
          );
        }
      },
    );
  }

  _buildMenu(BuildContext context) {
    if (_isAdmin) {
      return Container(
        padding: const EdgeInsets.only(right: DEFAULT_PAGE_PADDING, left: DEFAULT_PAGE_PADDING),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _buildFilter(),
            _buildDropdown(context),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  _buildDate() {
    if (_value == Range.Today || _value == Range.Yesterday || _value == Range.Date) {
      return Row(
        children: <Widget>[
          Text(
            _dateFormat.format(_startDate),
            style: const TextStyle(fontSize: 14.0, color: CustomColor.fontBlack),
          ),
        ],
      );
    } else if (_value == Range.CurrentMonth || _value == Range.Month || _value == Range.LastMonth) {
      return Row(
        children: <Widget>[
          Text(
            _mountFormat.format(_startDate),
            style: const TextStyle(fontSize: 14.0, color: CustomColor.fontBlack),
          ),
        ],
      );
    } else {
      return Row(
        children: <Widget>[
          Text(
            _dateFormat.format(_startDate),
            style: const TextStyle(fontSize: 14.0, color: CustomColor.fontBlack),
          ),
          const Text(
            " - ",
            style: TextStyle(fontSize: 14.0, color: CustomColor.fontBlack),
          ),
          Text(
            _dateFormat.format(_endDate.subtract(const Duration(days: 1))),
            style: const TextStyle(fontSize: 14.0, color: CustomColor.fontBlack),
          ),
        ],
      );
    }
  }

  _buildFilter() {
    return Wrap(
      spacing: 8,
      children: List.generate(_choices.length, (index) {
        return ChoiceChip(
          label: Text(_choices[index]),
          labelStyle: const TextStyle(color: Colors.white),
          selected: _defaultChoiceIndex == index,
          selectedColor: CustomColor.primary,
          backgroundColor: Colors.grey,
          onSelected: (value) {
            setState(() {
              _defaultChoiceIndex = value ? index : _defaultChoiceIndex;
            });
            _viewModel.getOrderItem(_choices[_defaultChoiceIndex], _getOrderRangeParam());
          },
          elevation: 1,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
        );
      }),
    );
  }

  _buildOrderList() {
    return StreamBuilder(
      stream: _viewModel.orders.stream,
      builder: (BuildContext context, AsyncSnapshot<List<OrderSummary>> snapshot) {
        if (snapshot.hasData) {
          var orders = snapshot.data ?? [];
          return Expanded(
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final item = orders[index];
                return ListTile(
                  leading: Text("${index + 1}"),
                  title: Text(item.getCreatedDate() + (item.customerName.isNotEmpty ? " Name: ${item.customerName}" : "")),
                  trailing: Text(_format.format(item.total)),
                  subtitle: _isAdmin ? Text("Cost: ${_format.format(item.totalCost)}  Profit: ${_format.format(item.total - item.totalCost)}") : null,
                  onTap: () {
                    _nextToOrderDetail(context, item);
                  },
                );
              },
            ),
          );
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

  _buildSummaryTotal() {
    return Container(
      padding: const EdgeInsets.all(DEFAULT_PAGE_PADDING),
      child: Column(
        children: <Widget>[
          _buildTotal(),
          _buildTotalCost(),
          _buildTotalProfit(),
        ],
      ),
    );
  }

  _buildTotal() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          'Total',
          style: CustomTheme.mainTheme.textTheme.headlineSmall,
        ),
        Text(
          '฿ ${_format.format(_total)}',
          style: CustomTheme.mainTheme.textTheme.headlineSmall,
        ),
      ],
    );
  }

  _buildTotalCost() {
    if (_isAdmin) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'Total Cost',
            style: CustomTheme.mainTheme.textTheme.headlineSmall,
          ),
          Text(
            '฿ ${_format.format(_totalCost)}',
            style: CustomTheme.mainTheme.textTheme.headlineSmall,
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  _buildTotalProfit() {
    if (_isAdmin) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'Total Profit',
            style: CustomTheme.mainTheme.textTheme.headlineSmall,
          ),
          Text(
            '฿ ${_format.format(_total - _totalCost)}',
            style: CustomTheme.mainTheme.textTheme.headlineSmall,
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  _selectRangeDate(DateTime currentDate, Range range) async {
    final DateTimeRange? result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2021, 1, 1),
      lastDate: currentDate,
      currentDate: currentDate,
      saveText: 'Done',
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );

    if (result != null) {
      setState(() {
        _startDate = result.start;
        _endDate = result.end.add(const Duration(days: 1));
        _value = range;
      });
      _viewModel.getOrderItem(_choices[_defaultChoiceIndex], _getOrderRangeParam());
    }
  }

  _selectDate(DateTime currentDate, Range range) async {
    final DateTime? result = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2021, 1, 1),
      lastDate: DateTime.now(),
      currentDate: currentDate,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (result != null) {
      setState(() {
        _startDate = result;
        _endDate = result.add(const Duration(days: 1));
        _value = range;
      });
      _viewModel.getOrderItem(_choices[_defaultChoiceIndex], _getOrderRangeParam());
    }
  }

  _getOrderRangeParam() {
    return GetOrderRangeParam(
      startDate: _startDate.toUtc().toIso8601String(),
      endDate: _endDate.toUtc().toIso8601String(),
    );
  }

  _nextToOrderDetail(BuildContext context, OrderSummary content) async {
    var _ = await Navigator.pushNamed(context, ORDER_DETAIL_ROUTE, arguments: OrderArgument(content.id));
    _viewModel.getOrderItem(_choices[_defaultChoiceIndex], _getOrderRangeParam());
  }
}
