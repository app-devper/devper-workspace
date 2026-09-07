// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:design_system/widgets/app_bar.dart';
import 'package:design_system/widgets/snack_bar.dart';

// Project imports:
import 'package:pos/container.dart';
import 'package:pos/domain/model/stock_count/stock_count.dart';
import 'package:pos/localizations/language/languages.dart';
import 'package:pos/presentation/constants.dart';
import 'package:pos/presentation/stock_count/argument.dart';
import 'package:pos/presentation/stock_count/main/stock_counts_state.dart';
import 'package:pos/presentation/stock_count/main/stock_counts_view_model.dart';
import 'package:design_system/theme/color.dart';

class StockCountsPage extends StatefulWidget {
  const StockCountsPage({super.key});

  @override
  State<StatefulWidget> createState() => _StockCountsPageState();
}

class _StockCountsPageState extends State<StockCountsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  late CustomSnackBar _snackBar;
  late StockCountsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<StockCountsViewModel>();
    _viewModel.state.addListener(_onStateChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.getStockCounts();
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
        Languages.of(context).stockCountsTitle,
        actions: [
          IconButton(
            splashRadius: 20,
            onPressed: () {
              _nextToStockCountManage(context);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return ValueListenableBuilder<StockCountsState>(
      valueListenable: _viewModel.state,
      builder: (BuildContext context, StockCountsState state, _) {
        if (state.loading && state.items.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 6,
              color: CustomColor.primary,
              strokeCap: StrokeCap.round,
            ),
          );
        }
        if (state.items.isEmpty) {
          return const Center(
            child: Text(
              'ยังไม่มีการนับสต็อก',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }
        return _buildStockCounts(state.items);
      },
    );
  }

  Widget _buildStockCounts(List<StockCount> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final content = items[index];
        return Column(children: [
          ListTile(
            title: Text(content.countNo),
            subtitle: Text(
              "รายการ: ${content.items.length}, วันที่: ${content.getCreatedDate()}",
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            onTap: () {
              _nextToStockCountManage(context, stockCountId: content.id);
            },
          ),
          const Divider(height: 1),
        ]);
      },
    );
  }

  _nextToStockCountManage(BuildContext context, {String? stockCountId}) async {
    var _ = await Navigator.pushNamed(
      context,
      stockCountManageRoute,
      arguments: StockCountManageArgument(stockCountId),
    );
    _viewModel.getStockCounts();
  }
}
