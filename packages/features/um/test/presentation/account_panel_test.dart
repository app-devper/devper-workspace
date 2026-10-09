import 'package:common/core/error/exception.dart';
import 'package:common/localizations/localizations_delegate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:um/container.dart';
import 'package:um/domain/entities/auth/user_session.dart';
import 'package:um/domain/entities/user/user.dart';
import 'package:um/domain/repositories/login_repository.dart';
import 'package:um/domain/repositories/user_repository.dart';
import 'package:um/domain/usecase/auth_use_cases.dart';
import 'package:um/domain/usecase/user_use_cases.dart';
import 'package:um/presentation/core/widget/account_panel.dart';

class _Users implements UserRepository {
  bool fail = true;
  @override
  Future<User> getUserInfo() async {
    if (fail) throw const NetworkException(message: 'offline');
    return User(
        id: 'u1',
        username: 'somchai',
        role: 'ADMIN',
        status: 'ACTIVE',
        createdBy: '',
        createdDate: '',
        updatedBy: '',
        updatedDate: '');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _Login implements LoginRepository {
  @override
  Future<List<UserSession>> getSessions() async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  late _Users users;

  setUp(() async {
    await sl.reset();
    users = _Users();
    final login = _Login();
    sl.registerFactory(() => GetUserInfoUseCase(users));
    sl.registerFactory(() => UpdateUserInfoUseCase(users));
    sl.registerFactory(() => ChangePasswordUseCase(users));
    sl.registerFactory(() => GetSessionsUseCase(login));
    sl.registerFactory(() => RevokeSessionUseCase(login));
    sl.registerFactory(() => RevokeOtherSessionsUseCase(login));
  });

  testWidgets('a profile that fails to load says so and can be retried',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: [CommonLocalizationsDelegate()],
      home: const Scaffold(body: AccountPanel()),
    ));
    await tester.pumpAndSettle();

    // It used to render nothing at all.
    expect(find.text('โหลดข้อมูลไม่สำเร็จ'), findsOneWidget);

    users.fail = false;
    await tester.tap(find.text('ลองใหม่'));
    await tester.pumpAndSettle();

    expect(find.text('โหลดข้อมูลไม่สำเร็จ'), findsNothing);
    expect(find.text('somchai'), findsWidgets);
  });
}
