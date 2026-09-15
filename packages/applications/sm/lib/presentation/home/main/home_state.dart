// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:sm/domain/model/system/system.dart';

/// What the home screen renders: the systems it lists, whether a request is in
/// flight, and the role that decides which sections the sidebar offers.
///
/// The error and the "logged out" flag used to sit here too. Neither is drawn:
/// one is a snack bar, the other a screen to leave.
@immutable
class HomeState {
  final List<System> items;
  final bool loading;
  final String role;

  const HomeState({
    this.items = const [],
    this.loading = false,
    this.role = '',
  });

  /// Mirrors um-web's sidebar gating.
  bool get canManageUsers => const ['SUPER', 'ADMIN', 'MANAGER'].contains(role);

  bool get canManageSystems => role == 'SUPER';

  HomeState copyWith({
    List<System>? items,
    bool? loading,
    String? role,
  }) {
    return HomeState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      role: role ?? this.role,
    );
  }
}
