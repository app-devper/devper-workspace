// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:common/core/ext/widget_ext.dart';
import 'package:design_system/theme/color.dart';
import 'package:design_system/theme/theme.dart';
import 'package:design_system/widgets/snack_bar.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// Project imports:
import 'package:um/domain/entities/user/user.dart';
import 'package:um/hooks/use_remove_user.dart';
import 'package:um/hooks/use_update_user.dart';
import 'package:um/hooks/use_user_id.dart';
import 'package:um/presentation/constants.dart';
import 'package:um/presentation/core/widget/build_user.dart';

class UserEditPage extends HookWidget {
  final String userId;

  const UserEditPage({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final snackBar = CustomSnackBar(key: const Key("snackbar"), context: context);

    final viewNode = useFocusNode();
    final userInfo = useUserId(userId);
    final edit = useState(false);

    success(User user) {
      snackBar.hideAll();
      snackBar.showSnackBar(text: "บันทึก ${user.username} สำเร็จ");
      edit.value = true;
    }

    final update = useUpdateUser(context, onSuccess: success);

    buildBody() {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPagePadding),
        child: FutureBuilder(
          future: userInfo,
          builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
            if (snapshot.hasError) {
              return Container();
            } else if (snapshot.hasData) {
              return buildUser(snapshot.requireData, (param) {
                update(param);
              });
            } else {
              return const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 6,
                  color: CustomColor.primary,
                  strokeCap: StrokeCap.round,
                ),
              );
            }
          },
        ),
      );
    }

    removeSuccess(User data) {
      Navigator.pop(context, true);
    }

    final remove = useRemoveUser(context, onSuccess: removeSuccess);

    confirm(User user) {
      showConfirmDialog(context, "ต้องการลบผู้ใช้งาน ${user.username} ใช่หรือไม่?", () {
        remove(user.id);
      });
    }

    buildAction() {
      return [
        IconButton(
          onPressed: () {
            userInfo.then((value) => confirm(value));
          },
          icon: const Icon(Icons.delete),
        ),
      ];
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(viewNode),
      child: Scaffold(
        appBar: AppBar(
          iconTheme: CustomTheme.mainTheme.iconTheme,
          backgroundColor: CustomColor.white,
          centerTitle: true,
          title: Text(
            "แก้ไขผู้ใช้",
            style: CustomTheme.mainTheme.textTheme.headlineSmall,
          ),
          actions: buildAction(),
        ),
        body: buildBody(),
      ),
    );
  }
}
