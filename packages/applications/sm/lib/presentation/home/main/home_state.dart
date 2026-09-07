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
  final String role;

  const HomeState({
    this.items = const [],
    this.loading = false,
    this.error,
    this.loggedOut = false,
    this.role = '',
  });

  /// Mirrors um-web's sidebar gating.
  bool get canManageUsers => const ['SUPER', 'ADMIN', 'MANAGER'].contains(role);

  bool get canManageSystems => role == 'SUPER';

  HomeState copyWith({
    List<System>? items,
    bool? loading,
    String? error,
    bool clearError = false,
    bool? loggedOut,
    String? role,
  }) {
    return HomeState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      loggedOut: loggedOut ?? this.loggedOut,
      role: role ?? this.role,
    );
  }
}
