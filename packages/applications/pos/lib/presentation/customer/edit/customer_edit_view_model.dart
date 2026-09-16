// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:common/core/state/one_shot.dart';

// Project imports:
import 'package:pos/domain/model/customer/customer.dart';
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

  /// Each outcome reaches the view once: a snackbar, or a pop with the record.
  /// Neither is drawn, so neither sits in state waiting to be cleared.
  final _updated = OneShot<Customer>();
  final _removed = OneShot<Customer>();
  final _errors = OneShot<String>();

  ValueListenable<CustomerEditState> get state => _state;

  Stream<Customer> get updated => _updated.stream;

  Stream<Customer> get removed => _removed.stream;

  Stream<String> get errors => _errors.stream;

  Future<void> updateCustomerById(String customerId, CustomerParam param) async {
    if (_state.value.busy) return;
    _state.value = _state.value.copyWith(busy: true);
    try {
      _updated.emit(await updateCustomerByIdUseCase(
        CustomerUpdateParam(customerId: customerId, param: param),
      ));
    } on Exception catch (e) {
      _errors.emit(toFailure(e).getMessage());
    } finally {
      _state.value = _state.value.copyWith(busy: false);
    }
  }

  Future<void> removeCustomerById(String customerId) async {
    if (_state.value.busy) return;
    _state.value = _state.value.copyWith(busy: true);
    try {
      _removed.emit(await removeCustomerByIdUseCase(customerId));
    } on Exception catch (e) {
      _errors.emit(toFailure(e).getMessage());
    } finally {
      _state.value = _state.value.copyWith(busy: false);
    }
  }

  void dispose() {
    _state.dispose();
    _updated.dispose();
    _removed.dispose();
    _errors.dispose();
  }
}
