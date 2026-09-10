// Dart imports:
import 'dart:async';

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// Project imports:
import 'package:um/container.dart';
import 'package:um/domain/entities/user/user.dart';
import 'package:um/domain/usecase/user_use_cases.dart';

Future<User> useUserId(String userId) {
  Future<User> getUserId() async {
    final action = sl<GetUserUseCase>();
    try {
      final result = await action(userId);
      return result;
    } on Exception catch (e) {
      return Future.error(toFailure(e));
    }
  }

  final data = useMemoized(getUserId, [userId]);
  return data;
}
