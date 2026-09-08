// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:design_system/theme/spacing.dart';
import 'package:design_system/widgets/page_container.dart';
import 'package:design_system/widgets/snack_bar.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:um/domain/entities/auth/user_session.dart';
import 'package:um/domain/entities/user/user.dart';
import 'package:um/hooks/use_revoke_other_sessions.dart';
import 'package:um/hooks/use_revoke_session.dart';
import 'package:um/hooks/use_sessions.dart';
import 'package:um/hooks/use_update_user_info.dart';
import 'package:um/hooks/use_user_info.dart';
import 'package:um/presentation/core/widget/build_sessions.dart';
import 'package:um/presentation/core/widget/build_user.dart';

/// Profile and active sessions, hosted by the shell rather than pushed.
class ProfileSection extends HookWidget {
  const ProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    final snackBar = CustomSnackBar(key: const Key("snackbar"), context: context);
    final textTheme = Theme.of(context).textTheme;

    final userInfo = useUserInfo();
    final update = useUpdateUserInfo(context, onSuccess: (User user) {
      snackBar.hideAll();
      snackBar.showSnackBar(text: "บันทึก ${user.username} สำเร็จ");
    });

    // Bumping the key re-runs useSessions so the list reflects a revoke.
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
            FutureBuilder(
              future: userInfo,
              builder: (context, AsyncSnapshot<User> snapshot) {
                if (snapshot.hasError) return const SizedBox.shrink();
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return buildUser(
                  snapshot.requireData,
                  (param) => update(param.userParam),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            const Divider(),
            const SizedBox(height: AppSpacing.lg),
            FutureBuilder(
              future: sessions,
              builder: (context, AsyncSnapshot<List<UserSession>> snapshot) {
                if (snapshot.hasError) return const SizedBox.shrink();
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return buildSessions(
                  snapshot.requireData,
                  onRevoke: revokeSession,
                  onRevokeOthers: revokeOthers,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
