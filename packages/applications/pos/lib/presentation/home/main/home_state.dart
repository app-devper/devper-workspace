// Flutter imports:
import 'package:flutter/foundation.dart';

@immutable
class HomeState {
  final bool? isAdmin;
  final bool loggedOut;
  final String? error;

  const HomeState({
    this.isAdmin,
    this.loggedOut = false,
    this.error,
  });

  HomeState copyWith({
    bool? isAdmin,
    bool? loggedOut,
    bool clearIsAdmin = false,
    bool clearLoggedOut = false,
    String? error,
    bool clearError = false,
  }) {
    return HomeState(
      isAdmin: clearIsAdmin ? null : (isAdmin ?? this.isAdmin),
      loggedOut: clearLoggedOut ? false : (loggedOut ?? this.loggedOut),
      error: clearError ? null : (error ?? this.error),
    );
  }
}
