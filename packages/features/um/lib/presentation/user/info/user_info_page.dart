// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:design_system/theme/app_colors.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// Project imports:
import 'package:um/presentation/core/widget/account_panel.dart';

class UserInfoPage extends HookWidget {
  const UserInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewNode = useFocusNode();
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(viewNode),
      child: Scaffold(
        appBar: AppBar(
          iconTheme: Theme.of(context).iconTheme,
          backgroundColor: AppColors.of(context).surfaceRaised,
          centerTitle: true,
          title: Text(
            "ข้อมูลของฉัน",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        body: const AccountPanel(),
      ),
    );
  }
}
