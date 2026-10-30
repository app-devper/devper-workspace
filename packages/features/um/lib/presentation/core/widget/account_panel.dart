// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:common/core/ext/widget_ext.dart';
import 'package:design_system/theme/spacing.dart';
import 'package:design_system/widgets/page_container.dart';
import 'package:design_system/widgets/snack_bar.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// Project imports:
import 'package:um/domain/entities/user/user.dart';
import 'package:um/hooks/use_revoke_other_sessions.dart';
import 'package:um/hooks/use_revoke_session.dart';
import 'package:um/hooks/use_sessions.dart';
import 'package:um/hooks/use_update_user_info.dart';
import 'package:um/hooks/use_user_info.dart';
import 'package:um/presentation/core/widget/build_change_password.dart';
import 'package:um/presentation/core/widget/build_sessions.dart';
import 'package:um/presentation/core/widget/build_user.dart';

/// The signed-in user's own account: profile, password and active sessions.
/// UM's "my account" page and SM's profile section both host this one panel.
/// A part that fails to load says so and offers a retry.
class AccountPanel extends HookWidget {
  const AccountPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final snackBar =
        CustomSnackBar(key: const Key("snackbar"), context: context);
    final textTheme = Theme.of(context).textTheme;

    // Bumping a key re-runs its load: after a retry, or a revoke.
    final userKey = useState(0);
    final userInfo = useUserInfo([userKey.value]);
    final update = useUpdateUserInfo(context, onSuccess: (User user) {
      snackBar.hideAll();
      snackBar.showSnackBar(text: "บันทึก ${user.username} สำเร็จ");
    });

    final sessionsKey = useState(0);
    final sessions = useSessions([sessionsKey.value]);
    void reloadSessions() => sessionsKey.value++;

    final revokeSession = useRevokeSession(context, onSuccess: reloadSessions);
    final revokeOthers = useRevokeOtherSessions(
      context,
      onSuccess: (revoked) {
        snackBar.hideAll();
        snackBar.showSnackBar(text: "ออกจากระบบแล้ว $revoked อุปกรณ์");
        reloadSessions();
      },
    );

    return SingleChildScrollView(
      child: PageContainer(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("ข้อมูลส่วนตัว", style: textTheme.titleMedium),
            userInfo.toWidgetLoading(
              widgetBuilder: (user) =>
                  buildUser(user, (param) => update(param.userParam)),
              onRetry: () => userKey.value++,
            ),
            const SizedBox(height: AppSpacing.xl),
            const Divider(),
            const SizedBox(height: AppSpacing.lg),
            Text("เปลี่ยนรหัสผ่าน", style: textTheme.titleMedium),
            buildChangePassword(onSuccess: () {
              snackBar.hideAll();
              snackBar.showSnackBar(text: "เปลี่ยนรหัสผ่านแล้ว");
            }),
            const SizedBox(height: AppSpacing.xl),
            const Divider(),
            const SizedBox(height: AppSpacing.lg),
            sessions.toWidgetLoading(
              widgetBuilder: (list) => buildSessions(
                list,
                onRevoke: revokeSession,
                onRevokeOthers: revokeOthers,
              ),
              onRetry: reloadSessions,
            ),
          ],
        ),
      ),
    );
  }
}
