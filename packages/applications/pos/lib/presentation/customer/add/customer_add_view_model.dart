// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/customer/param.dart';
import 'package:pos/domain/repositories/customer_repository.dart';
import 'package:pos/presentation/customer/add/customer_add_state.dart';

class CustomerAddViewModel {
  final CustomerRepository customerRepo;

  CustomerAddViewModel({
    required this.customerRepo,
  });

  final _state = ValueNotifier<CustomerAddState>(const CustomerAddState());

  ValueListenable<CustomerAddState> get state => _state;

  Future<void> createCustomer(CustomerParam param) async {
    _state.value = _state.value.copyWith(saving: true, clearError: true, clearCreated: true);
    try {
      final created = await customerRepo.createCustomer(param);
      _state.value = _state.value.copyWith(saving: false, created: created);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(saving: false, error: toFailure(e).getMessage());
    }
  }

  void consumeError() {
    if (_state.value.error != null) {
      _state.value = _state.value.copyWith(clearError: true);
    }
  }

  void consumeCreated() {
    if (_state.value.created != null) {
      _state.value = _state.value.copyWith(clearCreated: true);
    }
  }

  void dispose() {
    _state.dispose();
  }
}
