import 'package:flutter/widgets.dart';
import 'package:um/container.dart';
import 'package:um/domain/usecase/auth_use_cases.dart';
import 'package:um/hooks/use_mutation_action.dart';
import 'package:um/domain/entities/auth/param.dart';
import 'package:um/domain/entities/auth/system.dart';

Function(LoginParam) useLogin(
  BuildContext context, {
  required Function(System) onSuccess,
}) {
  final action = sl<LoginUseCase>();
  return useMutationAction<LoginParam, System>(context, action.call,
      onSuccess: onSuccess);
}
