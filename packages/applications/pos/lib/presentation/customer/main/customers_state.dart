// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:pos/domain/model/customer/customer.dart';

@immutable
class CustomersState {
  final List<Customer> items;
  final bool loading;
  final String? error;

  const CustomersState({
    this.items = const [],
    this.loading = false,
    this.error,
  });

  CustomersState copyWith({
    List<Customer>? items,
    bool? loading,
    String? error,
    bool clearError = false,
  }) {
    return CustomersState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
