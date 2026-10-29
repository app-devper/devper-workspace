// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:common/core/error/exception.dart';
import 'package:common/core/ext/string_ext.dart';
import 'package:common/core/network/error_mapper.dart';
import 'package:common/core/network/exception.dart';

// Project imports:
import 'package:um/data/datasource/local/token_storage.dart';
import 'package:um/data/datasource/network/um_service.dart';
import 'package:um/data/datasource/session/app_session.dart';
import 'package:um/data/datasource/session/keep_alive_scheduler.dart';
import 'package:um/data/repositories/login_mapper.dart';
import 'package:um/data/repositories/user_mapper.dart';
import 'package:um/domain/entities/auth/login.dart';
import 'package:um/domain/entities/auth/param.dart';
import 'package:um/domain/entities/auth/session.dart';
import 'package:um/domain/entities/auth/system.dart';
import 'package:um/domain/entities/auth/user_session.dart';
import 'package:um/domain/repositories/login_repository.dart';

class LoginRepositoryImpl implements LoginRepository {
  final UmService _service;
  final TokenStorage _tokenStorage;
  final AppSession _appSession;
  final KeepAliveScheduler _keepAliveScheduler;

  LoginRepositoryImpl({
    required UmService service,
    required TokenStorage tokenStorage,
    required AppSession appSession,
    required KeepAliveScheduler keepAliveScheduler,
  })  : _tokenStorage = tokenStorage,
        _service = service,
        _appSession = appSession,
        _keepAliveScheduler = keepAliveScheduler;

  @override
  Future<Session> loginUser(LoginParam param) async {
    if (param.password.isEmpty || param.username.isEmpty) {
      throw const ValidationException(message: "กรุณากรอกชื่อผู้ใช้และรหัสผ่าน");
    }
    final mapper = LoginMapper();
    final response = await _service.loginUser(mapper.toLoginRequest(param));
    final login = mapper.toLoginDomain(jsonOrThrow(response));
    return _start(login.accessToken);
  }

  @override
  Future<Session> exchangeTicket(String ticket, String system) async {
    // The ticket decides who is signed in, so an older session here ends first.
    _keepAliveScheduler.stop();
    await _tokenStorage.clear();
    _appSession.clear();
    final mapper = LoginMapper();
    final response = await _service.exchangeTicket(jsonEncode({'ticket': ticket}));
    final login = mapper.toLoginDomain(jsonOrThrow(response));
    return _start(login.accessToken, expectedSystem: system);
  }

  /// Keeps the token, loads the user and System, and starts keep-alive; leaves
  /// no token behind if any step fails or the System is not [expectedSystem].
  Future<Session> _start(String accessToken, {String? expectedSystem}) async {
    await _tokenStorage.save(accessToken);
    _appSession.setAccessToken(accessToken);
    try {
      final user = UserMapper().toUserDomain(jsonOrThrow(await _service.getUserInfo()));
      final system = await getSystem();
      if (expectedSystem != null && system.systemCode != expectedSystem) {
        throw const AuthException(message: "บัญชีนี้เปิดระบบนี้จาก UM ไม่ได้ กรุณาเข้าสู่ระบบ");
      }
      _keepAliveScheduler.start();
      return Session(accessToken: accessToken, user: user, system: system);
    } catch (e) {
      await _tokenStorage.clear();
      _appSession.clear();
      rethrow;
    }
  }

  @override
  Future<Login> keepAlive() async {
    final accessToken = await _tokenStorage.read();
    if (accessToken.isEmpty) {
      throw const AuthException(message: "กรุณาเข้าสู่ระบบ");
    }
    _appSession.setAccessToken(accessToken);
    final mapper = LoginMapper();
    final response = await _service.keepAlive();
    final result = mapper.toLoginDomain(jsonOrThrow(response));
    await _tokenStorage.save(result.accessToken);
    _appSession.setAccessToken(result.accessToken);
    _keepAliveScheduler.start();
    return result;
  }

  @override
  Future<bool> logoutUser() async {
    _keepAliveScheduler.stop();
    try {
      await _service.logoutUser();
    } on Exception catch (_) {} finally {
      await _tokenStorage.clear();
      _appSession.clear();
    }
    return true;
  }

  @override
  Future<String> getRole() async {
    final accessToken = await _tokenStorage.read();
    final parts = accessToken.split('.');
    if (parts.length != 3) {
      throw const AuthException(message: "invalid token");
    }
    final payload = decodeBase64(parts[1]);
    final payloadMap = json.decode(payload);
    if (payloadMap is! Map<String, dynamic>) {
      throw const AuthException(message: "invalid payload");
    }
    return payloadMap['role'];
  }

  @override
  Future<System> getSystem() async {
    final mapper = LoginMapper();
    final response = await _service.getSystem();
    final result = mapper.toSystemDomain(jsonOrThrow(response));
    _appSession.setHostApp(result.host);
    _appSession.setClientId(result.clientId);
    return result;
  }

  @override
  String getClientId() {
    return _appSession.getClientId();
  }

  @override
  Future<List<UserSession>> getSessions() async {
    final mapper = LoginMapper();
    final response = await _service.getSessions();
    return mapper.toUserSessionsDomain(jsonOrThrow(response));
  }

  @override
  Future<bool> revokeSessionById(String sessionId) async {
    final response = await _service.revokeSessionById(sessionId);
    if (response.isSuccessful) {
      return true;
    } else {
      throw toAppException(response);
    }
  }

  @override
  Future<int> revokeOtherSessions() async {
    final response = await _service.revokeOtherSessions();
    final json = jsonOrThrow(response);
    return json['revoked'] ?? 0;
  }
}
