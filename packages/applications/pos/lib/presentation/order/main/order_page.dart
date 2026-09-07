// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:design_system/widgets/app_bar.dart';
import 'package:design_system/widgets/snack_bar.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:pos/container.dart';
import 'package:pos/domain/model/order/order_summary.dart';
import 'package:pos/domain/model/order/param.dart';
import 'package:pos/localizations/language/languages.dart';
import 'package:pos/presentation/constants.dart';
import 'package:pos/presentation/order/argument.dart';
import 'package:design_system/theme/color.dart';
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

  Range _value = Range.today;
  double _totalCost = 0;
  double _total = 0;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<OrderViewModel>();
    _viewModel.state.addListener(_onStateChanged);
    _viewModel.checkLogin();
  }

  void _onStateChanged() {
    final state = _viewModel.state.value;
    if (state.error != null) {
      final message = state.error!;
      _viewModel.consumeError();
      _snackBar.hideAll();
      _snackBar.showErrorSnackBar(message);
    }
    setState(() {
      _totalCost = state.totalCost;
      _total = state.total;
    });
    if (state.logged != null) {
      final isAdmin = state.logged!;
      _viewModel.consumeLogged();
      setState(() {
        _isAdmin = isAdmin;
      });
      _viewModel.initData();
    }
    if (state.initialized) {
      _viewModel.consumeInitialized();
      _viewModel.selectRange(_value);
    }
    final selection = state.rangeSelection;
    if (selection != null) {
      _viewModel.consumeRangeSelection();
      if (selection.range == Range.dateRange) {
        _selectRangeDate(selection.startDate, selection.range);
      } else if (selection.range == Range.date) {
        _selectDate(_startDate, selection.range);
      } else {
        setState(() {
          _startDate = selection.startDate;
          _endDate = selection.endDate;
          _value = selection.range;
        });
        _viewModel.getOrderItem(_choices[_defaultChoiceIndex], _getOrderRangeParam());
      }
    }
  }

  @override
  void dispose() {
    _viewModel.state.removeListener(_onStateChanged);
    _viewModel.dispose();
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
        appBar: buildAppBar(
            Languages.of(context).ordersTitle,
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
    return ValueListenableBuilder<OrderState>(
      valueListenable: _viewModel.state,
      builder: (BuildContext context, OrderState state, _) {
        final data = state.ranges;
        if (data.isNotEmpty && _isAdmin) {
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
                    _viewModel.selectRange(value as Range);
                  },
                ),
              ),
              _buildDate(),
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

  _buildMenu(BuildContext context) {
    if (_isAdmin) {
      return Container(
        padding: const EdgeInsets.only(right: defaultPagePadding, left: defaultPagePadding),
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
    if (_value == Range.today || _value == Range.yesterday || _value == Range.date) {
      return Row(
        children: <Widget>[
          Text(
            _dateFormat.format(_startDate),
            style: const TextStyle(fontSize: 14.0, color: CustomColor.fontBlack),
          ),
        ],
      );
    } else if (_value == Range.currentMonth || _value == Range.month || _value == Range.lastMonth) {
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
    return ValueListenableBuilder<OrderState>(
      valueListenable: _viewModel.state,
      builder: (BuildContext context, OrderState state, _) {
        final orders = state.orders;
        if (orders != null) {
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
      padding: const EdgeInsets.all(defaultPagePadding),
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
        const Text(
          'Total',
        ),
        Text(
          '฿ ${_format.format(_total)}',
        ),
      ],
    );
  }

  _buildTotalCost() {
    if (_isAdmin) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const Text(
            'Total Cost',
          ),
          Text(
            '฿ ${_format.format(_totalCost)}',
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
          const Text(
            'Total Profit',
          ),
          Text(
            '฿ ${_format.format(_total - _totalCost)}',
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
    var _ = await Navigator.pushNamed(context, orderDetailRoute, arguments: OrderArgument(content.id));
    _viewModel.getOrderItem(_choices[_defaultChoiceIndex], _getOrderRangeParam());
  }
}
