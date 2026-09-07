// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:common/core/ext/widget_ext.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// Project imports:
import 'package:um/container.dart';
import 'package:um/domain/entities/user/param.dart';
import 'package:um/domain/repositories/user_repository.dart';

Function(SetPasswordParam) useSetPassword(
  BuildContext context, {
  required Function() onSuccess,
}) {
  loading() {
    showLoadingDialog(context);
  }

  success() {
    hideLoadingDialog(context);
    onSuccess();
  }

  error(Failure failure) {
    hideLoadingDialog(context);
    showAlertDialog(context, failure.getMessage(), () {});
  }

  setPassword(SetPasswordParam param) async {
    final userRepo = sl<UserRepository>();
    loading();
    try {
      await userRepo.setPasswordById(param);
      success();
    } on Exception catch (e) {
      error(toFailure(e));
    }
  }

  final cachedFunction = useCallback(setPassword, []);
  return cachedFunction;
}
