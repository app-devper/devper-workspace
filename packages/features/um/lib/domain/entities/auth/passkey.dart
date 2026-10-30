/// A passkey login UM started: the Ceremony to answer and the WebAuthn request
/// options, as JSON for `PublicKeyCredential.parseRequestOptionsFromJSON`.
class PasskeyChallenge {
  final String ceremonyId;
  final String optionsJson;

  const PasskeyChallenge({required this.ceremonyId, required this.optionsJson});
}

/// A passkey sign-in on [system]. [typedUsername] is whatever the login form
/// holds; UM refuses a passkey that belongs to a different account.
class PasskeyLoginParam {
  final String system;
  final String typedUsername;

  const PasskeyLoginParam({required this.system, this.typedUsername = ''});
}
