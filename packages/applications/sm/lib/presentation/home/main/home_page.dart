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
import 'package:sm/presentation/home/main/system_form_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  late HomeViewModel _viewModel;
  late AppConfig _config;
  late CustomSnackBar _snackBar;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<HomeViewModel>();
    _config = sl<AppConfig>();
    _viewModel.state.addListener(_onStateChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadRole();
      _viewModel.getSystems();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _snackBar = CustomSnackBar(key: const Key("snackbar"), context: context);
  }

  @override
  void dispose() {
    _viewModel.state.removeListener(_onStateChanged);
    _viewModel.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    final state = _viewModel.state.value;
    if (state.error != null) {
      _snackBar.hideAll();
      _snackBar.showErrorSnackBar(state.error!);
      _viewModel.consumeError();
    }
    if (state.loggedOut && mounted) {
      Navigator.popAndPushNamed(context, routeLogin);
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
      floatingActionButton: ValueListenableBuilder<HomeState>(
        valueListenable: _viewModel.state,
        builder: (context, state, _) => state.canManageSystems
            ? FloatingActionButton(
                onPressed: () => _openForm(),
                tooltip: 'เพิ่มระบบ',
                child: const Icon(Icons.add),
              )
            : const SizedBox.shrink(),
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
      ValueListenableBuilder<HomeState>(
        valueListenable: _viewModel.state,
        builder: (context, state, _) => PopupMenuButton<int>(
          icon: const Icon(Icons.more_vert),
          onSelected: (item) => handleClick(item),
          itemBuilder: (context) => [
            if (state.canManageUsers)
              const PopupMenuItem<int>(value: 0, child: Text("Users")),
            const PopupMenuItem<int>(value: 1, child: Text("User info")),
            const PopupMenuItem<int>(value: 2, child: Text("Change password")),
            const PopupMenuItem<int>(value: 3, child: Text('Logout')),
          ],
        ),
      ),
    ];
  }

  void handleClick(int item) {
    switch (item) {
      case 0:
        Navigator.pushNamed(context, routeUsers);
        break;
      case 1:
        Navigator.pushNamed(context, routeUserInfo);
        break;
      case 2:
        Navigator.pushNamed(context, routeChangePassword);
        break;
      case 3:
        _viewModel.logout();
        break;
    }
  }

  Widget _buildBody(BuildContext context) {
    return ValueListenableBuilder<HomeState>(
      valueListenable: _viewModel.state,
      builder: (context, state, _) {
        if (state.loading && state.items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.items.isEmpty) {
          return const Center(child: Text('ยังไม่มีระบบ'));
        }
        return Padding(
          padding: const EdgeInsets.all(defaultPagePadding),
          child: _buildSystems(state.items, state.canManageSystems),
        );
      },
    );
  }

  Widget _buildSystems(List<System> items, bool canManage) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final content = items[index];
        return ListTile(
          title: Text(content.systemCode),
          subtitle: Text('${content.systemName}\n${content.host}'),
          isThreeLine: true,
          trailing: canManage
              ? PopupMenuButton<int>(
                  icon: const Icon(Icons.more_horiz),
                  onSelected: (action) {
                    if (action == 0) {
                      _openForm(system: content);
                    } else {
                      _confirmRemove(content);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem<int>(value: 0, child: Text('แก้ไข')),
                    const PopupMenuItem<int>(value: 1, child: Text('ลบ')),
                  ],
                )
              : null,
          onTap: canManage ? () => _openForm(system: content) : null,
        );
      },
    );
  }

  void _openForm({System? system}) {
    showSystemFormDialog(
      context,
      system: system,
      onCreate: _viewModel.createSystem,
      onUpdate: _viewModel.updateSystemById,
    );
  }

  void _confirmRemove(System system) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('ลบระบบ'),
        content: Text('ต้องการลบ ${system.systemCode} ใช่หรือไม่'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _viewModel.removeSystemById(system.id);
            },
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
  }
}
