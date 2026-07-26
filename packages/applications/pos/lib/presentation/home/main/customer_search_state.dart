import 'package:flutter/foundation.dart';
import 'package:pos/domain/model/customer/customer.dart';

@immutable
class CustomerSearchState {
  final List<Customer> items;
  final bool loading;
  final String? error;

  const CustomerSearchState({
    this.items = const [],
    this.loading = false,
    this.error,
  });

  CustomerSearchState copyWith({
    List<Customer>? items,
    bool? loading,
    String? error,
    bool clearError = false,
  }) {
    return CustomerSearchState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
