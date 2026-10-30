import 'package:common/core/error/exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:um/domain/entities/auth/role.dart';
import 'package:um/domain/repositories/login_repository.dart';
import 'package:um/domain/usecase/auth_use_cases.dart';

class _Login implements LoginRepository {
  final String? role;
  _Login(this.role);

  @override
  Future<String> getRole() async {
    final r = role;
    if (r == null) throw const AuthException(message: 'invalid token');
    return r;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  group('whether the signed-in user is at least a role', () {
    test('a role at or above it is', () async {
      expect(await GetRoleUseCase(_Login('ADMIN')).atLeast(Role.admin), isTrue);
      expect(await GetRoleUseCase(_Login('SUPER')).atLeast(Role.admin), isTrue);
    });

    test('a role below it is not', () async {
      expect(await GetRoleUseCase(_Login('MANAGER')).atLeast(Role.admin), isFalse);
    });

    test('a role that cannot be read grants nothing, and does not throw', () async {
      expect(await GetRoleUseCase(_Login(null)).atLeast(Role.admin), isFalse);
      expect(await GetRoleUseCase(_Login('OWNER')).atLeast(Role.admin), isFalse);
    });
  });
}
