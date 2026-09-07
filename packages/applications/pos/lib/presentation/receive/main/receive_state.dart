// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:pos/domain/model/receive/receive.dart';

@immutable
class ReceivesState {
  final List<Receive> items;
  final bool loading;
  final String? error;

  const ReceivesState({
    this.items = const [],
    this.loading = false,
    this.error,
  });

  ReceivesState copyWith({
    List<Receive>? items,
    bool? loading,
    String? error,
    bool clearError = false,
  }) {
    return ReceivesState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
