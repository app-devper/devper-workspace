// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// Project imports:
import 'package:um/container.dart';
import 'package:um/domain/entities/auth/system.dart';
import 'package:um/domain/usecase/auth_use_cases.dart';

Future<System> Function() useKeepAlive() {
  Future<System> keepAlive() async {
    final action = sl<RestoreSessionUseCase>();
    try {
      final result = await action();
      return result;
    } on Exception catch (e) {
      return Future.error(toFailure(e));
    }
  }

  final cachedFunction = useCallback(keepAlive, []);
  return cachedFunction;
}
