import 'dart:async';

import 'package:http/http.dart';

import 'interceptor.dart';

class UnauthorizedInterceptor implements Interceptor {
  final Future<void> Function() _onUnauthorized;
  final List<String> _excludedPaths;
  bool _isHandling = false;

  UnauthorizedInterceptor({
    required Future<void> Function() onUnauthorized,
    List<String> excludedPaths = const ["/auth/login", "/auth/exchange"],
  })  : _onUnauthorized = onUnauthorized,
        _excludedPaths = excludedPaths;

  @override
  FutureOr<Request> onRequest(Request request) => request;

  @override
  FutureOr<Response> onResponse(Response response) async {
    if (response.statusCode != 401) {
      return response;
    }
    final path = response.request?.url.path ?? "";
    if (_excludedPaths.any(path.endsWith)) {
      return response;
    }
    if (_isHandling) {
      return response;
    }
    _isHandling = true;
    try {
      await _onUnauthorized();
    } finally {
      _isHandling = false;
    }
    return response;
  }
}
