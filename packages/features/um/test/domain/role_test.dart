import 'package:flutter_test/flutter_test.dart';
import 'package:um/domain/entities/auth/role.dart';

void main() {
  group('Role follows the order UM sets: USER < MANAGER < ADMIN < SUPER', () {
    test('reads the role a token carries', () {
      expect(Role.parse('USER'), Role.user);
      expect(Role.parse('MANAGER'), Role.manager);
      expect(Role.parse('ADMIN'), Role.admin);
      expect(Role.parse('SUPER'), Role.superuser);
    });

    test('an unknown or empty role is no role', () {
      expect(Role.parse(''), isNull);
      expect(Role.parse('OWNER'), isNull);
      expect(Role.parse(null), isNull);
    });

    test('SUPER is at least ADMIN, the way pos-api treats it', () {
      expect(Role.superuser.atLeast(Role.admin), isTrue);
      expect(Role.admin.atLeast(Role.admin), isTrue);
      expect(Role.manager.atLeast(Role.admin), isFalse);
      expect(Role.user.atLeast(Role.admin), isFalse);
    });

    test('MANAGER is at least MANAGER and below ADMIN', () {
      expect(Role.manager.atLeast(Role.manager), isTrue);
      expect(Role.manager.atLeast(Role.superuser), isFalse);
    });
  });
}
