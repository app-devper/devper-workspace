// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:common/core/ext/widget_ext.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// Project imports:
import 'package:um/container.dart';
import 'package:um/domain/entities/user/user.dart';
import 'package:um/domain/repositories/user_repository.dart';

Function(String) useRemoveUser(
  BuildContext context, {
  required Function(User) onSuccess,
}) {
  loading() {
    showLoadingDialog(context);
  }

  success(User user) {
    hideLoadingDialog(context);
    onSuccess(user);
  }

  error(Failure failure) {
    hideLoadingDialog(context);
    showAlertDialog(context, failure.getMessage(), () {});
  }

  removeUser(String param) async {
    final userRepo = sl<UserRepository>();
    loading();
    try {
      final result = await userRepo.removeUserById(param);
      success(result);
    } on Exception catch (e) {
      error(toFailure(e));
    }
  }

  final cachedFunction = useCallback(removeUser, []);
  return cachedFunction;
}
