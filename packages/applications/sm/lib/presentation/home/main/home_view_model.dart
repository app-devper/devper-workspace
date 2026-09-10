// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';
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

  ValueListenable<HomeState> get state => _state;

  Future<void> loadRole() async {
    try {
      _state.value = _state.value.copyWith(role: await getRoleUseCase());
    } on Exception catch (_) {
      _state.value = _state.value.copyWith(role: '');
    }
  }

  Future<void> getSystems() async {
    _state.value = _state.value.copyWith(loading: true, clearError: true);
    try {
      final items = await getSystemsUseCase();
      _state.value = _state.value.copyWith(loading: false, items: items);
    } on Exception catch (e) {
      _state.value = _state.value
          .copyWith(loading: false, error: toFailure(e).getMessage());
    }
  }

  Future<void> createSystem(CreateParam param) async {
    _state.value = _state.value.copyWith(loading: true, clearError: true);
    try {
      await createSystemUseCase(param);
      await getSystems();
    } on Exception catch (e) {
      _state.value = _state.value
          .copyWith(loading: false, error: toFailure(e).getMessage());
    }
  }

  Future<void> updateSystemById(UpdateSystemParam param) async {
    _state.value = _state.value.copyWith(loading: true, clearError: true);
    try {
      await updateSystemByIdUseCase(param);
      await getSystems();
    } on Exception catch (e) {
      _state.value = _state.value
          .copyWith(loading: false, error: toFailure(e).getMessage());
    }
  }

  Future<void> removeSystemById(String systemId) async {
    _state.value = _state.value.copyWith(loading: true, clearError: true);
    try {
      await removeSystemByIdUseCase(systemId);
      await getSystems();
    } on Exception catch (e) {
      _state.value = _state.value
          .copyWith(loading: false, error: toFailure(e).getMessage());
    }
  }

  Future<void> logout() async {
    try {
      await logoutUseCase();
    } on Exception catch (_) {
      // Log out locally even when the server call fails.
    }
    _state.value = _state.value.copyWith(loggedOut: true);
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
