import 'dart:convert';

import 'package:common/core/error/exception.dart';
import 'package:common/core/network/error_mapper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  group('toAppException', () {
    test('maps 401 with um error body to AuthException', () {
      final e = toAppException(http.Response('{"code":"UM-401","message":"session expired"}', 401));

      expect(e, isA<AuthException>());
      expect(e.message, 'session expired');
      expect(e.code, 'UM-401');
    });

    test('maps 403 to ForbiddenException', () {
      expect(toAppException(http.Response('', 403)), isA<ForbiddenException>());
    });

    test('maps 404 to NotFoundException', () {
      expect(toAppException(http.Response('', 404)), isA<NotFoundException>());
    });

    test('maps 409 to ConflictException carrying payload', () {
      final e = toAppException(http.Response('{"message":"duplicate","extra":1}', 409));

      expect(e, isA<ConflictException>());
      expect((e as ConflictException).payload?['extra'], 1);
    });

    test('maps 500 to ServerException', () {
      expect(toAppException(http.Response('', 500)), isA<ServerException>());
    });

    test('maps other status to UnknownHttpException with statusCode', () {
      final e = toAppException(http.Response('', 418));

      expect(e, isA<UnknownHttpException>());
      expect((e as UnknownHttpException).statusCode, 418);
      expect(e.code, 'HTTP-418');
    });

    test('reads the pos-api envelope, errcode and error', () {
      // gin sends JSON as UTF-8, and pos-api's messages are Thai.
      final e = toAppException(http.Response.bytes(
        utf8.encode('{"errcode":"PD-BAD-REQUEST-002","error":"สต็อกไม่พอ"}'),
        400,
        headers: {'content-type': 'application/json; charset=utf-8'},
      ));

      expect(e.code, 'PD-BAD-REQUEST-002');
      expect(e.message, 'สต็อกไม่พอ');
    });

    test('prefers errcode when a body carries both keys', () {
      final e = toAppException(http.Response('{"errcode":"A","code":"B"}', 409));

      expect(e.code, 'A');
    });

    test('maps 400 to ValidationException with the server code and message', () {
      final e = toAppException(http.Response('{"errcode":"OR-001","error":"bad sale"}', 400));

      expect(e, isA<ValidationException>());
      expect(e.code, 'OR-001');
      expect(e.message, 'bad sale');
    });

    test('maps 422 to ValidationException', () {
      final e = toAppException(http.Response('{"code":"UM-422","message":"weak password"}', 422));

      expect(e, isA<ValidationException>());
      expect(e.code, 'UM-422');
    });

    test('a 400 without a code still says which status it was', () {
      expect(toAppException(http.Response('', 400)).code, 'HTTP-400');
    });

    test('falls back to legacy error key for message', () {
      final e = toAppException(http.Response('{"error":"boom"}', 400));

      expect(e.message, 'boom');
    });

    test('malformed body falls back to status text', () {
      final e = toAppException(http.Response('not-json', 500));

      expect(e, isA<ServerException>());
      expect(e.message, 'HTTP 500');
    });
  });

  group('jsonOrThrow', () {
    test('returns decoded json on success', () {
      final json = jsonOrThrow(http.Response('{"a":1}', 200));

      expect(json['a'], 1);
    });

    test('returns null on empty success body', () {
      expect(jsonOrThrow(http.Response('', 204)), isNull);
    });

    test('throws typed exception on failure', () {
      expect(
        () => jsonOrThrow(http.Response('{"message":"nope"}', 404)),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('toNetworkException', () {
    test('maps ClientException to NetworkException', () {
      final e = toNetworkException(http.ClientException('connection refused'));

      expect(e, isA<NetworkException>());
      expect(e.message, 'connection refused');
    });

    test('passes AppException through unchanged', () {
      const original = AuthException(message: 'x');

      expect(toNetworkException(original), same(original));
    });

    test('wraps unknown errors as NetworkException', () {
      expect(toNetworkException(StateError('x')), isA<NetworkException>());
    });
  });
}
