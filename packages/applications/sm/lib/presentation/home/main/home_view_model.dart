// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:common/core/state/one_shot.dart';
import 'package:um/domain/usecase/auth_use_cases.dart';

// Project imports:
import 'package:sm/domain/model/system/param.dart';
import 'package:sm/domain/usecase/system/create_system_use_case.dart';
import 'package:sm/domain/usecase/system/get_systems_use_case.dart';
import 'package:sm/domain/usecase/system/remove_system_by_id_use_case.dart';
import 'package:sm/domain/usecase/system/update_system_by_id_use_case.dart';
import 'home_state.dart';

class HomeViewModel {
  final GetSystemsUseCase getSystemsUseCase;
  final CreateSystemUseCase createSystemUseCase;
  final UpdateSystemByIdUseCase updateSystemByIdUseCase;
  final RemoveSystemByIdUseCase removeSystemByIdUseCase;
  final GetRoleUseCase getRoleUseCase;
  final LogoutUseCase logoutUseCase;

  HomeViewModel({
    required this.getSystemsUseCase,
    required this.createSystemUseCase,
    required this.updateSystemByIdUseCase,
    required this.removeSystemByIdUseCase,
    required this.getRoleUseCase,
    required this.logoutUseCase,
  });

  final _state = ValueNotifier<HomeState>(const HomeState());
  final _errors = OneShot<String>();
  final _loggedOut = OneShot<void>();

  ValueListenable<HomeState> get state => _state;

  Stream<String> get errors => _errors.stream;

  /// The session is over; the screen leaves for the login page. This used to
  /// be a flag nothing ever cleared, so every later notification would have
  /// pushed the login route again.
  Stream<void> get loggedOut => _loggedOut.stream;

  Future<void> loadRole() async {
    try {
      _state.value = _state.value.copyWith(role: await getRoleUseCase());
    } on Exception catch (_) {
      _state.value = _state.value.copyWith(role: '');
    }
  }

  Future<void> getSystems() async {
    _state.value = _state.value.copyWith(loading: true);
    try {
      final items = await getSystemsUseCase();
      _state.value = _state.value.copyWith(loading: false, items: items);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(loading: false);
      _errors.emit(toFailure(e).getMessage());
    }
  }

  Future<void> createSystem(CreateParam param) async {
    _state.value = _state.value.copyWith(loading: true);
    try {
      await createSystemUseCase(param);
      await getSystems();
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(loading: false);
      _errors.emit(toFailure(e).getMessage());
    }
  }

  Future<void> updateSystemById(UpdateSystemParam param) async {
    _state.value = _state.value.copyWith(loading: true);
    try {
      await updateSystemByIdUseCase(param);
      await getSystems();
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(loading: false);
      _errors.emit(toFailure(e).getMessage());
    }
  }

  Future<void> removeSystemById(String systemId) async {
    _state.value = _state.value.copyWith(loading: true);
    try {
      await removeSystemByIdUseCase(systemId);
      await getSystems();
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(loading: false);
      _errors.emit(toFailure(e).getMessage());
    }
  }

  Future<void> logout() async {
    try {
      await logoutUseCase();
    } on Exception catch (_) {
      // Log out locally even when the server call fails.
    }
    _loggedOut.emit(null);
  }

  void dispose() {
    _state.dispose();
    _errors.dispose();
    _loggedOut.dispose();
  }
}
