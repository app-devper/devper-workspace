// Dart imports:
import 'dart:async';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/customer/customer.dart';
import 'package:pos/domain/repositories/customer_repository.dart';
import 'package:pos/presentation/customer/main/customer_state.dart';

class CustomersViewModel {
  final CustomerRepository customerRepo;

  CustomersViewModel({
    required this.customerRepo,
  });

  final _customers = StreamController<List<Customer>>();

  Stream<List<Customer>> get customers => _customers.stream;

  void getCustomers() async {
    try {
      final result = await customerRepo.getLocalCustomers();
      _onListCustomers(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  _onListCustomers(List<Customer> data) {
    if (!_customers.isClosed) {
      _customers.sink.add(data);
    }
  }

  _onError(Failure failure) {
    if (!_customers.isClosed) {
      _customers.sink.addError(failure.getMessage());
    }
  }

  dispose() {
    _customers.close();
  }
}
