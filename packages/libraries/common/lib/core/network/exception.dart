import 'package:http/http.dart' as http;

extension Response on http.Response {
  bool get isSuccessful => statusCode >= 200 && statusCode < 300;
}
