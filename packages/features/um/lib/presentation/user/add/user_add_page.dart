// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:design_system/theme/app_colors.dart';
import 'package:design_system/theme/theme.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// Project imports:
import 'package:um/presentation/constants.dart';
import 'package:um/presentation/core/widget/build_add_user.dart';

class UserAddPage extends HookWidget {
  const UserAddPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewNode = useFocusNode();
    final add = useState(false);

    buildBody() {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPagePadding),
        child: buildAddUser((user) {
          add.value = true;
        }),
      );
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(viewNode),
      child: Scaffold(
        appBar: AppBar(
          iconTheme: CustomTheme.mainTheme.iconTheme,
          backgroundColor: AppColors.of(context).surfaceRaised,
          centerTitle: true,
          title: Text(
            "เพิ่มผู้ใช้",
            style: CustomTheme.mainTheme.textTheme.headlineSmall,
          ),
        ),
        body: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            Navigator.pop(context, add.value);
          },
          child: buildBody(),
        ),
      ),
    );
  }
}
