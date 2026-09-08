// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:design_system/theme/color.dart';
import 'package:design_system/theme/radius.dart';
import 'package:design_system/theme/spacing.dart';
import 'package:design_system/widgets/responsive.dart';

/// One entry in the shell's sidebar.
class AppShellItem {
  final String id;
  final String label;
  final IconData icon;

  const AppShellItem({
    required this.id,
    required this.label,
    required this.icon,
  });
}

/// Application frame with a collapsible sidebar.
///
/// On a wide viewport the sidebar is part of the layout and its width animates
/// between expanded and a collapsed icon rail. On a narrow one the same panel
/// slides in over the content behind a scrim, so navigation behaves the way a
/// drawer is expected to on a phone.
class AppShell extends StatefulWidget {
  final String title;
  final String brand;
  final List<AppShellItem> items;
  final String selectedId;
  final ValueChanged<String> onSelect;
  final Widget child;
  final List<Widget> actions;
  /// Built with the collapsed state so the host can drop labels in the rail,
  /// the way the nav items do. A plain widget would wrap one glyph per line.
  final Widget Function(bool collapsed)? sidebarFooter;
  final Widget? floatingActionButton;

  /// Start docked-and-expanded or as an icon rail. Null follows the form
  /// factor, which suits a host whose sidebar is the only navigation.
  final bool? initiallyExpanded;

  /// Set false when each section draws its own header. The bar still appears
  /// on a narrow viewport, where it is the only way to reach the drawer.
  final bool showTopBar;

  const AppShell({
    super.key,
    required this.title,
    required this.brand,
    required this.items,
    required this.selectedId,
    required this.onSelect,
    required this.child,
    this.actions = const [],
    this.sidebarFooter,
    this.floatingActionButton,
    this.initiallyExpanded,
    this.showTopBar = true,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with SingleTickerProviderStateMixin {
  static const _expandedWidth = 260.0;
  static const _railWidth = 72.0;
  static const _duration = Duration(milliseconds: 220);
  static const _curve = Curves.easeInOutCubic;

  /// Desktop: expanded vs icon rail. Mobile: drawer shown vs hidden.
  ///
  /// Null until the user touches the toggle, so the default can follow the
  /// form factor: a docked sidebar starts open, a drawer starts hidden.
  bool? _open;

  bool _isOpen(bool isMobile) =>
      _open ?? widget.initiallyExpanded ?? !isMobile;

  void _toggle(bool isMobile) => setState(() => _open = !_isOpen(isMobile));

  @override
  Widget build(BuildContext context) {
    return Responsive.isMobile(context)
        ? _buildMobile(context)
        : _buildDesktop(context);
  }

  Widget _buildDesktop(BuildContext context) {
    final open = _isOpen(false);
    return Scaffold(
      backgroundColor: CustomColor.backgroundIcon,
      floatingActionButton: widget.floatingActionButton,
      body: Row(
        children: [
          AnimatedContainer(
            duration: _duration,
            curve: _curve,
            width: open ? _expandedWidth : _railWidth,
            child: _Sidebar(
              brand: widget.brand,
              items: widget.items,
              selectedId: widget.selectedId,
              collapsed: !open,
              onSelect: widget.onSelect,
              onToggle: () => _toggle(false),
              footer: widget.sidebarFooter?.call(!open),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                if (widget.showTopBar)
                  _TopBar(title: widget.title, actions: widget.actions),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobile(BuildContext context) {
    final open = _isOpen(true);
    return Scaffold(
      backgroundColor: CustomColor.backgroundIcon,
      // The drawer sits above the content, so the action must not float over
      // the scrim while it is open.
      floatingActionButton: open ? null : widget.floatingActionButton,
      body: Stack(
        children: [
          Column(
            children: [
              _TopBar(
                title: widget.showTopBar ? widget.title : '',
                actions: widget.actions,
                onMenu: () => _toggle(true),
              ),
              Expanded(child: widget.child),
            ],
          ),
          // Scrim fades with the panel and swallows taps only while open.
          IgnorePointer(
            ignoring: !open,
            child: AnimatedOpacity(
              duration: _duration,
              curve: _curve,
              opacity: open ? 1 : 0,
              child: GestureDetector(
                onTap: () => _toggle(true),
                child: Container(color: Colors.black.withValues(alpha: 0.4)),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: _duration,
            curve: _curve,
            top: 0,
            bottom: 0,
            left: open ? 0 : -_expandedWidth,
            width: _expandedWidth,
            child: Material(
              elevation: 8,
              child: _Sidebar(
                brand: widget.brand,
                items: widget.items,
                selectedId: widget.selectedId,
                collapsed: false,
                onSelect: (id) {
                  _toggle(true);
                  widget.onSelect(id);
                },
                onToggle: () => _toggle(true),
                footer: widget.sidebarFooter?.call(false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final List<Widget> actions;
  final VoidCallback? onMenu;

  const _TopBar({required this.title, required this.actions, this.onMenu});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: const BoxDecoration(
        color: CustomColor.white,
        border: Border(bottom: BorderSide(color: CustomColor.divider)),
      ),
      child: Row(
        children: [
          if (onMenu != null)
            IconButton(
              icon: const Icon(Icons.menu),
              tooltip: 'เมนู',
              onPressed: onMenu,
            ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          ...actions,
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final String brand;
  final List<AppShellItem> items;
  final String selectedId;
  final bool collapsed;
  final ValueChanged<String> onSelect;
  final VoidCallback onToggle;
  final Widget? footer;

  const _Sidebar({
    required this.brand,
    required this.items,
    required this.selectedId,
    required this.collapsed,
    required this.onSelect,
    required this.onToggle,
    required this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: CustomColor.white,
        border: Border(right: BorderSide(color: CustomColor.divider)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _header(context),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                children: [
                  for (final item in items)
                    _NavItem(
                      item: item,
                      selected: item.id == selectedId,
                      collapsed: collapsed,
                      onTap: () => onSelect(item.id),
                    ),
                ],
              ),
            ),
            if (footer != null) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: footer,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Row(
        children: [
          const SizedBox(width: AppSpacing.sm),
          // The label disappears before the panel finishes narrowing, which
          // keeps it from being clipped mid-animation.
          Expanded(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 120),
              opacity: collapsed ? 0 : 1,
              child: Text(
                brand,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          IconButton(
            icon: Icon(collapsed ? Icons.chevron_right : Icons.chevron_left),
            tooltip: collapsed ? 'ขยายเมนู' : 'ย่อเมนู',
            onPressed: onToggle,
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final AppShellItem item;
  final bool selected;
  final bool collapsed;
  final VoidCallback onTap;

  const _NavItem({
    required this.item,
    required this.selected,
    required this.collapsed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? CustomColor.primary : CustomColor.font2;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Tooltip(
        message: collapsed ? item.label : '',
        child: Material(
          color: selected
              ? CustomColor.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 12,
              ),
              child: Row(
                children: [
                  Icon(item.icon, size: 20, color: foreground),
                  if (!collapsed) ...[
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        item.label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: selected ? CustomColor.primary : CustomColor.fontBlack,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
