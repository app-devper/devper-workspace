// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:common/core/state/one_shot.dart';

// Project imports:
import 'package:pos/domain/model/customer/customer.dart';
import 'package:pos/domain/usecase/customer/get_customer_by_id_use_case.dart';
import 'package:pos/presentation/customer/main/customer_state.dart';

class CustomerViewModel {
  final GetCustomerByIdUseCase getCustomerByIdUseCase;

  CustomerViewModel({
    required this.getCustomerByIdUseCase,
  });

  final _state = ValueNotifier<CustomerState>(const CustomerState());

  /// Delivered once: the page swaps to the info panel on it.
  final _loaded = OneShot<Customer>();
  final _errors = OneShot<String>();

  ValueListenable<CustomerState> get state => _state;

  Stream<Customer> get loaded => _loaded.stream;

  Stream<String> get errors => _errors.stream;

  Future<void> getCustomerById(String id) async {
    if (_state.value.loading) return;
    _state.value = _state.value.copyWith(loading: true);
    try {
      _loaded.emit(await getCustomerByIdUseCase(id));
    } on Exception catch (e) {
      _errors.emit(toFailure(e).getMessage());
    } finally {
      _state.value = _state.value.copyWith(loading: false);
    }
  }

  void dispose() {
    _state.dispose();
    _loaded.dispose();
    _errors.dispose();
  }
}
