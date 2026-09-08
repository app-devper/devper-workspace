// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:design_system/widgets/app_bar.dart';
import 'package:design_system/widgets/snack_bar.dart';

// Project imports:
import 'package:pos/container.dart';
import 'package:pos/domain/model/supplier/supplier.dart';
import 'package:pos/localizations/language/languages.dart';
import 'package:pos/presentation/constants.dart';
import 'package:pos/presentation/supplier/argument.dart';
import 'package:pos/presentation/supplier/main/suppliers_state.dart';
import 'package:pos/presentation/supplier/main/suppliers_view_model.dart';
import 'package:design_system/theme/color.dart';

class SuppliersPage extends StatefulWidget {
  const SuppliersPage({super.key});

  @override
  State<StatefulWidget> createState() => _SuppliersPageState();
}

class _SuppliersPageState extends State<SuppliersPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  late CustomSnackBar _snackBar;
  late SuppliersViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<SuppliersViewModel>();
    _viewModel.state.addListener(_onStateChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.getSuppliers();
    });
  }

  void _onStateChanged() {
    final error = _viewModel.state.value.error;
    if (error != null) {
      _snackBar.hideAll();
      _snackBar.showErrorSnackBar(error);
      _viewModel.consumeError();
    }
  }

  @override
  void dispose() {
    _viewModel.state.removeListener(_onStateChanged);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _snackBar = CustomSnackBar(key: const Key("snackbar"), context: context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: buildAppBar(
        Languages.of(context).suppliersTitle,
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
          _nextToSupplierAdd(context);
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
          _buildSupplierList(),
        ],
      ),
    );
  }

  ValueListenableBuilder<SuppliersState> _buildSupplierList() {
    return ValueListenableBuilder<SuppliersState>(
      valueListenable: _viewModel.state,
      builder: (BuildContext context, SuppliersState state, _) {
        if (state.loading && state.items.isEmpty) {
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
        return _buildCustomer(state.items);
      },
    );
  }

  Expanded _buildCustomer(List<Supplier> item) {
    return Expanded(
      child: ListView.builder(
        itemCount: item.length,
        itemBuilder: (context, index) {
          final content = item[index];
          return ListTile(
            title: Text(content.name),
            subtitle: Text(content.phone),
            onTap: () {
              _nextToSupplierEdit(context, content);
            },
          );
        },
      ),
    );
  }

  Future<void> _nextToSupplierEdit(BuildContext context, Supplier content) async {
    var _ = await Navigator.pushNamed(context, supplierEditRoute, arguments: SupplierArgument(content));
    _viewModel.getSuppliers();
  }

  Future<void> _nextToSupplierAdd(BuildContext context) async {
    var _ = await Navigator.pushNamed(context, supplierAddRoute);
    _viewModel.getSuppliers();
  }
}
