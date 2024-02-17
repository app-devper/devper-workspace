// Dart imports:
import 'dart:async';

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:um/domain/repositories/login_repository.dart';

// Project imports:
import 'package:sm/domain/model/system/system.dart';
import 'package:sm/domain/repositories/system_repository.dart';
import 'package:sm/presentation/home/main/home_state.dart';

class HomeViewModel {
  final SystemRepository systemRepo;
  final LoginRepository loginRepo;

  HomeViewModel({
    required this.systemRepo,
    required this.loginRepo,
  });

  final _states = StreamController<HomeState>();

  StreamController<HomeState> get states => _states;

  final _systems = StreamController<List<System>>();

  StreamController<List<System>> get systems => _systems;

  void getSystems() async {
    try {
      final result = await systemRepo.getSystems();
      _onGetSystemSuccess(result);
    } on Exception catch (e ) {
      _onError(toFailure(e));
    }
  }

  void checkLogin() async {
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
    } on Exception catch (_) {
    }
    _onLogoutSuccess();
  }

  _onLoading() {
    _states.sink.add(LoadingState());
  }

  _onCheckLoginSuccess(bool isLogin) {
    _states.sink.add((LoggedState(isLogin)));
  }

  _onGetSystemSuccess(List<System> data) {
    _systems.sink.add(data);
    _states.sink.add((SystemState()));
  }

  _onLogoutSuccess() {
    _states.sink.add((LogoutState()));
  }

  _onError(Failure failure) {
    if (!_states.isClosed) {
      _states.sink.add(ErrorState(failure.error));
    }
  }

  dispose() {
    _states.close();
  }
}
