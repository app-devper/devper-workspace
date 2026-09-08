// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:design_system/theme/spacing.dart';
import 'package:design_system/widgets/page_container.dart';
import 'package:design_system/widgets/snack_bar.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:um/domain/entities/user/param.dart';
import 'package:um/hooks/use_set_password.dart';
import 'package:um/hooks/use_users.dart';
import 'package:um/presentation/constants.dart';
import 'package:um/presentation/core/widget/build_set_password.dart';
import 'package:um/presentation/core/widget/build_users.dart';
import 'package:um/presentation/user/argument.dart';

/// Users list rendered inside the shell, so the sidebar stays put while the
/// add and edit screens are still full pages pushed on top.
class UsersSection extends HookWidget {
  const UsersSection({super.key});

  @override
  Widget build(BuildContext context) {
    final snackBar = CustomSnackBar(key: const Key("snackbar"), context: context);
    final reloadKey = useState(UniqueKey());
    final users = useUsers(reloadKey.value);

    void reload(Object? result) {
      if (result is bool && result) {
        reloadKey.value = UniqueKey();
      }
    }

    Future<void> nextToUserEdit(String userId) async {
      final result = await Navigator.pushNamed(context, routeUserEdit,
          arguments: UserArgument(userId));
      reload(result);
    }

    Future<void> nextToUserAdd() async {
      final result = await Navigator.pushNamed(context, routeUserAdd);
      reload(result);
    }

    final setPassword = useSetPassword(
      context,
      onSuccess: () {
        snackBar.hideAll();
        snackBar.showSnackBar(text: "ตั้งรหัสผ่านใหม่แล้ว");
      },
    );

    return Column(
      children: [
        PageContainer(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
          child: Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: nextToUserAdd,
              icon: const Icon(Icons.person_add_alt),
              label: const Text('เพิ่มผู้ใช้'),
            ),
          ),
        ),
        Expanded(
          child: buildUsers(
            users,
            (user) => nextToUserEdit(user.id),
            onSetPassword: (user) => showSetPasswordDialog(
              context,
              user: user,
              onSubmit: (password) => setPassword(
                SetPasswordParam(userId: user.id, password: password),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
