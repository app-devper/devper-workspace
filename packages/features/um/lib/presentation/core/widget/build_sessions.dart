// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:um/domain/entities/auth/user_session.dart';

/// Active sessions for the signed-in user, with per-session revoke and a
/// revoke-all action for everything except the session in use.
Widget buildSessions(
  List<UserSession> sessions, {
  required void Function(String sessionId) onRevoke,
  required VoidCallback onRevokeOthers,
}) {
  final hasOthers = sessions.any((session) => !session.current);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Active sessions",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          if (hasOthers)
            TextButton(
              onPressed: onRevokeOthers,
              child: const Text("Sign out others"),
            ),
        ],
      ),
      const SizedBox(height: 8),
      if (sessions.isEmpty)
        const Text("No active sessions")
      else
        ...sessions.map(
          (session) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Row(
                children: [
                  Flexible(child: Text(session.system)),
                  if (session.current) ...[
                    const SizedBox(width: 8),
                    const Chip(
                      label: Text("This device"),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ],
              ),
              subtitle: Text(
                "${session.ipAddress}\n${session.userAgent}\nLast activity ${session.lastActivity}",
              ),
              isThreeLine: true,
              trailing: session.current
                  ? null
                  : IconButton(
                      tooltip: "Sign out",
                      icon: const Icon(Icons.logout),
                      onPressed: () => onRevoke(session.sessionId),
                    ),
            ),
          ),
        ),
    ],
  );
}
