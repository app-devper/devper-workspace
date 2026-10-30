// Dart imports:
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

// Package imports:
import 'package:common/core/error/exception.dart';

// Project imports:
import 'package:um/domain/platform/passkey_authenticator.dart';

@JS('JSON.parse')
external JSAny? _jsonParse(JSString text);

@JS('JSON.stringify')
external JSString _jsonStringify(JSAny? value);

/// The browser's passkey prompt: parses UM's JSON options with
/// `PublicKeyCredential.parseRequestOptionsFromJSON`, runs
/// `navigator.credentials.get` and returns the assertion's `toJSON()`.
class PlatformPasskeyAuthenticator implements PasskeyAuthenticator {
  const PlatformPasskeyAuthenticator();

  JSObject? get _publicKeyCredential {
    final value = globalContext['PublicKeyCredential'];
    if (value == null || value.isUndefinedOrNull) return null;
    return value as JSObject;
  }

  @override
  bool get isSupported {
    final pkc = _publicKeyCredential;
    return pkc != null && pkc.has('parseRequestOptionsFromJSON');
  }

  @override
  Future<String> get(String optionsJson) async {
    final pkc = _publicKeyCredential;
    if (pkc == null || !pkc.has('parseRequestOptionsFromJSON')) {
      throw const PasskeyException(
        code: PasskeyException.unsupported,
        message: 'เบราว์เซอร์นี้ใช้ passkey ไม่ได้',
      );
    }
    final options = _jsonParse(optionsJson.toJS) as JSObject;
    final publicKey =
        pkc.callMethod('parseRequestOptionsFromJSON'.toJS, options['publicKey']);
    final request = JSObject()..['publicKey'] = publicKey;
    final credentials =
        (globalContext['navigator'] as JSObject)['credentials'] as JSObject;
    // Settle on the JS side, so the rejection reason stays a JS value and its
    // DOMException name can be read without a Dart/JS runtime type check.
    final prompt = credentials.callMethod('get'.toJS, request) as JSObject;
    final settled = prompt.callMethod(
      'then'.toJS,
      ((JSObject? credential) => _Outcome.ok(credential == null
          ? null
          : _jsonStringify(credential.callMethod('toJSON'.toJS)).toDart)).toJS,
      ((JSAny? reason) => _Outcome.failed(_errorName(reason))).toJS,
    ) as JSPromise<JSBoxedDartObject>;
    final outcome = (await settled.toDart).toDart as _Outcome;
    if (outcome.errorName != null) throw _failure(outcome.errorName!);
    final assertion = outcome.credentialJson;
    if (assertion == null) throw _cancelled;
    return assertion;
  }

  static String? _errorName(JSAny? reason) {
    if (reason == null || !reason.isA<JSObject>()) return null;
    return ((reason as JSObject)['name'] as JSString?)?.toDart;
  }

  static const _cancelled = PasskeyException(
    code: PasskeyException.cancelled,
    message: 'ยกเลิกการใช้ passkey แล้ว',
  );

  /// A DOMException name tells a dismissed prompt from a broken one.
  static PasskeyException _failure(String? name) {
    switch (name) {
      case 'NotAllowedError':
      case 'AbortError':
        return _cancelled;
      case 'NotSupportedError':
        return const PasskeyException(
          code: PasskeyException.unsupported,
          message: 'เบราว์เซอร์นี้ใช้ passkey ไม่ได้',
        );
      default:
        return const PasskeyException(
          code: PasskeyException.failed,
          message: 'เข้าสู่ระบบด้วย passkey ไม่สำเร็จ',
        );
    }
  }
}

/// How the browser prompt ended: an assertion as JSON, nothing (dismissed), or
/// the name of the DOMException it rejected with.
class _Outcome {
  final String? credentialJson;
  final String? errorName;

  const _Outcome._(this.credentialJson, this.errorName);

  static JSBoxedDartObject ok(String? credentialJson) =>
      _Outcome._(credentialJson, null).toJSBox;

  static JSBoxedDartObject failed(String? errorName) =>
      _Outcome._(null, errorName ?? 'Error').toJSBox;
}
