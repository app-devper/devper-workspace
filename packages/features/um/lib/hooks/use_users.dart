// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// Project imports:
import 'package:um/container.dart';
import 'package:um/domain/entities/user/user.dart';
import 'package:um/domain/usecase/user_use_cases.dart';

Future<List<User>> useUsers(UniqueKey reloadKey) {
  Future<List<User>> getUsers() async {
    final action = sl<GetUsersUseCase>();
    try {
      final result = await action();
      return result;
    } on Exception catch (e) {
      return Future.error(toFailure(e));
    }
  }

  final data = useMemoized(getUsers, [reloadKey]);
  return data;
}
