// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:pos/domain/model/supplier/supplier.dart';

@immutable
class SuppliersState {
  final List<Supplier> items;
  final bool loading;
  final String? error;

  const SuppliersState({
    this.items = const [],
    this.loading = false,
    this.error,
  });

  SuppliersState copyWith({
    List<Supplier>? items,
    bool? loading,
    String? error,
    bool clearError = false,
  }) {
    return SuppliersState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
