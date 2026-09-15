// Flutter imports:
import 'package:flutter/foundation.dart';

/// What this screen renders: whether the signed-in user is an admin, which
/// decides what the menu offers.
///
/// It used to be nullable and cleared after reading, as though it were an
/// event. It is a predicate the screen draws from, so it stays, and defaults
/// to the safer answer until the role comes back.
///
/// Logging out is the event, and it is on the view model's channel.
@immutable
class HomeState {
  final bool isAdmin;

  const HomeState({this.isAdmin = false});

  HomeState copyWith({bool? isAdmin}) {
    return HomeState(isAdmin: isAdmin ?? this.isAdmin);
  }
}
