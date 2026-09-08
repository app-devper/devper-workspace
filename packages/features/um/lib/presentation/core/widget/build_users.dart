// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:common/core/ext/widget_ext.dart';
import 'package:design_system/theme/color.dart';
import 'package:design_system/theme/radius.dart';
import 'package:design_system/theme/spacing.dart';
import 'package:design_system/widgets/empty_state.dart';
import 'package:design_system/widgets/page_container.dart';
import 'package:design_system/widgets/status_badge.dart';

// Project imports:
import 'package:um/domain/entities/user/user.dart';

/// Role drives the badge colour so privileged accounts stand out in the list.
Color _roleColor(String role) {
  switch (role.toUpperCase()) {
    case 'SUPER':
      return CustomColor.font6;
    case 'ADMIN':
      return CustomColor.info;
    case 'MANAGER':
      return CustomColor.warning;
    default:
      return CustomColor.font2;
  }
}

FutureBuilder<List<User>> buildUsers(
  Future<List<User>> users,
  Function(User) onTap, {
  Function(User)? onSetPassword,
  VoidCallback? onRetry,
}) {
  return users.toWidgetLoading(
    onRetry: onRetry,
    widgetBuilder: (data) {
      if (data.isEmpty) {
        return const EmptyState(
          icon: Icons.group_outlined,
          title: "ยังไม่มีผู้ใช้งาน",
        );
      }
      return PageContainer(
        child: ListView.separated(
          itemCount: data.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) => _UserCard(
            user: data[index],
            onTap: onTap,
            onSetPassword: onSetPassword,
          ),
        ),
      );
    },
  );
}

class _UserCard extends StatelessWidget {
  final User user;
  final Function(User) onTap;
  final Function(User)? onSetPassword;

  const _UserCard({
    required this.user,
    required this.onTap,
    required this.onSetPassword,
  });

  String get _fullName {
    final name = "${user.firstName ?? ''} ${user.lastName ?? ''}".trim();
    return name.isEmpty ? user.username : name;
  }

  String get _initial {
    final source = _fullName.trim();
    return source.isEmpty ? "?" : source.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final roleColor = _roleColor(user.role);

    return Container(
      decoration: BoxDecoration(
        color: CustomColor.white,
        border: Border.all(color: CustomColor.divider),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        onTap: () => onTap(user),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: roleColor.withValues(alpha: 0.12),
                child: Text(
                  _initial,
                  style: TextStyle(
                    color: roleColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _fullName,
                      style: textTheme.titleSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      user.username,
                      style: TextStyle(fontSize: 12, color: CustomColor.font2),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              StatusBadge(label: user.role, color: roleColor),
              if (onSetPassword != null)
                IconButton(
                  tooltip: "ตั้งรหัสผ่าน",
                  icon: const Icon(Icons.key_outlined),
                  onPressed: () => onSetPassword!(user),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
