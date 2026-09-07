import 'package:flutter/widgets.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

void resetToRoute(String route) {
  appNavigatorKey.currentState?.pushNamedAndRemoveUntil(route, (r) => false);
}
