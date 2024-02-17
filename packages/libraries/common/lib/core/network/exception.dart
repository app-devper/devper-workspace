// Package imports:
import 'package:http/http.dart' as http;

class HttpException implements Exception {
  late int code;
  late String? message;
  late http.Response response;

  HttpException(this.response) {
    code = response.statusCode;
    message = response.reasonPhrase;
  }

  String getMessage() {
    return "HTTP ${response.statusCode} ${response.reasonPhrase}";
  }

  @override
  String toString() => "HttpException: $message";

}

extension Response on http.Response {
  bool get isSuccessful => statusCode >= 200 && statusCode < 300;
}

