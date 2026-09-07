// Dart imports:
import 'dart:async';

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// Project imports:
import 'package:um/container.dart';
import 'package:um/domain/entities/auth/user_session.dart';
import 'package:um/domain/repositories/login_repository.dart';

Future<List<UserSession>> useSessions([List<Object?> keys = const []]) {
  Future<List<UserSession>> getSessions() async {
    final loginRepo = sl<LoginRepository>();
    try {
      return await loginRepo.getSessions();
    } on Exception catch (e) {
      return Future.error(toFailure(e));
    }
  }

  return useMemoized(getSessions, keys);
}
