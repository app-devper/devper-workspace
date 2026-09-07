// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:common/core/ext/widget_ext.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// Project imports:
import 'package:um/container.dart';
import 'package:um/domain/entities/auth/param.dart';
import 'package:um/domain/entities/auth/system.dart';
import 'package:um/domain/repositories/login_repository.dart';

Function(LoginParam) useLogin(
  BuildContext context, {
  required Function(System) onSuccess,
}) {
  loading() {
    showLoadingDialog(context);
  }

  success(System system) {
    hideLoadingDialog(context);
    onSuccess(system);
  }

  error(Failure failure) {
    hideLoadingDialog(context);
    showAlertDialog(context, failure.getMessage(), () {});
  }

  loginUser(LoginParam param) async {
    final loginRepo = sl<LoginRepository>();
    loading();
    try {
      final session = await loginRepo.loginUser(param);
      success(session.system);
    } on Exception catch (e) {
      error(toFailure(e));
    }
  }

  final cachedFunction = useCallback(loginUser, []);
  return cachedFunction;
}
