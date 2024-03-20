// Dart imports:
import 'dart:async';

// Package imports:
import 'package:um/domain/repositories/login_repository.dart';

// Project imports:
import 'home_state.dart';

class HomeViewModel {
  final LoginRepository loginRepo;

  HomeViewModel({
    required this.loginRepo,
  });

  final _states = StreamController<HomeState>();

  Stream<HomeState> get states => _states.stream;

  void prepareData() async {
    getRole();
  }

  void getRole() async {
    try {
      final result = await loginRepo.getRole();
      _onCheckLoginSuccess(result == "ADMIN");
    } on Exception catch (_) {
      _onCheckLoginSuccess(false);
    }
  }

  void logout() async {
    try {
      final result = await loginRepo.logoutUser();
      _onLogoutSuccess(result);
    } on Exception catch (_) {
      _onLogoutSuccess(true);
    }
  }

  _onLoading() {
    _states.sink.add(LoadingState());
  }

  _onCheckLoginSuccess(bool isLogin) {
    _states.sink.add((CheckRoleState(isLogin)));
  }

  _onLogoutSuccess(bool data) {
    _states.sink.add((LogoutState()));
  }

  dispose() {
    _states.close();
  }
}
