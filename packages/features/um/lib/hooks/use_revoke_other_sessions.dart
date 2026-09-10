import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:um/container.dart';
import 'package:um/domain/usecase/auth_use_cases.dart';
import 'package:um/hooks/use_mutation_action.dart';

Function() useRevokeOtherSessions(
  BuildContext context, {
  required Function(int revoked) onSuccess,
}) {
  final action = sl<RevokeOtherSessionsUseCase>();
  final run = useMutationAction<void, int>(context, (_) => action(),
      onSuccess: onSuccess);
  return useCallback(() => run(null), [run]);
}
