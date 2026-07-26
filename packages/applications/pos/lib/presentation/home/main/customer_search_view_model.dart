// Flutter imports:
import 'package:flutter/foundation.dart';

import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/customer/customer.dart';
import 'package:pos/domain/usecase/customer/get_local_customers_use_case.dart';
import 'package:pos/presentation/home/main/customer_search_state.dart';

class CustomerSearchViewModel {
  final GetLocalCustomersUseCase getLocalCustomersUseCase;

  CustomerSearchViewModel({
    required this.getLocalCustomersUseCase,
  });

  final _state =
      ValueNotifier<CustomerSearchState>(const CustomerSearchState());

  ValueListenable<CustomerSearchState> get state => _state;

  List<Customer> _customers = [];

  Future<void> getCacheCustomers() async {
    _state.value = _state.value.copyWith(loading: true, clearError: true);
    try {
      _customers = await getLocalCustomersUseCase();
      _state.value = _state.value.copyWith(loading: false, items: _customers);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(
        loading: false,
        error: toFailure(e).getMessage(),
      );
    }
  }

  void searchCustomer(String term) {
    if (term.isEmpty) {
      _state.value = _state.value.copyWith(items: _customers);
    } else {
      final lower = term.toLowerCase();
      _state.value = _state.value.copyWith(
          items: _customers
              .where((item) =>
                  item.name.toLowerCase().contains(lower) ||
                  item.phone.contains(term))
              .toList());
    }
  }

  void dispose() {
    _state.dispose();
  }
}
