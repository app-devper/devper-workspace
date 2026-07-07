// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:pos/domain/model/customer/customer.dart';
import 'package:pos/domain/repositories/customer_repository.dart';

class CustomerSearchViewModel {
  final CustomerRepository customerRepo;

  CustomerSearchViewModel({
    required this.customerRepo,
  });

  final _items = ValueNotifier<List<Customer>?>(null);

  ValueListenable<List<Customer>?> get items => _items;

  List<Customer> _customers = [];

  Future<void> getCacheCustomers() async {
    try {
      _customers = await customerRepo.getLocalCustomers();
      _items.value = _customers;
    } on Exception catch (_) {}
  }

  void searchCustomer(String term) {
    if (term.isEmpty) {
      _items.value = _customers;
    } else {
      final lower = term.toLowerCase();
      _items.value = _customers
          .where((item) => item.name.toLowerCase().contains(lower) || item.phone.contains(term))
          .toList();
    }
  }

  void dispose() {
    _items.dispose();
  }
}
