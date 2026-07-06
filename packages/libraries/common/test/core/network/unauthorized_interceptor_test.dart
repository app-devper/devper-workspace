import 'dart:async';

import 'package:common/core/network/unauthorized_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

http.Response responseFor(String path, int statusCode) {
  return http.Response(
    '',
    statusCode,
    request: http.Request('GET', Uri.parse('http://api.test$path')),
  );
}

void main() {
  test('fires callback once for a 401 and returns the same response', () async {
    var calls = 0;
    final interceptor = UnauthorizedInterceptor(onUnauthorized: () async {
      calls = calls + 1;
    });
    final response = responseFor('/api/pos/v1/products', 401);

    final result = await interceptor.onResponse(response);

    expect(calls, 1);
    expect(result, same(response));
  });

  test('fires callback once when parallel 401 responses arrive', () async {
    var calls = 0;
    final gate = Completer<void>();
    final interceptor = UnauthorizedInterceptor(onUnauthorized: () async {
      calls = calls + 1;
      await gate.future;
    });

    final first = interceptor.onResponse(responseFor('/api/pos/v1/products', 401));
    final second = interceptor.onResponse(responseFor('/api/pos/v1/orders', 401));
    gate.complete();
    await Future.wait([Future.value(first), Future.value(second)]);

    expect(calls, 1);
  });

  test('ignores 401 from the login path', () async {
    var calls = 0;
    final interceptor = UnauthorizedInterceptor(onUnauthorized: () async {
      calls = calls + 1;
    });

    await interceptor.onResponse(responseFor('/api/um/v1/auth/login', 401));

    expect(calls, 0);
  });

  test('ignores non-401 responses', () async {
    var calls = 0;
    final interceptor = UnauthorizedInterceptor(onUnauthorized: () async {
      calls = calls + 1;
    });

    await interceptor.onResponse(responseFor('/api/pos/v1/products', 500));

    expect(calls, 0);
  });

  test('fires again for a later 401 after handling completes', () async {
    var calls = 0;
    final interceptor = UnauthorizedInterceptor(onUnauthorized: () async {
      calls = calls + 1;
    });

    await interceptor.onResponse(responseFor('/api/pos/v1/products', 401));
    await interceptor.onResponse(responseFor('/api/pos/v1/products', 401));

    expect(calls, 2);
  });
}
