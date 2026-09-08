// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:design_system/theme/color.dart';
import 'package:design_system/theme/radius.dart';
import 'package:design_system/theme/spacing.dart';
import 'package:design_system/widgets/empty_state.dart';
import 'package:design_system/widgets/page_container.dart';
import 'package:design_system/widgets/snack_bar.dart';
import 'package:design_system/widgets/status_badge.dart';
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
  final _searchController = TextEditingController();

  late HomeViewModel _viewModel;
  late CustomSnackBar _snackBar;

  String _query = '';

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
    _searchController.dispose();
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

  /// Case-insensitive match across the fields shown on the card.
  List<System> _visible(List<System> items) {
    if (_query.isEmpty) return items;
    final query = _query.toLowerCase();
    return items
        .where((item) =>
            item.systemCode.toLowerCase().contains(query) ||
            item.systemName.toLowerCase().contains(query) ||
            item.host.toLowerCase().contains(query) ||
            item.clientId.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: CustomColor.backgroundIcon,
      appBar: AppBar(
        title: const Text('ระบบทั้งหมด'),
        actions: _buildAction(context),
      ),
      floatingActionButton: ValueListenableBuilder<HomeState>(
        valueListenable: _viewModel.state,
        builder: (context, state, _) => state.canManageSystems
            ? FloatingActionButton.extended(
                onPressed: () => _openForm(),
                icon: const Icon(Icons.add),
                label: const Text('เพิ่มระบบ'),
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
          icon: const Icon(Icons.account_circle_outlined),
          tooltip: 'บัญชีผู้ใช้',
          onSelected: (item) => handleClick(item),
          itemBuilder: (context) => [
            if (state.canManageUsers)
              const PopupMenuItem<int>(
                value: 0,
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.group_outlined),
                  title: Text('ผู้ใช้งาน'),
                ),
              ),
            const PopupMenuItem<int>(
              value: 1,
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.person_outline),
                title: Text('ข้อมูลของฉัน'),
              ),
            ),
            const PopupMenuItem<int>(
              value: 2,
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.lock_outline),
                title: Text('เปลี่ยนรหัสผ่าน'),
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem<int>(
              value: 3,
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.logout, color: CustomColor.error),
                title: Text('ออกจากระบบ',
                    style: TextStyle(color: CustomColor.error)),
              ),
            ),
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
          return EmptyState(
            icon: Icons.dns_outlined,
            title: 'ยังไม่มีระบบ',
            message: state.canManageSystems
                ? 'เพิ่มระบบแรกเพื่อเริ่มใช้งาน'
                : 'ติดต่อผู้ดูแลระบบเพื่อเพิ่มระบบ',
            actionLabel: state.canManageSystems ? 'เพิ่มระบบ' : null,
            onAction: state.canManageSystems ? () => _openForm() : null,
          );
        }

        final visible = _visible(state.items);
        return RefreshIndicator(
          onRefresh: _viewModel.getSystems,
          child: PageContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state.items.length > 5) ...[
                  _buildSearchField(),
                  const SizedBox(height: AppSpacing.sm),
                ],
                Expanded(
                  child: visible.isEmpty
                      ? const EmptyState(
                          icon: Icons.search_off,
                          title: 'ไม่พบระบบที่ค้นหา',
                        )
                      : _buildSystems(visible, state.canManageSystems),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _query = value.trim()),
      decoration: InputDecoration(
        hintText: 'ค้นหาชื่อระบบ รหัส หรือ host',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _query.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'ล้างคำค้นหา',
                onPressed: () {
                  _searchController.clear();
                  setState(() => _query = '');
                },
              ),
        filled: true,
        fillColor: CustomColor.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSystems(List<System> items, bool canManage) {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) => _buildSystemCard(items[index], canManage),
    );
  }

  Widget _buildSystemCard(System system, bool canManage) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        side: const BorderSide(color: CustomColor.divider),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        onTap: canManage ? () => _openForm(system: system) : null,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            system.systemName,
                            style: textTheme.titleMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        StatusBadge(
                          label: system.systemCode,
                          color: CustomColor.info,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _detailRow(Icons.link, system.host),
                    const SizedBox(height: AppSpacing.xs),
                    _detailRow(Icons.badge_outlined, system.clientId),
                  ],
                ),
              ),
              if (canManage)
                PopupMenuButton<int>(
                  icon: const Icon(Icons.more_horiz),
                  tooltip: 'จัดการระบบ',
                  onSelected: (action) {
                    if (action == 0) {
                      _openForm(system: system);
                    } else {
                      _confirmRemove(system);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem<int>(
                      value: 0,
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.edit_outlined),
                        title: Text('แก้ไข'),
                      ),
                    ),
                    const PopupMenuItem<int>(
                      value: 1,
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.delete_outline,
                            color: CustomColor.error),
                        title: Text('ลบ',
                            style: TextStyle(color: CustomColor.error)),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: CustomColor.font2),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 13, color: CustomColor.font2),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
        content: Text('ต้องการลบ ${system.systemName} (${system.systemCode}) '
            'ใช่หรือไม่ การลบไม่สามารถย้อนกลับได้'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: CustomColor.error),
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
