// Dart imports:
import 'dart:async';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/customer/customer.dart';
import 'package:pos/domain/model/customer/param.dart';
import 'package:pos/domain/repositories/customer_repository.dart';
import 'package:pos/presentation/customer/edit/customer_edit_state.dart';

class CustomerEditViewModel {
  final CustomerRepository customerRepo;

  CustomerEditViewModel({
    required this.customerRepo,
  });

  final _states = StreamController<CustomerEditState>();

  Stream<CustomerEditState> get states => _states.stream;

  getCustomerById(String customerId) async {
    _onLoading();
    try {
      final result = await customerRepo.getCustomerById(customerId);
      _onGetCustomer(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  updateCustomerById(String customerId, CustomerParam param) async {
    _onLoading();
    try {
      final result = await customerRepo.updateCustomerById(customerId, param);
      _onEditCustomer(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  removeCustomerById(String customerId) async {
    _onLoading();
    try {
      final result = await customerRepo.removeCustomerById(customerId);
      _onRemoveCustomer(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  _onLoading() {
    _states.sink.add(LoadingState());
  }

  _onRemoveCustomer(Customer data) {
    if (!_states.isClosed) {
      _states.sink.add(RemoveCustomerState(data: data));
    }
  }

  _onGetCustomer(Customer data) {
    if (!_states.isClosed) {
      _states.sink.add(GetCustomerState(data: data));
    }
  }

  _onEditCustomer(Customer data) {
    if (!_states.isClosed) {
      _states.sink.add(UpdateCustomerState(data: data));
    }
  }

  _onError(Failure failure) {
    if (!_states.isClosed) {
      _states.sink.add(ErrorState(message: failure.getMessage()));
    }
  }

  dispose() {
    _states.close();
  }
}
