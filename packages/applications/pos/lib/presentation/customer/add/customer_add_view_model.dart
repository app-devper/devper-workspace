// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/customer/param.dart';
import 'package:pos/domain/usecase/customer/create_customer_use_case.dart';
import 'package:pos/presentation/customer/add/customer_add_state.dart';

class CustomerAddViewModel {
  final CreateCustomerUseCase createCustomerUseCase;

  CustomerAddViewModel({
    required this.createCustomerUseCase,
  });

  final _state = ValueNotifier<CustomerAddState>(const CustomerAddState());

  ValueListenable<CustomerAddState> get state => _state;

  Future<void> createCustomer(CustomerParam param) async {
    _state.value = _state.value.copyWith(task: const CustomerAddRunning());
    try {
      final created = await createCustomerUseCase(param);
      _state.value = _state.value.copyWith(task: CustomerAddCreated(created));
    } on Exception catch (e) {
      _state.value =
          _state.value.copyWith(task: CustomerAddFailed(toFailure(e)));
    }
  }

  void consumeError() {
    if (_state.value.task is CustomerAddFailed) {
      _state.value = _state.value.copyWith(task: const CustomerAddTask());
    }
  }

  void consumeCreated() {
    if (_state.value.task is CustomerAddCreated) {
      _state.value = _state.value.copyWith(task: const CustomerAddTask());
    }
  }

  void dispose() {
    _state.dispose();
  }
}
