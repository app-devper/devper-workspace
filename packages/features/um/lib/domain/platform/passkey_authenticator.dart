/// The device's passkey prompt (WebAuthn `navigator.credentials.get`).
/// Implemented per platform; the browser one lives in data/datasource/passkey.
abstract class PasskeyAuthenticator {
  /// Whether this platform can answer UM's passkey login options.
  bool get isSupported;

  /// Asks the user for a passkey matching [optionsJson] (UM's request options)
  /// and returns the assertion as JSON. Throws a `PasskeyException` when the
  /// prompt is dismissed or the platform cannot run it.
  Future<String> get(String optionsJson);
}
