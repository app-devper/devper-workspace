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

Function(ChangePasswordParam) useChangePassword(
  BuildContext context, {
  required Function(bool) onSuccess,
}) {
  loading() {
    showLoadingDialog(context);
  }

  success(bool data) {
    hideLoadingDialog(context);
    onSuccess(data);
  }

  error(Failure failure) {
    hideLoadingDialog(context);
    showAlertDialog(context, failure.getMessage(), () {});
  }

  changePassword(ChangePasswordParam param) async {
    final userRepo = sl<UserRepository>();
    loading();
    try {
      final result = await userRepo.changePassword(param);
      success(result);
    } on Exception catch (e) {
      error(toFailure(e));
    }
  }

  final cachedFunction = useCallback(changePassword, []);
  return cachedFunction;
}
