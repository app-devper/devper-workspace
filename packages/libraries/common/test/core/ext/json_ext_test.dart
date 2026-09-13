import 'package:common/core/ext/json_ext.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('readDouble', () {
    test('reads numbers of either kind', () {
      expect({'a': 12}.readDouble('a'), 12.0);
      expect({'a': 12.5}.readDouble('a'), 12.5);
    });

    test('a missing field takes the fallback', () {
      expect(<String, dynamic>{}.readDouble('a'), 0);
      expect(<String, dynamic>{'a': null}.readDouble('a', fallback: 9), 9);
    });

    test('a number sent as text is read, not rejected', () {
      expect({'a': '12.50'}.readDouble('a'), 12.5);
    });

    test('anything else names the field instead of blaming toDouble', () {
      expect(
        () => {'price': 'ห้าบาท'}.readDouble('price'),
        throwsA(isA<FormatException>().having(
            (e) => e.message,
            'message',
            allOf(
                contains('price'), contains('a number'), contains('String')))),
      );
    });

    test('a bad price must not quietly become zero', () {
      // The reason a malformed field throws rather than falling back: a till
      // selling at 0 is worse than a till that refuses to load the product.
      expect(() => {'price': <String, dynamic>{}}.readDouble('price'),
          throwsA(isA<FormatException>()));
    });
  });

  group('readInt', () {
    test('truncates a double and parses text', () {
      expect({'a': 7.9}.readInt('a'), 7);
      expect({'a': '7'}.readInt('a'), 7);
      expect({'a': '7.9'}.readInt('a'), 7);
    });

    test('missing takes the fallback, wrong shape throws', () {
      expect(<String, dynamic>{}.readInt('a', fallback: 3), 3);
      expect(() => {'a': true}.readInt('a'), throwsA(isA<FormatException>()));
    });
  });

  group('readString', () {
    test('passes strings through and renders scalars', () {
      expect({'a': 'ยา'}.readString('a'), 'ยา');
      expect({'a': 12}.readString('a'), '12');
      expect({'a': true}.readString('a'), 'true');
    });

    test('missing takes the fallback, a structure throws', () {
      expect(<String, dynamic>{}.readString('a', fallback: '-'), '-');
      expect(
          () => {
                'a': <int>[1]
              }.readString('a'),
          throwsA(isA<FormatException>()));
    });

    test('readStringOrNull keeps null as null', () {
      expect(<String, dynamic>{}.readStringOrNull('a'), isNull);
      expect({'a': 'x'}.readStringOrNull('a'), 'x');
    });
  });

  group('readBool', () {
    test('accepts booleans, the numbers servers send, and their text', () {
      expect({'a': true}.readBool('a'), isTrue);
      expect({'a': 1}.readBool('a'), isTrue);
      expect({'a': 0}.readBool('a'), isFalse);
      expect({'a': 'true'}.readBool('a'), isTrue);
    });

    test('missing takes the fallback, anything else throws', () {
      expect(<String, dynamic>{}.readBool('a', fallback: true), isTrue);
      expect(() => {'a': 'yes'}.readBool('a'), throwsA(isA<FormatException>()));
    });
  });
}
