// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:common/core/widgets/custom_snack_bar.dart';

// Project imports:
import 'package:pos/container.dart';
import 'package:pos/domain/model/customer/customer.dart';
import 'package:pos/localizations/language/languages.dart';
import 'package:pos/presentation/constants.dart';
import 'package:pos/presentation/customer/argument.dart';
import 'package:pos/presentation/customer/main/customer_state.dart';
import 'package:pos/presentation/customer/main/customer_view_model.dart';
import 'package:pos/presentation/theme.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  State<StatefulWidget> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  late CustomSnackBar _snackBar;
  late CustomerViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<CustomerViewModel>();
    _viewModel.states.listen((state) {
      if (state is ErrorState) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _snackBar.hideAll();
          _snackBar.showErrorSnackBar(state.message);
        });
      } else if (state is LoadingState) {
      } else if (state is ListCustomerState) {
        _viewModel.setCustomers(state.data);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.getCustomers();
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
      appBar: AppBar(
        iconTheme: CustomTheme.mainTheme.iconTheme,
        backgroundColor: CustomColor.white,
        centerTitle: true,
        title: Text(
          Languages.of(context).customerTitle,
          style: CustomTheme.mainTheme.textTheme.headlineSmall,
        ),
        actions: _buildAction(context),
      ),
      body: _buildBody(context),
    );
  }

  List<Widget> _buildAction(BuildContext context) {
    return [
      IconButton(
        splashRadius: 20,
        onPressed: () {
          _nextToCustomerAdd(context);
        },
        icon: const Icon(Icons.add),
      ),
    ];
  }

  Widget _buildBody(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height,
      width: size.width,
      child: Column(
        children: <Widget>[
          _buildCustomerList(),
        ],
      ),
    );
  }

  _buildCustomerList() {
    return StreamBuilder(
      stream: _viewModel.customers,
      builder: (BuildContext context, AsyncSnapshot<List<Customer>> snapshot) {
        if (snapshot.hasData) {
          var data = snapshot.data ?? [];
          return _buildCustomer(data);
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

  _buildCustomer(List<Customer> item) {
    return Expanded(
      child: ListView.builder(
        itemCount: item.length,
        itemBuilder: (context, index) {
          final content = item[index];
          return ListTile(
            title: Text(content.name),
            subtitle: Text(content.code),
            onTap: () {
              _nextToCustomerEdit(context, content);
            },
          );
        },
      ),
    );
  }

  _nextToCustomerEdit(BuildContext context, Customer content) async {
    var result = await Navigator.pushNamed(context, CUSTOMER_EDIT_ROUTE, arguments: CustomerArgument(content));
    _viewModel.getCustomers();
  }

  _nextToCustomerAdd(BuildContext context) async {
    var result = await Navigator.pushNamed(context, CUSTOMER_ADD_ROUTE);
    _viewModel.getCustomers();
  }
}
