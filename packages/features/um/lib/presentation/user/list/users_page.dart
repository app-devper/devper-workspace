// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:design_system/theme/color.dart';
import 'package:design_system/theme/theme.dart';
import 'package:design_system/widgets/snack_bar.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// Project imports:
import 'package:um/domain/entities/user/param.dart';
import 'package:um/hooks/use_set_password.dart';
import 'package:um/hooks/use_users.dart';
import 'package:um/presentation/constants.dart';
import 'package:um/presentation/core/widget/build_set_password.dart';
import 'package:um/presentation/core/widget/build_users.dart';
import 'package:um/presentation/user/argument.dart';

class UsersPage extends HookWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final snackBar = CustomSnackBar(key: const Key("snackbar"), context: context);

    final reloadKey = useState(UniqueKey());

    final users = useUsers(reloadKey.value);

    reload(result) {
      if (result != null && result is bool) {
        if (result) {
          reloadKey.value = UniqueKey();
        }
      }
    }

    nextToUserEdit(String userId) async {
      final result = await Navigator.pushNamed(context, routeUserEdit, arguments: UserArgument(userId));
      reload(result);
    }

    nextToUserAdd() async {
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

    openSetPassword(user) {
      showSetPasswordDialog(
        context,
        user: user,
        onSubmit: (password) => setPassword(
          SetPasswordParam(userId: user.id, password: password),
        ),
      );
    }

    buildAction() {
      return [
        IconButton(
          onPressed: () {
            nextToUserAdd();
          },
          icon: const Icon(Icons.add),
        ),
      ];
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: CustomTheme.mainTheme.iconTheme,
        backgroundColor: CustomColor.white,
        centerTitle: true,
        title: Text(
          "ผู้ใช้งาน",
          style: CustomTheme.mainTheme.textTheme.headlineSmall,
        ),
        actions: buildAction(),
      ),
      body: buildUsers(
        users,
        (user) {
          nextToUserEdit(user.id);
        },
        onSetPassword: openSetPassword,
        onRetry: () => reloadKey.value = UniqueKey(),
      ),
    );
  }
}
