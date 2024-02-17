// Dart imports:
import 'dart:async';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/customer/customer.dart';
import 'package:pos/domain/repositories/customer_repository.dart';
import 'package:pos/presentation/customer/main/customer_state.dart';

class CustomerViewModel {
  final CustomerRepository customerRepo;

  CustomerViewModel({
    required this.customerRepo,
  });

  final _states = StreamController<CustomerState>();

  Stream<CustomerState> get states => _states.stream;

  final _customers = StreamController<List<Customer>>();

  Stream<List<Customer>> get customers => _customers.stream;

  void getCustomers() async {
    try {
      final result = await customerRepo.getCustomers();
      _onListCustomers(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  void setCustomers(List<Customer> data) {
    _customers.sink.add(data);
  }

  _onLoading() {
    _states.sink.add(LoadingState());
  }

  _onListCustomers(List<Customer> data) {
    if (!_states.isClosed) {
      _states.sink.add(ListCustomerState(data: data));
    }
  }

  _onError(Failure failure) {
    if (!_states.isClosed) {
      _states.sink.add(ErrorState(message: failure.getMessage()));
    }
  }

  dispose() {
    _states.close();
    _customers.close();
  }
}
