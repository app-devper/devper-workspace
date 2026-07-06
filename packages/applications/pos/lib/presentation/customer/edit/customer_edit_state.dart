// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:pos/domain/model/customer/customer.dart';

@immutable
class CustomerEditState {
  final bool loading;
  final String? error;
  final Customer? updated;
  final Customer? removed;

  const CustomerEditState({
    this.loading = false,
    this.error,
    this.updated,
    this.removed,
  });

  CustomerEditState copyWith({
    bool? loading,
    String? error,
    Customer? updated,
    Customer? removed,
    bool clearError = false,
    bool clearUpdated = false,
    bool clearRemoved = false,
  }) {
    return CustomerEditState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      updated: clearUpdated ? null : (updated ?? this.updated),
      removed: clearRemoved ? null : (removed ?? this.removed),
    );
  }
}
