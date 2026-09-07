// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
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
                  Text("Active sessions", style: textTheme.titleMedium),
                  Text(
                    "Devices signed in to your account",
                    style: textTheme.bodySmall?.copyWith(color: CustomColor.font2),
                  ),
                ],
              ),
            ),
            if (hasOthers)
              TextButton.icon(
                onPressed: onRevokeOthers,
                icon: const Icon(Icons.logout, size: 18),
                label: const Text("Sign out others"),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (sessions.isEmpty)
          Text(
            "No active sessions",
            style: textTheme.bodySmall?.copyWith(color: CustomColor.font2),
          )
        else
          ...sessions.map((session) => _sessionCard(context, session)),
      ],
    );
  }

  Widget _sessionCard(BuildContext context, UserSession session) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: CustomColor.white,
        border: Border.all(
          color: session.current ? CustomColor.info : CustomColor.divider,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            session.current ? Icons.verified_user : Icons.devices_other,
            color: session.current ? CustomColor.info : CustomColor.font2,
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
                        session.system.isEmpty ? "Unknown system" : session.system,
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
                          "This device",
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
                _line(Icons.schedule, "Last active ${_formatTimestamp(session.lastActivity)}"),
                _line(Icons.language, session.ipAddress),
                _line(Icons.computer, session.userAgent),
              ],
            ),
          ),
          if (!session.current)
            IconButton(
              tooltip: "Sign out",
              icon: const Icon(Icons.logout, color: CustomColor.error),
              onPressed: () => onRevoke(session.sessionId),
            ),
        ],
      ),
    );
  }

  Widget _line(IconData icon, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: CustomColor.font2),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12, color: CustomColor.font2),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
