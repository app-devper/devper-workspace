// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:common/core/state/one_shot.dart';

// Project imports:
import 'package:pos/domain/model/customer/customer.dart';
import 'package:pos/domain/model/customer/param.dart';
import 'package:pos/domain/usecase/customer/create_customer_use_case.dart';
import 'package:pos/presentation/customer/add/customer_add_state.dart';

class CustomerAddViewModel {
  final CreateCustomerUseCase createCustomerUseCase;

  CustomerAddViewModel({
    required this.createCustomerUseCase,
  });

  final _state = ValueNotifier<CustomerAddState>(const CustomerAddState());

  /// The two things the screen reacts to once each. Neither is drawn, so
  /// neither belongs in state, and there is nothing for the view to clear.
  final _created = OneShot<Customer>();
  final _errors = OneShot<String>();

  ValueListenable<CustomerAddState> get state => _state;

  Stream<Customer> get created => _created.stream;

  Stream<String> get errors => _errors.stream;

  Future<void> createCustomer(CustomerParam param) async {
    if (_state.value.saving) return;
    _state.value = _state.value.copyWith(saving: true);
    try {
      _created.emit(await createCustomerUseCase(param));
    } on Exception catch (e) {
      _errors.emit(toFailure(e).getMessage());
    } finally {
      _state.value = _state.value.copyWith(saving: false);
    }
  }

  void dispose() {
    _state.dispose();
    _created.dispose();
    _errors.dispose();
  }
}
