// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/usecase/customer/get_local_customers_use_case.dart';
import 'package:pos/presentation/customer/main/customers_state.dart';

class CustomersViewModel {
  final GetLocalCustomersUseCase getLocalCustomersUseCase;

  CustomersViewModel({
    required this.getLocalCustomersUseCase,
  });

  final _state = ValueNotifier<CustomersState>(const CustomersState());

  ValueListenable<CustomersState> get state => _state;

  Future<void> getCustomers() async {
    _state.value = _state.value.copyWith(loading: true, clearError: true);
    try {
      final items = await getLocalCustomersUseCase();
      _state.value = _state.value.copyWith(loading: false, items: items);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(loading: false, error: toFailure(e).getMessage());
    }
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
