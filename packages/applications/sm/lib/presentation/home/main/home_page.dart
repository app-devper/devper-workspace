// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:common/config/app_config.dart';
import 'package:design_system/theme/color.dart';
import 'package:design_system/theme/theme.dart';
import 'package:design_system/widgets/snack_bar.dart';
import 'package:um/presentation/constants.dart';

// Project imports:
import 'package:sm/container.dart';
import 'package:sm/domain/model/system/system.dart';
import 'package:sm/presentation/home/main/home_state.dart';
import 'package:sm/presentation/home/main/home_view_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  late HomeViewModel _viewModel;
  late AppConfig _config;
  late CustomSnackBar _snackBar;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    _viewModel = sl<HomeViewModel>();
    _config = sl<AppConfig>();
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
      } else if (state is SystemState) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _snackBar.hideAll();
          _snackBar.showLoadingSnackBar();
        });
      } else if (state is LoggedState) {
      } else if (state is LogoutState) {
        Navigator.popAndPushNamed(context, routeLogin);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.getSystems();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _viewModel.checkLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        iconTheme: CustomTheme.mainTheme.iconTheme,
        backgroundColor: CustomColor.white,
        centerTitle: true,
        title: Text(_config.home),
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
    return [
      PopupMenuButton<int>(
        icon: const Icon(Icons.more_vert),
        onSelected: (item) => handleClick(item),
        itemBuilder: (context) => [
          const PopupMenuItem<int>(value: 0, child: Text("User info")),
          const PopupMenuItem<int>(value: 1, child: Text("Change password")),
          const PopupMenuItem<int>(value: 3, child: Text('Logout')),
        ],
      ),
    ];
  }

  void handleClick(int item) {
    switch (item) {
      case 0:
        Navigator.pushNamed(context, routeUserInfo);
        break;
      case 1:
        Navigator.pushNamed(context, routeChangePassword);
        break;
      case 3:
        _viewModel.logout();
        break;
    }
  }

  Widget _buildBody(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Container(
      height: size.height,
      width: size.width,
      padding: const EdgeInsets.all(defaultPagePadding),
      child: Column(
        children: <Widget>[
          _buildSystemList(),
        ],
      ),
    );
  }

  _buildSystemList() {
    return StreamBuilder(
        stream: _viewModel.systems.stream,
        builder: (BuildContext context, AsyncSnapshot<List<System>> snapshot) {
          if (snapshot.hasData) {
            var data = snapshot.data ?? [];
            return _buildSystems(data);
          } else {
            return const Expanded(
              child: Center(child: CircularProgressIndicator()),
            );
          }
        });
  }

  _buildSystems(List<System> item) {
    return Expanded(
      child: ListView.builder(
        itemCount: item.length,
        itemBuilder: (context, index) {
          final content = item[index];
          return ListTile(
            title: Text(content.systemCode),
            subtitle: Text(content.systemName),
            trailing: Text(content.clientId),
            onTap: () {},
          );
        },
      ),
    );
  }
}
