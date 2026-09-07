// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:common/core/ext/widget_ext.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// Project imports:
import 'package:um/container.dart';
import 'package:um/domain/repositories/login_repository.dart';

Function(String) useRevokeSession(
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

  revokeSession(String sessionId) async {
    final loginRepo = sl<LoginRepository>();
    loading();
    try {
      await loginRepo.revokeSessionById(sessionId);
      success();
    } on Exception catch (e) {
      error(toFailure(e));
    }
  }

  final cachedFunction = useCallback(revokeSession, []);
  return cachedFunction;
}
