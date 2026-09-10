import 'package:flutter/widgets.dart';
import 'package:um/container.dart';
import 'package:um/domain/usecase/user_use_cases.dart';
import 'package:um/hooks/use_mutation_action.dart';
import 'package:um/domain/entities/user/param.dart';

Function(ChangePasswordParam) useChangePassword(
  BuildContext context, {
  required Function(bool) onSuccess,
}) {
  final action = sl<ChangePasswordUseCase>();
  return useMutationAction<ChangePasswordParam, bool>(context, action.call,
      onSuccess: onSuccess);
}
