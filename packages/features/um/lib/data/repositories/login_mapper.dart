// Dart imports:
import 'dart:convert';

// Project imports:
import 'package:um/domain/entities/auth/login.dart';
import 'package:um/domain/entities/auth/param.dart';
import 'package:um/domain/entities/auth/system.dart';
import 'package:um/domain/entities/auth/user_session.dart';

class LoginMapper {
  String toLoginRequest(LoginParam param) {
    return jsonEncode({
      'username': param.username,
      'password': param.password,
      'system': param.system,
    });
  }

  Login toLoginDomain(Map<String, dynamic> json) {
    return Login(
      accessToken: json['accessToken'],
    );
  }

  UserSession toUserSessionDomain(Map<String, dynamic> json) {
    return UserSession(
      sessionId: json['sessionId'] ?? '',
      createdAt: json['createdAt'] ?? '',
      lastActivity: json['lastActivity'] ?? '',
      userAgent: json['userAgent'] ?? '',
      ipAddress: json['ipAddress'] ?? '',
      system: json['system'] ?? '',
      current: json['current'] ?? false,
    );
  }

  List<UserSession> toUserSessionsDomain(List<dynamic> json) {
    return json
        .map((item) => toUserSessionDomain(item as Map<String, dynamic>))
        .toList();
  }

  System toSystemDomain(Map<String, dynamic> json) {
    return System(
        id: json['id'],
        clientId: json['clientId'],
        systemName: json['systemName'],
        systemCode: json['systemCode'],
        host: json['host']
    );
  }

}
