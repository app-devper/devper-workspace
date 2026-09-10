import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:um/container.dart';
import 'package:um/domain/usecase/auth_use_cases.dart';
import 'package:um/hooks/use_mutation_action.dart';

Function() useLogout(
  BuildContext context, {
  required Function() onSuccess,
}) {
  final action = sl<LogoutUseCase>();
  final run = useMutationAction<void, bool>(context, (_) => action(),
      onSuccess: (_) => onSuccess());
  return useCallback(() => run(null), [run]);
}
