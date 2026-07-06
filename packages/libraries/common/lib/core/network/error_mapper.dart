import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../error/exception.dart';
import 'exception.dart';

dynamic jsonOrThrow(http.Response response) {
  if (response.isSuccessful) {
    if (response.body.isEmpty) {
      return null;
    }
    return jsonDecode(response.body);
  }
  throw toAppException(response);
}

AppException toAppException(http.Response response) {
  final body = _decodeBody(response.body);
  final message = _extractMessage(body, response);
  final code = _extractCode(body, response);
  final statusCode = response.statusCode;
  if (statusCode == 401) {
    return AuthException(message: message, code: code);
  }
  if (statusCode == 403) {
    return ForbiddenException(message: message, code: code);
  }
  if (statusCode == 404) {
    return NotFoundException(message: message, code: code);
  }
  if (statusCode == 409) {
    return ConflictException(message: message, code: code, payload: body);
  }
  if (statusCode >= 500) {
    return ServerException(message: message, code: code);
  }
  return UnknownHttpException(message: message, code: code, statusCode: statusCode);
}

AppException toNetworkException(Object error) {
  if (error is AppException) {
    return error;
  }
  if (error is http.ClientException) {
    return NetworkException(message: error.message);
  }
  if (error is TimeoutException) {
    return const NetworkException(message: "request timeout");
  }
  return NetworkException(message: error.toString());
}

Map<String, dynamic>? _decodeBody(String body) {
  if (body.isEmpty) {
    return null;
  }
  try {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return null;
  } on FormatException {
    return null;
  }
}

String _extractMessage(Map<String, dynamic>? body, http.Response response) {
  final message = body?["message"] ?? body?["error"];
  if (message is String && message.isNotEmpty) {
    return message;
  }
  return response.reasonPhrase ?? "HTTP ${response.statusCode}";
}

String _extractCode(Map<String, dynamic>? body, http.Response response) {
  final code = body?["code"];
  if (code != null && code.toString().isNotEmpty) {
    return code.toString();
  }
  return "HTTP-${response.statusCode}";
}
