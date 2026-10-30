// Package imports:
import 'package:common/core/error/exception.dart';

// Project imports:
import 'package:um/domain/platform/passkey_authenticator.dart';

/// Outside the browser there is no WebAuthn prompt yet.
class PlatformPasskeyAuthenticator implements PasskeyAuthenticator {
  const PlatformPasskeyAuthenticator();

  @override
  bool get isSupported => false;

  @override
  Future<String> get(String optionsJson) async {
    throw const PasskeyException(
      code: PasskeyException.unsupported,
      message: 'อุปกรณ์นี้ใช้ passkey ไม่ได้',
    );
  }
}
