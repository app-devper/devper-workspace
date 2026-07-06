// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/repositories/customer_repository.dart';
import 'package:pos/presentation/customer/main/customer_state.dart';

class CustomerViewModel {
  final CustomerRepository customerRepo;

  CustomerViewModel({
    required this.customerRepo,
  });

  final _state = ValueNotifier<CustomerState>(const CustomerState());

  ValueListenable<CustomerState> get state => _state;

  Future<void> getCustomerById(String id) async {
    _state.value = _state.value.copyWith(loading: true, clearError: true, clearLoaded: true);
    try {
      final loaded = await customerRepo.getCustomerById(id);
      _state.value = _state.value.copyWith(loading: false, loaded: loaded);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(loading: false, error: toFailure(e).getMessage());
    }
  }

  void consumeError() {
    if (_state.value.error != null) {
      _state.value = _state.value.copyWith(clearError: true);
    }
  }

  void consumeLoaded() {
    if (_state.value.loaded != null) {
      _state.value = _state.value.copyWith(clearLoaded: true);
    }
  }

  void dispose() {
    _state.dispose();
  }
}
