// Flutter imports:
import 'package:flutter/foundation.dart';

@immutable
class HomeState {
  final bool? isAdmin;
  final bool loggedOut;

  const HomeState({
    this.isAdmin,
    this.loggedOut = false,
  });

  HomeState copyWith({
    bool? isAdmin,
    bool? loggedOut,
    bool clearIsAdmin = false,
    bool clearLoggedOut = false,
  }) {
    return HomeState(
      isAdmin: clearIsAdmin ? null : (isAdmin ?? this.isAdmin),
      loggedOut: clearLoggedOut ? false : (loggedOut ?? this.loggedOut),
    );
  }
}
