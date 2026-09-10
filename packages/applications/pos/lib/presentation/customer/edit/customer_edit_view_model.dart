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
    if (_state.value is CustomerEditSaving) return;
    _state.value = const CustomerEditSaving();
    try {
      final updated = await updateCustomerByIdUseCase(
        CustomerUpdateParam(customerId: customerId, param: param),
      );
      _state.value = CustomerEditUpdated(updated);
    } on Exception catch (e) {
      _state.value = CustomerEditFailed(toFailure(e));
    }
  }

  Future<void> removeCustomerById(String customerId) async {
    if (_state.value is CustomerEditDeleting) return;
    _state.value = const CustomerEditDeleting();
    try {
      final removed = await removeCustomerByIdUseCase(customerId);
      _state.value = CustomerEditRemoved(removed);
    } on Exception catch (e) {
      _state.value = CustomerEditFailed(toFailure(e));
    }
  }

  void consumeError() {
    if (_state.value is CustomerEditFailed) {
      _state.value = const CustomerEditState();
    }
  }

  void consumeUpdated() {
    if (_state.value is CustomerEditUpdated) {
      _state.value = const CustomerEditState();
    }
  }

  void consumeRemoved() {
    if (_state.value is CustomerEditRemoved) {
      _state.value = const CustomerEditState();
    }
  }

  void dispose() {
    _state.dispose();
  }
}
