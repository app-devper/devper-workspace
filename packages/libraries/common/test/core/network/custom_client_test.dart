import 'dart:async';

import 'package:common/core/network/custom_client.dart';
import 'package:common/core/network/interceptor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class RecordingInterceptor implements Interceptor {
  final String name;
  final List<String> log;

  RecordingInterceptor({required this.name, required this.log});

  @override
  FutureOr<http.Request> onRequest(http.Request request) {
    log.add('$name:request');
    return request;
  }

  @override
  FutureOr<http.Response> onResponse(http.Response response) {
    log.add('$name:response');
    return response;
  }
}

void main() {
  test('runs interceptors in registration order and keeps body unchanged', () async {
    final log = <String>[];
    final client = CustomClient(
      inner: MockClient((request) async => http.Response('{"ok":true}', 200)),
    );
    client.addInterceptor(RecordingInterceptor(name: 'first', log: log));
    client.addInterceptor(RecordingInterceptor(name: 'second', log: log));

    final response = await client.get(Uri.parse('http://api.test/ping'));

    expect(log, ['first:request', 'second:request', 'first:response', 'second:response']);
    expect(response.body, '{"ok":true}');
    expect(response.statusCode, 200);
  });
}
