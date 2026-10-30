// Dart imports:
import 'dart:js_interop';

@JS('window.history.replaceState')
external void _replaceState(JSAny? data, JSString title, JSString url);

/// Puts `/` back in the address bar without reloading.
void resetAddress() => _replaceState(null, ''.toJS, '/'.toJS);
