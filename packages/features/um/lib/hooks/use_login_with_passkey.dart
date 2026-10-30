// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import 'package:um/container.dart';
import 'package:um/domain/entities/auth/passkey.dart';
import 'package:um/domain/entities/auth/system.dart';
import 'package:um/domain/platform/passkey_authenticator.dart';
import 'package:um/domain/usecase/auth_use_cases.dart';
import 'package:um/hooks/use_mutation_action.dart';

/// Whether this device can sign in with a passkey (um-api ADR-0010).
bool usePasskeysSupported() => sl<PasskeyAuthenticator>().isSupported;

/// Signs in with a passkey; the typed username, if any, must own it.
Future<void> Function(PasskeyLoginParam) useLoginWithPasskey(
  BuildContext context, {
  required Function(System) onSuccess,
}) {
  final action = sl<LoginWithPasskeyUseCase>();
  return useMutationAction<PasskeyLoginParam, System>(context, action.call,
      onSuccess: onSuccess);
}
