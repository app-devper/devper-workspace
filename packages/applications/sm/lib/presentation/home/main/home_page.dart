// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:design_system/theme/color.dart';
import 'package:design_system/widgets/app_shell.dart';
import 'package:design_system/widgets/snack_bar.dart';
import 'package:um/presentation/constants.dart';

// Project imports:
import 'package:sm/container.dart';
import 'package:sm/presentation/home/main/home_state.dart';
import 'package:sm/presentation/home/main/home_view_model.dart';
import 'package:sm/presentation/home/main/system_form_dialog.dart';
import 'package:sm/presentation/home/sections/profile_section.dart';
import 'package:sm/presentation/home/sections/systems_section.dart';
import 'package:sm/presentation/home/sections/users_section.dart';

const _systemsId = 'systems';
const _usersId = 'users';
const _profileId = 'profile';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomeViewModel _viewModel;
  late CustomSnackBar _snackBar;

  String _selected = _systemsId;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<HomeViewModel>();
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

  /// The sidebar only offers what the signed-in role may open, mirroring the
  /// gating the screens themselves apply.
  List<AppShellItem> _items(HomeState state) {
    return [
      if (state.canManageSystems)
        const AppShellItem(
            id: _systemsId, label: 'ระบบ', icon: Icons.dns_outlined),
      if (state.canManageUsers)
        const AppShellItem(
            id: _usersId, label: 'ผู้ใช้งาน', icon: Icons.group_outlined),
      const AppShellItem(
          id: _profileId, label: 'ข้อมูลของฉัน', icon: Icons.person_outline),
    ];
  }

  String _titleFor(String id) {
    switch (id) {
      case _usersId:
        return 'ผู้ใช้งาน';
      case _profileId:
        return 'ข้อมูลของฉัน';
      default:
        return 'ระบบทั้งหมด';
    }
  }

  Widget _sectionFor(String id) {
    switch (id) {
      case _usersId:
        return const UsersSection();
      case _profileId:
        return const ProfileSection();
      default:
        return SystemsSection(viewModel: _viewModel);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<HomeState>(
      valueListenable: _viewModel.state,
      builder: (context, state, _) {
        final items = _items(state);
        // Role loads after the first frame, so fall back to a section the
        // current role is actually allowed to see.
        final selected = items.any((item) => item.id == _selected)
            ? _selected
            : (items.isEmpty ? _profileId : items.first.id);

        return AppShell(
          brand: 'Devper SM',
          title: _titleFor(selected),
          items: items,
          selectedId: selected,
          onSelect: (id) => setState(() => _selected = id),
          sidebarFooter: _buildSidebarFooter,
          floatingActionButton: selected == _systemsId && state.canManageSystems
              ? FloatingActionButton.extended(
                  onPressed: () => showSystemFormDialog(
                    context,
                    onCreate: _viewModel.createSystem,
                    onUpdate: _viewModel.updateSystemById,
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('เพิ่มระบบ'),
                )
              : null,
          child: _sectionFor(selected),
        );
      },
    );
  }

  Widget _buildSidebarFooter(bool collapsed) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _footerAction(
          collapsed: collapsed,
          icon: Icons.logout,
          label: 'ออกจากระบบ',
          color: CustomColor.error,
          onTap: _viewModel.logout,
        ),
      ],
    );
  }

  Widget _footerAction({
    required bool collapsed,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return AppSidebarAction(
      label: label,
      icon: icon,
      collapsed: collapsed,
      onTap: onTap,
    );
  }
}
