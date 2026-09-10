// Dart imports:
import 'dart:async';

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// Project imports:
import 'package:um/container.dart';
import 'package:um/domain/entities/auth/user_session.dart';
import 'package:um/domain/usecase/auth_use_cases.dart';

Future<List<UserSession>> useSessions([List<Object?> keys = const []]) {
  Future<List<UserSession>> getSessions() async {
    final action = sl<GetSessionsUseCase>();
    try {
      return await action();
    } on Exception catch (e) {
      return Future.error(toFailure(e));
    }
  }

  return useMemoized(getSessions, keys);
}
