// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:common/core/widgets/appbar_widget.dart';
import 'package:common/core/widgets/custom_snack_bar.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:pos/container.dart';
import 'package:pos/domain/model/receive/receive.dart';
import 'package:pos/localizations/language/languages.dart';
import 'package:pos/presentation/constants.dart';
import 'package:pos/presentation/receive/argument.dart';
import 'package:pos/presentation/receive/main/receives_state.dart';
import 'package:pos/presentation/receive/main/receives_view_model.dart';
import 'package:pos/presentation/theme.dart';

class ReceivesPage extends StatefulWidget {
  const ReceivesPage({super.key});

  @override
  State<StatefulWidget> createState() => _ReceivesPageState();
}

class _ReceivesPageState extends State<ReceivesPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _format = NumberFormat("#,##0.00", "en_US");

  late CustomSnackBar _snackBar;
  late ReceivesViewModel _viewModel;

  double _totalCost = 0;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<ReceivesViewModel>();
    _viewModel.states.listen((state) {
      if (state is ErrorState) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _snackBar.hideAll();
          _snackBar.showErrorSnackBar(state.message);
        });
      } else if (state is LoadingState) {
      } else if (state is ListReceiveState) {
        _viewModel.setReceives(state.data);
        setState(() {
          _totalCost = state.totalCost;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.getReceives();
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
        Languages.of(context).receivesTitle,
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
          _nextToReceiveAdd(context);
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
        children: <Widget>[_buildReceiveList(), _buildTotalCost()],
      ),
    );
  }

  _buildReceiveList() {
    return StreamBuilder(
      stream: _viewModel.receives,
      builder: (BuildContext context, AsyncSnapshot<List<Receive>> snapshot) {
        if (snapshot.hasData) {
          var data = snapshot.data ?? [];
          return _buildReceives(data);
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

  _buildReceives(List<Receive> item) {
    return Expanded(
      child: ListView.builder(
        itemCount: item.length,
        itemBuilder: (context, index) {
          final content = item[index];
          return ListTile(
            leading: Text("${index + 1}"),
            title: Text(content.getCreatedDate() + ("  ร้าน: ${content.supplier?.name ?? "-"}")),
            subtitle: Text(content.code + ("  Ref: ${content.reference}")),
            trailing: Text(_format.format(content.totalCost)),
            onTap: () {
              _nextToReceiveManage(context, content);
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

  _nextToReceiveManage(BuildContext context, Receive content) async {
    var _ = await Navigator.pushNamed(context, RECEIVE_MANAGE_ROUTE, arguments: ReceiveManageArgument(content.id));
    _viewModel.getReceives();
  }

  _nextToReceiveAdd(BuildContext context) async {
    var _ = await Navigator.pushNamed(context, RECEIVE_MANAGE_ROUTE);
    _viewModel.getReceives();
  }
}
