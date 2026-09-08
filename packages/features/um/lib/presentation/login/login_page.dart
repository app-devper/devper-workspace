// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:design_system/theme/color.dart';
import 'package:design_system/theme/spacing.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// Project imports:
import 'package:um/domain/entities/auth/system.dart';
import 'package:um/hooks/use_app_config.dart';
import 'package:um/presentation/constants.dart';
import 'package:um/presentation/core/widget/build_login.dart';

class LoginPage extends HookWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final config = useAppConfig();

    void nextHome(System system) {
      if (system.systemCode == config.system) {
        Navigator.pushNamedAndRemoveUntil(context, config.home, (r) => false);
      } else {
        Navigator.pushNamedAndRemoveUntil(context, routeError, (r) => false);
      }
    }

    return Scaffold(
      backgroundColor: CustomColor.backgroundIcon,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xl,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                // AutofillGroup lets the browser and the OS offer saved
                // credentials for the pair of fields.
                child: AutofillGroup(child: buildLogin(nextHome)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
