// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:design_system/theme/app_colors.dart';
import 'package:design_system/theme/color.dart';
import 'package:design_system/theme/radius.dart';
import 'package:design_system/theme/spacing.dart';

// Project imports:
import 'package:um/domain/entities/auth/user_session.dart';

/// Active sessions for the signed-in user, with per-session revoke and a
/// revoke-all action for everything except the session in use.
Widget buildSessions(
  List<UserSession> sessions, {
  required void Function(String sessionId) onRevoke,
  required VoidCallback onRevokeOthers,
}) {
  return _SessionsSection(
    sessions: sessions,
    onRevoke: onRevoke,
    onRevokeOthers: onRevokeOthers,
  );
}

class _SessionsSection extends StatelessWidget {
  final List<UserSession> sessions;
  final void Function(String sessionId) onRevoke;
  final VoidCallback onRevokeOthers;

  const _SessionsSection({
    required this.sessions,
    required this.onRevoke,
    required this.onRevokeOthers,
  });

  /// "2026-09-08T01:00:00Z" reads as noise in a list; show the date and
  /// minute only, and fall back to the raw value if it will not parse.
  String _formatTimestamp(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    final local = parsed.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(local.day)}/${two(local.month)}/${local.year} '
        '${two(local.hour)}:${two(local.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasOthers = sessions.any((session) => !session.current);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("อุปกรณ์ที่เข้าสู่ระบบอยู่", style: textTheme.titleMedium),
                  Text(
                    "อุปกรณ์ที่ยังเข้าสู่ระบบด้วยบัญชีนี้",
                    style: textTheme.bodySmall?.copyWith(color: AppColors.of(context).textSecondary),
                  ),
                ],
              ),
            ),
            if (hasOthers)
              TextButton.icon(
                onPressed: onRevokeOthers,
                icon: const Icon(Icons.logout, size: 18),
                label: const Text("ออกจากระบบอุปกรณ์อื่น"),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (sessions.isEmpty)
          Text(
            "ไม่มีอุปกรณ์ที่เข้าสู่ระบบอยู่",
            style: textTheme.bodySmall?.copyWith(color: AppColors.of(context).textSecondary),
          )
        else
          ...sessions.map((session) => _sessionCard(context, session)),
      ],
    );
  }

  Widget _sessionCard(BuildContext context, UserSession session) {
    final textTheme = Theme.of(context).textTheme;
    final colors = AppColors.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.of(context).surfaceRaised,
        border: Border.all(
          color: session.current ? CustomColor.info : AppColors.of(context).border,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            session.current ? Icons.verified_user : Icons.devices_other,
            color: session.current ? CustomColor.info : AppColors.of(context).textSecondary,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        session.system.isEmpty ? "ไม่ทราบระบบ" : session.system,
                        style: textTheme.titleSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (session.current) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm, vertical: 2),
                        decoration: BoxDecoration(
                          color: CustomColor.info.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: const Text(
                          "อุปกรณ์นี้",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: CustomColor.info,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                _line(Icons.schedule, "ใช้งานล่าสุด ${_formatTimestamp(session.lastActivity)}", colors.textSecondary),
                _line(Icons.language, session.ipAddress, colors.textSecondary),
                _line(Icons.computer, session.userAgent, colors.textSecondary),
              ],
            ),
          ),
          if (!session.current)
            IconButton(
              tooltip: "ออกจากระบบอุปกรณ์นี้",
              icon: const Icon(Icons.logout, color: CustomColor.error),
              onPressed: () => onRevoke(session.sessionId),
            ),
        ],
      ),
    );
  }

  Widget _line(IconData icon, String value, Color color) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12, color: color),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
