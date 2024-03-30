// Dart imports:
import 'dart:async';

// Project imports:
import 'package:pos/domain/model/customer/customer.dart';
import 'package:pos/domain/repositories/customer_repository.dart';

class CustomerSearchViewModel {
  final CustomerRepository customerRepo;

  CustomerSearchViewModel({
    required this.customerRepo,
  });

  final _customerItems = StreamController<List<Customer>>();

  Stream<List<Customer>> get customerItems => _customerItems.stream;

  List<Customer> _customers = [];

  void getCacheCustomers() async {
    try {
      _customers = await customerRepo.getLocalCustomers();
      _onSearchCustomerSuccess(_customers);
    } on Exception catch (_) {}
  }

  void searchCustomer(String term) {
    if (term.isEmpty) {
      _onSearchCustomerSuccess(_customers);
    } else {
      List<Customer> filtered = [];
      for (var item in _customers) {
        if (item.name.toLowerCase().contains(term.toLowerCase()) || item.phone.contains(term)) {
          filtered.add(item);
        }
      }
      _onSearchCustomerSuccess(filtered);
    }
  }

  void _onSearchCustomerSuccess(List<Customer> customers) {
    if (!_customerItems.isClosed) {
      _customerItems.sink.add(customers);
    }
  }

  dispose() {
    _customerItems.close();
  }
}
