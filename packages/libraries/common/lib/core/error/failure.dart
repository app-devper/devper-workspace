import 'dart:async';

import 'package:http/http.dart' as http;

import 'exception.dart';

class Failure {
  final String error;
  final String errorCode;

  const Failure({
    required this.errorCode,
    required this.error,
  });

  String getMessage() {
    return "$error [$errorCode]";
  }
}

const _networkErrorMessage = "เชื่อมต่อเซิร์ฟเวอร์ไม่ได้ กรุณาลองใหม่";

Failure toFailure(Object e) {
  return switch (e) {
    AuthException() => Failure(errorCode: e.code, error: "เซสชันหมดอายุ กรุณาเข้าสู่ระบบใหม่"),
    ForbiddenException() => Failure(errorCode: e.code, error: "ไม่มีสิทธิ์ใช้งานส่วนนี้"),
    NotFoundException() => Failure(errorCode: e.code, error: "ไม่พบข้อมูลที่ต้องการ"),
    NetworkException() => Failure(errorCode: e.code, error: _networkErrorMessage),
    ServerException() => Failure(errorCode: e.code, error: "ระบบขัดข้อง กรุณาลองใหม่ภายหลัง"),
    ValidationException() => Failure(errorCode: e.code, error: e.message),
    ConflictException() => Failure(errorCode: e.code, error: e.message),
    UnknownHttpException() => Failure(errorCode: e.code, error: e.message),
    http.ClientException() => const Failure(errorCode: "NETWORK_ERROR", error: _networkErrorMessage),
    TimeoutException() => const Failure(errorCode: "NETWORK_ERROR", error: _networkErrorMessage),
    _ => Failure(errorCode: "UNKNOWN", error: e.toString()),
  };
}
