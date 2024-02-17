// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:common/core/theme/theme.dart';
import 'package:common/core/widgets/custom_snack_bar.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// Project imports:
import 'package:um/domain/entities/user/user.dart';
import 'package:um/hooks/use_update_user_info.dart';
import 'package:um/hooks/use_user_info.dart';
import 'package:um/presentation/constants.dart';
import 'package:um/presentation/core/widget/build_user.dart';

class UserInfoPage extends HookWidget {
  const UserInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final snackBar = CustomSnackBar(key: const Key("snackbar"), context: context);

    final viewNode = useFocusNode();
    final userInfo = useUserInfo();

    final edit = useState(false);

    success(User user) {
      snackBar.hideAll();
      snackBar.showSnackBar(text: "Update ${user.username} success");
      edit.value = true;
    }

    final update = useUpdateUserInfo(context, onSuccess: success);

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
                update(param.userParam);
              });
            } else {
              return Center(
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

    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(viewNode),
      child: Scaffold(
        appBar: AppBar(
          iconTheme: CustomTheme.mainTheme.iconTheme,
          backgroundColor: CustomColor.white,
          centerTitle: true,
          title: Text(
            "User Info",
            style: CustomTheme.mainTheme.textTheme.headlineSmall,
          ),
        ),
        body: buildBody(),
      ),
    );
  }
}
