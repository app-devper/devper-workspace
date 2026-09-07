// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:sm/domain/model/system/system.dart';

@immutable
class HomeState {
  final List<System> items;
  final bool loading;
  final String? error;
  final bool loggedOut;

  const HomeState({
    this.items = const [],
    this.loading = false,
    this.error,
    this.loggedOut = false,
  });

  HomeState copyWith({
    List<System>? items,
    bool? loading,
    String? error,
    bool clearError = false,
    bool? loggedOut,
  }) {
    return HomeState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      loggedOut: loggedOut ?? this.loggedOut,
    );
  }
}
