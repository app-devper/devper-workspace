import 'package:flutter/widgets.dart';
import 'package:um/container.dart';
import 'package:um/domain/usecase/user_use_cases.dart';
import 'package:um/hooks/use_mutation_action.dart';
import 'package:um/domain/entities/user/param.dart';

Function(SetPasswordParam) useSetPassword(
  BuildContext context, {
  required Function() onSuccess,
}) {
  final action = sl<SetPasswordUseCase>();
  return useMutationAction<SetPasswordParam, bool>(context, action.call,
      onSuccess: (_) => onSuccess());
}
