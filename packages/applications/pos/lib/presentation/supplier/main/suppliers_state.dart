// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:pos/domain/model/supplier/supplier.dart';

@immutable
class SuppliersState {
  final List<Supplier> items;
  final bool loading;

  const SuppliersState({
    this.items = const [],
    this.loading = false,
  });

  SuppliersState copyWith({
    List<Supplier>? items,
    bool? loading,
  }) {
    return SuppliersState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
    );
  }
}
