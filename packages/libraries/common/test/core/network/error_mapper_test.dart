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
