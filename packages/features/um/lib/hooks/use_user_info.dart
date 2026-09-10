// Dart imports:
import 'dart:async';

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// Project imports:
import 'package:um/container.dart';
import 'package:um/domain/entities/user/user.dart';
import 'package:um/domain/usecase/user_use_cases.dart';

Future<User> useUserInfo() {
  Future<User> getUserInfo() async {
    final action = sl<GetUserInfoUseCase>();
    try {
      final result = await action();
      return result;
    } on Exception catch (e) {
      return Future.error(toFailure(e));
    }
  }

  final data = useMemoized(getUserInfo, []);
  return data;
}
