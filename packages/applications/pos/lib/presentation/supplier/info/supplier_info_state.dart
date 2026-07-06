// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:pos/domain/model/supplier/supplier.dart';

@immutable
class SupplierInfoState {
  final Supplier? supplier;
  final bool saving;
  final String? error;
  final Supplier? updated;

  const SupplierInfoState({
    this.supplier,
    this.saving = false,
    this.error,
    this.updated,
  });

  SupplierInfoState copyWith({
    Supplier? supplier,
    bool? saving,
    String? error,
    Supplier? updated,
    bool clearError = false,
    bool clearUpdated = false,
  }) {
    return SupplierInfoState(
      supplier: supplier ?? this.supplier,
      saving: saving ?? this.saving,
      error: clearError ? null : (error ?? this.error),
      updated: clearUpdated ? null : (updated ?? this.updated),
    );
  }
}
