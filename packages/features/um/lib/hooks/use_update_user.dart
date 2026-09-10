import 'package:flutter/widgets.dart';
import 'package:um/container.dart';
import 'package:um/domain/usecase/user_use_cases.dart';
import 'package:um/hooks/use_mutation_action.dart';
import 'package:um/domain/entities/user/param.dart';
import 'package:um/domain/entities/user/user.dart';

Function(UpdateUserParam) useUpdateUser(
  BuildContext context, {
  required Function(User) onSuccess,
}) {
  final action = sl<UpdateUserUseCase>();
  return useMutationAction<UpdateUserParam, User>(context, action.call,
      onSuccess: onSuccess);
}
