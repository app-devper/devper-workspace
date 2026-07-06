// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:pos/domain/model/customer/customer.dart';

@immutable
class CustomerState {
  final bool loading;
  final String? error;
  final Customer? loaded;

  const CustomerState({
    this.loading = false,
    this.error,
    this.loaded,
  });

  CustomerState copyWith({
    bool? loading,
    String? error,
    Customer? loaded,
    bool clearError = false,
    bool clearLoaded = false,
  }) {
    return CustomerState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      loaded: clearLoaded ? null : (loaded ?? this.loaded),
    );
  }
}
