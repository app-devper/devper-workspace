// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:common/core/ext/widget_ext.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// Project imports:
import 'package:um/container.dart';
import 'package:um/domain/repositories/login_repository.dart';

Function() useLogout(
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

  logoutUser() async {
    final loginRepo = sl<LoginRepository>();
    loading();
    final _ = await loginRepo.logoutUser();
    success();
  }

  final cachedFunction = useCallback(logoutUser, []);
  return cachedFunction;
}
