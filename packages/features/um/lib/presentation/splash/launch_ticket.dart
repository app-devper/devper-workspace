// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'launch_address_stub.dart' if (dart.library.js_interop) 'launch_address_web.dart';

/// The one-time ticket UM put in the address when the user opened this app
/// from UM (`/sso?ticket=…`, um-api ADR-0011), or null. The address is reset
/// to `/` so the ticket is neither bookmarked nor reused on reload.
String? takeLaunchTicket([Uri? address]) {
  final uri = address ?? Uri.base;
  if (!kIsWeb && address == null) return null;
  if (uri.path != '/sso') return null;
  final ticket = uri.queryParameters['ticket'];
  if (address == null) resetAddress();
  if (ticket == null || ticket.isEmpty || ticket.length > 128) return null;
  return ticket;
}
