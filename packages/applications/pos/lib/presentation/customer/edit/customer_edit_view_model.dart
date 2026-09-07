// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/customer/param.dart';
import 'package:pos/domain/usecase/customer/remove_customer_by_id_use_case.dart';
import 'package:pos/domain/usecase/customer/update_customer_by_id_use_case.dart';
import 'package:pos/presentation/customer/edit/customer_edit_state.dart';

class CustomerEditViewModel {
  final UpdateCustomerByIdUseCase updateCustomerByIdUseCase;
  final RemoveCustomerByIdUseCase removeCustomerByIdUseCase;

  CustomerEditViewModel({
    required this.updateCustomerByIdUseCase,
    required this.removeCustomerByIdUseCase,
  });

  final _state = ValueNotifier<CustomerEditState>(const CustomerEditState());

  ValueListenable<CustomerEditState> get state => _state;

  Future<void> updateCustomerById(String customerId, CustomerParam param) async {
    _state.value = _state.value.copyWith(loading: true, clearError: true, clearUpdated: true);
    try {
      final updated = await updateCustomerByIdUseCase(
        CustomerUpdateParam(customerId: customerId, param: param),
      );
      _state.value = _state.value.copyWith(loading: false, updated: updated);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(loading: false, error: toFailure(e).getMessage());
    }
  }

  Future<void> removeCustomerById(String customerId) async {
    _state.value = _state.value.copyWith(loading: true, clearError: true, clearRemoved: true);
    try {
      final removed = await removeCustomerByIdUseCase(customerId);
      _state.value = _state.value.copyWith(loading: false, removed: removed);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(loading: false, error: toFailure(e).getMessage());
    }
  }

  void consumeError() {
    if (_state.value.error != null) {
      _state.value = _state.value.copyWith(clearError: true);
    }
  }

  void consumeUpdated() {
    if (_state.value.updated != null) {
      _state.value = _state.value.copyWith(clearUpdated: true);
    }
  }

  void consumeRemoved() {
    if (_state.value.removed != null) {
      _state.value = _state.value.copyWith(clearRemoved: true);
    }
  }

  void dispose() {
    _state.dispose();
  }
}
