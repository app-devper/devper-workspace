// Dart imports:
import 'dart:async';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/customer/customer.dart';
import 'package:pos/domain/model/customer/param.dart';
import 'package:pos/domain/repositories/customer_repository.dart';
import 'package:pos/presentation/customer/add/customer_add_state.dart';

class CustomerAddViewModel {
  final CustomerRepository customerRepo;

  CustomerAddViewModel({
    required this.customerRepo,
  });

  final _states = StreamController<CustomerAddState>();

  Stream<CustomerAddState> get states => _states.stream;

  void createCustomer(CustomerParam param) async {
    _onLoading();
    try {
      final result = await customerRepo.createCustomer(param);
      _onCreateCustomer(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  _onLoading() {
    _states.sink.add(LoadingState());
  }

  _onCreateCustomer(Customer data) {
    if (!_states.isClosed) {
      _states.sink.add(CreateCustomerState(data: data));
    }
  }

  _onError(Failure failure) {
    if (!_states.isClosed) {
      _states.sink.add(ErrorState(message: failure.getMessage()));
    }
  }

  dispose() {
    _states.close();
  }
}
