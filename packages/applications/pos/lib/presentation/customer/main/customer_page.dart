// Flutter imports:
import 'package:common/core/widgets/responsive.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:pos/container.dart';
import 'package:pos/domain/model/customer/customer.dart';
import 'package:pos/presentation/customer/add/customer_add_page.dart';
import 'package:pos/presentation/customer/edit/customer_edit_page.dart';
import 'package:pos/presentation/customer/main/customer_detail_widget.dart';
import 'package:pos/presentation/customer/main/customer_menu_widget.dart';
import 'package:pos/presentation/customer/main/customer_state.dart';
import 'package:pos/presentation/customer/main/customer_view_model.dart';
import 'package:pos/presentation/customer/main/customers_widget.dart';

class CustomerPage extends StatefulWidget {
  final Function() onBack;

  const CustomerPage({super.key, required this.onBack});

  @override
  State<StatefulWidget> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  late CustomerViewModel _viewModel;
  PageState _pageState = MainPage();

  @override
  void initState() {
    super.initState();
    _viewModel = sl<CustomerViewModel>();
    _viewModel.states.listen((state) {
      if (state is GetCustomerState) {
        setState(() {
          _pageState = InfoPage(data: state.data);
        });
      }
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Responsive(mobile: _buildMobile(), desktop: _buildDesktop());
  }

  _buildDesktop() {
    return Row(
      children: [
        SizedBox(
          width: 320,
          child: CustomersWidget(
            onAdd: () {
              setState(() {
                _pageState = AddPage();
              });
            },
            onSelected: (value) {
              _viewModel.getCustomerById(value.id);
            },
            onBack: () {
              widget.onBack();
            },
          ),
        ),
        Container(width: 1, color: Colors.grey[200]),
        Expanded(
          child: _buildPage(),
        ),
      ],
    );
  }

  _buildMobile() {
    return Row(
      children: [
        Expanded(
          child: _buildPage(),
        ),
      ],
    );
  }

  _buildPage() {
    if (_pageState is MainPage) {
      final isMobile = Responsive.isMobile(context);
      if (isMobile) {
        return CustomersWidget(
          onAdd: () {
            setState(() {
              _pageState = AddPage();
            });
          },
          onSelected: (value) {
            _viewModel.getCustomerById(value.id);
          },
          onBack: () {
            widget.onBack();
          },
        );
      } else {
        return CustomerMenuWidget(
          onAdd: () {
            setState(() {
              _pageState = AddPage();
            });
          },
          onExport: () {},
        );
      }
    } else if (_pageState is InfoPage) {
      final customer = (_pageState as InfoPage).data;
      return CustomerDetailWidget(
        onEdit: () {
          _viewModel.getCustomerById(customer.id);
        },
        customer: customer,
        onBack: () {
          setState(() {
            _pageState = MainPage();
          });
        },
        onClickEdit: () {
          setState(() {
            _pageState = EditPage(data: customer);
          });
        },
      );
    } else if (_pageState is EditPage) {
      final customer = (_pageState as EditPage).data;
      return CustomerEditPage(
        customer: customer,
        onBack: () {
          setState(() {
            _pageState = InfoPage(data: customer);
          });
        },
        onEdit: () {
          _viewModel.getCustomerById(customer.id);
        },
        onRemove: () {
          setState(() {
            _pageState = MainPage();
          });
        },
      );
    } else if (_pageState is AddPage) {
      return CustomerAddPage(
        onBack: () {
          setState(() {
            _pageState = MainPage();
          });
        },
        onAdd: () {
          setState(() {
            _pageState = MainPage();
          });
        },
      );
    }
  }
}

abstract class PageState {}

class MainPage extends PageState {}

class AddPage extends PageState {}

class InfoPage extends PageState {
  final Customer data;

  InfoPage({
    required this.data,
  });
}

class EditPage extends PageState {
  final Customer data;

  EditPage({
    required this.data,
  });
}
