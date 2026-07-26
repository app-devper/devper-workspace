// Flutter imports:
import 'package:flutter/foundation.dart';

import 'package:common/core/error/failure.dart';

// Package imports:
import 'package:um/domain/usecase/auth/get_role_use_case.dart';
import 'package:um/domain/usecase/auth/logout_use_case.dart';

// Project imports:
import 'home_state.dart';

class HomeViewModel {
  final GetRoleUseCase getRoleUseCase;
  final LogoutUseCase logoutUseCase;

  HomeViewModel({
    required this.getRoleUseCase,
    required this.logoutUseCase,
  });

  final _state = ValueNotifier<HomeState>(const HomeState());

  ValueListenable<HomeState> get state => _state;

  Future<void> prepareData() async {
    await getRole();
  }

  Future<void> getRole() async {
    _state.value = _state.value.copyWith(clearError: true);
    try {
      final role = await getRoleUseCase();
      _state.value = _state.value.copyWith(isAdmin: role == "ADMIN");
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(
        isAdmin: false,
        error: toFailure(e).getMessage(),
      );
    }
  }

  Future<void> logout() async {
    try {
      await logoutUseCase();
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(error: toFailure(e).getMessage());
    }
    _state.value = _state.value.copyWith(loggedOut: true);
  }

  void consumeIsAdmin() {
    if (_state.value.isAdmin != null) {
      _state.value = _state.value.copyWith(clearIsAdmin: true);
    }
  }

  void consumeLoggedOut() {
    if (_state.value.loggedOut) {
      _state.value = _state.value.copyWith(clearLoggedOut: true);
    }
  }

  void consumeError() {
    if (_state.value.error != null) {
      _state.value = _state.value.copyWith(clearError: true);
    }
  }

  void dispose() {
    _state.dispose();
  }
}
