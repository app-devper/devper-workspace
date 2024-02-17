// Dart imports:
import 'dart:async';

// Package imports:
import 'package:http/http.dart';

abstract class Interceptor {
  FutureOr<Request> onRequest(Request request);
  FutureOr<Response> onResponse(Response response);
}
