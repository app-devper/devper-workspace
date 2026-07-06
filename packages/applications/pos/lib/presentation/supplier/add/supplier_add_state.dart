// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:pos/domain/model/supplier/supplier.dart';

@immutable
class SupplierAddState {
  final bool saving;
  final String? error;
  final Supplier? created;

  const SupplierAddState({
    this.saving = false,
    this.error,
    this.created,
  });

  SupplierAddState copyWith({
    bool? saving,
    String? error,
    Supplier? created,
    bool clearError = false,
    bool clearCreated = false,
  }) {
    return SupplierAddState(
      saving: saving ?? this.saving,
      error: clearError ? null : (error ?? this.error),
      created: clearCreated ? null : (created ?? this.created),
    );
  }
}
