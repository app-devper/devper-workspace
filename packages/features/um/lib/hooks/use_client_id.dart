// Package imports:
import 'package:flutter_hooks/flutter_hooks.dart';

// Project imports:
import 'package:um/container.dart';
import 'package:um/domain/usecase/auth_use_cases.dart';

String useClientId() {
  getClientId() {
    final action = sl<GetClientIdUseCase>();
    return action();
  }

  final data = useMemoized(getClientId, []);
  return data;
}
