// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:um/domain/repositories/login_repository.dart';

// Project imports:
import 'home_state.dart';

class HomeViewModel {
  final LoginRepository loginRepo;

  HomeViewModel({
    required this.loginRepo,
  });

  final _state = ValueNotifier<HomeState>(const HomeState());

  ValueListenable<HomeState> get state => _state;

  Future<void> prepareData() async {
    await getRole();
  }

  Future<void> getRole() async {
    try {
      final role = await loginRepo.getRole();
      _state.value = _state.value.copyWith(isAdmin: role == "ADMIN");
    } on Exception catch (_) {
      _state.value = _state.value.copyWith(isAdmin: false);
    }
  }

  Future<void> logout() async {
    try {
      await loginRepo.logoutUser();
    } on Exception catch (_) {}
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

  void dispose() {
    _state.dispose();
  }
}
