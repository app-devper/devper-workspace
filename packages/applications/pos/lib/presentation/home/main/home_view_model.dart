// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/state/one_shot.dart';

// Package imports:
import 'package:um/domain/usecase/auth_use_cases.dart';

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

  /// Signalled once, when the session ends and the screen should return to
  /// login. Nothing draws it.
  final _loggedOut = OneShot<void>();

  ValueListenable<HomeState> get state => _state;

  Stream<void> get loggedOut => _loggedOut.stream;

  Future<void> prepareData() async {
    await getRole();
  }

  Future<void> getRole() async {
    try {
      final role = await getRoleUseCase();
      _state.value = _state.value.copyWith(isAdmin: role == "ADMIN");
    } on Exception catch (_) {
      _state.value = _state.value.copyWith(isAdmin: false);
    }
  }

  Future<void> logout() async {
    try {
      await logoutUseCase();
    } on Exception catch (_) {}
    _loggedOut.emit(null);
  }

  void dispose() {
    _state.dispose();
    _loggedOut.dispose();
  }
}
