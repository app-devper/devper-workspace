// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/usecase/customer/get_customer_by_id_use_case.dart';
import 'package:pos/presentation/customer/main/customer_state.dart';

class CustomerViewModel {
  final GetCustomerByIdUseCase getCustomerByIdUseCase;

  CustomerViewModel({
    required this.getCustomerByIdUseCase,
  });

  final _state = ValueNotifier<CustomerState>(const CustomerState());

  ValueListenable<CustomerState> get state => _state;

  Future<void> getCustomerById(String id) async {
    _state.value = _state.value.copyWith(task: const CustomerRunning());
    try {
      final loaded = await getCustomerByIdUseCase(id);
      _state.value = _state.value.copyWith(task: CustomerLoaded(loaded));
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(task: CustomerFailed(toFailure(e)));
    }
  }

  void consumeError() {
    if (_state.value.task is CustomerFailed) {
      _state.value = _state.value.copyWith(task: const CustomerTask());
    }
  }

  void consumeLoaded() {
    if (_state.value.task is CustomerLoaded) {
      _state.value = _state.value.copyWith(task: const CustomerTask());
    }
  }

  void dispose() {
    _state.dispose();
  }
}
