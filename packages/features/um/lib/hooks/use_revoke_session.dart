import 'package:flutter/widgets.dart';
import 'package:um/container.dart';
import 'package:um/domain/usecase/auth_use_cases.dart';
import 'package:um/hooks/use_mutation_action.dart';

Function(String) useRevokeSession(
  BuildContext context, {
  required Function() onSuccess,
}) {
  final action = sl<RevokeSessionUseCase>();
  return useMutationAction<String, bool>(context, action.call,
      onSuccess: (_) => onSuccess());
}
