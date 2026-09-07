// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:common/core/ext/widget_ext.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// Project imports:
import 'package:um/container.dart';
import 'package:um/domain/repositories/login_repository.dart';

Function() useRevokeOtherSessions(
  BuildContext context, {
  required Function(int revoked) onSuccess,
}) {
  loading() {
    showLoadingDialog(context);
  }

  success(int revoked) {
    hideLoadingDialog(context);
    onSuccess(revoked);
  }

  error(Failure failure) {
    hideLoadingDialog(context);
    showAlertDialog(context, failure.getMessage(), () {});
  }

  revokeOtherSessions() async {
    final loginRepo = sl<LoginRepository>();
    loading();
    try {
      final revoked = await loginRepo.revokeOtherSessions();
      success(revoked);
    } on Exception catch (e) {
      error(toFailure(e));
    }
  }

  final cachedFunction = useCallback(revokeOtherSessions, []);
  return cachedFunction;
}
