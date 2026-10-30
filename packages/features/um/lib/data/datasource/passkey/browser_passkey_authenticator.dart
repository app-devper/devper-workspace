// Project imports:
import 'package:um/domain/platform/passkey_authenticator.dart';
import 'passkey_authenticator_stub.dart'
    if (dart.library.js_interop) 'passkey_authenticator_web.dart';

/// The passkey prompt of the platform the app runs on.
PasskeyAuthenticator createPasskeyAuthenticator() =>
    const PlatformPasskeyAuthenticator();
