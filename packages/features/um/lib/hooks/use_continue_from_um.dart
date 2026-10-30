// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// Project imports:
import 'package:um/container.dart';
import 'package:um/domain/entities/auth/system.dart';
import 'package:um/domain/usecase/auth_use_cases.dart';

/// Starts a session from the ticket UM handed over (um-api ADR-0011).
Future<System> Function(String ticket, String system) useContinueFromUm() {
  Future<System> continueFromUm(String ticket, String system) async {
    try {
      return await sl<ContinueFromUmUseCase>()(ticket, system);
    } on Exception catch (e) {
      return Future.error(toFailure(e));
    }
  }

  return useCallback(continueFromUm, []);
}
