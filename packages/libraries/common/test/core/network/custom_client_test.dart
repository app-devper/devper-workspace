import 'dart:async';

import 'package:common/core/network/custom_client.dart';
import 'package:common/core/network/unauthorized_interceptor.dart';
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
  test('runs interceptors in registration order and keeps body unchanged',
      () async {
    final log = <String>[];
    final client = CustomClient(
      inner: MockClient((request) async => http.Response('{"ok":true}', 200)),
    );
    client.addInterceptor(RecordingInterceptor(name: 'first', log: log));
    client.addInterceptor(RecordingInterceptor(name: 'second', log: log));

    final response = await client.get(Uri.parse('http://api.test/ping'));

    expect(log, [
      'first:request',
      'second:request',
      'first:response',
      'second:response'
    ]);
    expect(response.body, '{"ok":true}');
    expect(response.statusCode, 200);
  });

  group('sendUnary', () {
    test('runs the response interceptors a streamed send would skip', () async {
      final log = <String>[];
      final client = CustomClient(
        inner: MockClient((request) async => http.Response('{"ok":true}', 200)),
      );
      client.addInterceptor(RecordingInterceptor(name: 'only', log: log));

      final request = http.MultipartRequest(
          'POST', Uri.parse('http://api.test/upload'))
        ..files.add(
            http.MultipartFile.fromBytes('file', [1, 2], filename: 'a.csv'));
      final response = await client.sendUnary(request);

      expect(response.body, '{"ok":true}');
      expect(log, ['only:response'],
          reason: 'a multipart body is not a Request, so onRequest cannot run');
    });

    test('a 401 on an upload reaches UnauthorizedInterceptor', () async {
      var loggedOut = 0;
      final client = CustomClient(
        inner: MockClient(
            (request) async => http.Response('{"code":"UM-401"}', 401)),
      );
      client.addInterceptor(UnauthorizedInterceptor(onUnauthorized: () async {
        loggedOut++;
      }));

      final request = http.MultipartRequest(
          'POST', Uri.parse('http://api.test/upload'))
        ..files
            .add(http.MultipartFile.fromBytes('file', [1], filename: 'a.csv'));
      await client.sendUnary(request);

      expect(loggedOut, 1,
          reason: 'an expired session must end the same way on every endpoint');
    });

    test('plain send still hands back the stream untouched', () async {
      final log = <String>[];
      final client = CustomClient(
        inner: MockClient((request) async => http.Response('{"ok":true}', 401)),
      );
      client.addInterceptor(RecordingInterceptor(name: 'only', log: log));

      final streamed = await client
          .send(http.Request('GET', Uri.parse('http://api.test/stream')));

      expect(streamed.statusCode, 401);
      expect(log, isEmpty,
          reason: 'draining a stream to inspect it would defeat streaming');
    });
  });
}
