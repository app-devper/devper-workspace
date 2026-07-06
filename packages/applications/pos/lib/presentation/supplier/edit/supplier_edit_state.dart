// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:pos/domain/model/supplier/supplier.dart';

@immutable
class SupplierEditState {
  final bool loading;
  final String? error;
  final Supplier? updated;
  final Supplier? removed;

  const SupplierEditState({
    this.loading = false,
    this.error,
    this.updated,
    this.removed,
  });

  SupplierEditState copyWith({
    bool? loading,
    String? error,
    Supplier? updated,
    Supplier? removed,
    bool clearError = false,
    bool clearUpdated = false,
    bool clearRemoved = false,
  }) {
    return SupplierEditState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      updated: clearUpdated ? null : (updated ?? this.updated),
      removed: clearRemoved ? null : (removed ?? this.removed),
    );
  }
}
