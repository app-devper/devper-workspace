// Dart imports:
import 'dart:io' show Platform;

// Flutter imports:
import 'package:flutter/foundation.dart';

class Device {
  static Os getPlatform() {
    if (kIsWeb) {
      return Os.web;
    } else if (Platform.isIOS) {
      return Os.iOS;
    } else if (Platform.isAndroid) {
      return Os.android;
    } else if (Platform.isFuchsia) {
      return Os.fuchsia;
    } else if (Platform.isLinux) {
      return Os.linux;
    } else if (Platform.isMacOS) {
      return Os.macOS;
    } else if (Platform.isWindows) {
      return Os.windows;
    }
    return Os.unknown;
  }

  static bool isWeb() {
    return (getPlatform() == Os.web);
  }

  static bool isMobile() {
    Os platform = getPlatform();
    return (platform == Os.android || platform == Os.iOS || platform == Os.fuchsia);
  }

  static bool isComputer() {
    Os platform = getPlatform();
    return (platform == Os.linux || platform == Os.macOS || platform == Os.windows);
  }
}

enum Os {
  unknown,
  web,
  android,
  fuchsia,
  iOS,
  linux,
  macOS,
  windows,
}
