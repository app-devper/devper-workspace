// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:design_system/theme/app_colors.dart';
import 'package:design_system/theme/color.dart';
import 'package:design_system/theme/theme.dart';
import 'package:design_system/widgets/snack_bar.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// Project imports:
import 'package:um/domain/entities/auth/user_session.dart';
import 'package:um/domain/entities/user/user.dart';
import 'package:um/hooks/use_revoke_other_sessions.dart';
import 'package:um/hooks/use_revoke_session.dart';
import 'package:um/hooks/use_sessions.dart';
import 'package:um/hooks/use_update_user_info.dart';
import 'package:um/hooks/use_user_info.dart';
import 'package:design_system/theme/spacing.dart';
import 'package:design_system/widgets/page_container.dart';
import 'package:um/presentation/core/widget/build_change_password.dart';
import 'package:um/presentation/core/widget/build_sessions.dart';
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
      snackBar.showSnackBar(text: "บันทึก ${user.username} สำเร็จ");
      edit.value = true;
    }

    final update = useUpdateUserInfo(context, onSuccess: success);

    // Bumping the key re-runs useSessions so the list reflects a revoke.
    final sessionsKey = useState(0);
    final sessions = useSessions([sessionsKey.value]);

    reloadSessions() => sessionsKey.value++;

    final revokeSession = useRevokeSession(context, onSuccess: reloadSessions);
    final revokeOthers = useRevokeOtherSessions(
      context,
      onSuccess: (revoked) {
        snackBar.hideAll();
        snackBar.showSnackBar(text: "ออกจากระบบแล้ว $revoked อุปกรณ์");
        reloadSessions();
      },
    );

    buildSessionSection() {
      return FutureBuilder(
        future: sessions,
        builder: (BuildContext context, AsyncSnapshot<List<UserSession>> snapshot) {
          if (snapshot.hasError) {
            return const SizedBox.shrink();
          } else if (snapshot.hasData) {
            return buildSessions(
              snapshot.requireData,
              onRevoke: revokeSession,
              onRevokeOthers: revokeOthers,
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      );
    }

    buildBody() {
      return SingleChildScrollView(
        child: PageContainer(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.lg,
          ),
          child: FutureBuilder(
          future: userInfo,
          builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
            if (snapshot.hasError) {
              return Container();
            } else if (snapshot.hasData) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "ข้อมูลส่วนตัว",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  buildUser(snapshot.requireData, (param) {
                    update(param.userParam);
                  }),
                  const SizedBox(height: AppSpacing.xl),
                  const Divider(),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    "เปลี่ยนรหัสผ่าน",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  buildChangePassword(onSuccess: () {
                    snackBar.hideAll();
                    snackBar.showSnackBar(text: "เปลี่ยนรหัสผ่านแล้ว");
                  }),
                  const SizedBox(height: AppSpacing.xl),
                  const Divider(),
                  const SizedBox(height: AppSpacing.lg),
                  buildSessionSection(),
                ],
              );
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
        ),
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
            "ข้อมูลของฉัน",
            style: CustomTheme.mainTheme.textTheme.headlineSmall,
          ),
        ),
        body: buildBody(),
      ),
    );
  }
}
