// Package imports:
import 'package:common/config/network_config.dart';
import 'package:common/core/network/custom_client.dart';
import 'package:http/http.dart' as http;

class UmService {
  final NetworkConfig _networkConfig;
  final CustomClient _client;

  UmService({
    required NetworkConfig networkConfig,
    required CustomClient client,
  })  : _networkConfig = networkConfig,
        _client = client;

  // Auth
  Future<http.Response> keepAlive() {
    var url =
        Uri.parse('${_networkConfig.getHostUm()}/api/um/v1/auth/keep-alive');
    final headers = _networkConfig.getHeaders(url);
    return _client.get(url, headers: headers);
  }

  Future<http.Response> loginUser(String jsonBody) {
    var url = Uri.parse('${_networkConfig.getHostUm()}/api/um/v1/auth/login');
    return _client.post(url,
        headers: _networkConfig.getHeaders(url), body: jsonBody);
  }

  Future<http.Response> logoutUser() {
    var url = Uri.parse('${_networkConfig.getHostUm()}/api/um/v1/auth/logout');
    return _client.post(url, headers: _networkConfig.getHeaders(url));
  }

  Future<http.Response> getSystem() {
    var url = Uri.parse('${_networkConfig.getHostUm()}/api/um/v1/auth/system');
    return _client.get(url, headers: _networkConfig.getHeaders(url));
  }

  Future<http.Response> getSessions() {
    var url = Uri.parse('${_networkConfig.getHostUm()}/api/um/v1/auth/sessions');
    return _client.get(url, headers: _networkConfig.getHeaders(url));
  }

  Future<http.Response> revokeSessionById(String sessionId) {
    var url = Uri.parse(
        '${_networkConfig.getHostUm()}/api/um/v1/auth/sessions/$sessionId');
    return _client.delete(url, headers: _networkConfig.getHeaders(url));
  }

  Future<http.Response> revokeOtherSessions() {
    var url = Uri.parse('${_networkConfig.getHostUm()}/api/um/v1/auth/sessions');
    return _client.delete(url, headers: _networkConfig.getHeaders(url));
  }

  // User
  Future<http.Response> getUserInfo() {
    var url = Uri.parse('${_networkConfig.getHostUm()}/api/um/v1/user/info');
    return _client.get(url, headers: _networkConfig.getHeaders(url));
  }

  Future<http.Response> updateUserInfo(String jsonBody) {
    var url = Uri.parse('${_networkConfig.getHostUm()}/api/um/v1/user/info');
    return _client.put(url,
        headers: _networkConfig.getHeaders(url), body: jsonBody);
  }

  Future<http.Response> changePassword(String jsonBody) {
    var url = Uri.parse(
        '${_networkConfig.getHostUm()}/api/um/v1/user/change-password');
    return _client.put(url,
        headers: _networkConfig.getHeaders(url), body: jsonBody);
  }

  // Admin
  Future<http.Response> getUsers() {
    var url = Uri.parse('${_networkConfig.getHostUm()}/api/um/v1/user');
    return _client.get(url, headers: _networkConfig.getHeaders(url));
  }

  Future<http.Response> getUserById(String userId) {
    var url = Uri.parse('${_networkConfig.getHostUm()}/api/um/v1/user/$userId');
    return _client.get(url, headers: _networkConfig.getHeaders(url));
  }

  Future<http.Response> updateUserById(String userId, String jsonBody) {
    var url = Uri.parse('${_networkConfig.getHostUm()}/api/um/v1/user/$userId');
    return _client.put(url,
        headers: _networkConfig.getHeaders(url), body: jsonBody);
  }

  Future<http.Response> removeUserById(String userId) {
    var url = Uri.parse('${_networkConfig.getHostUm()}/api/um/v1/user/$userId');
    return _client.delete(url, headers: _networkConfig.getHeaders(url));
  }

  Future<http.Response> createUser(String jsonBody) {
    var url = Uri.parse('${_networkConfig.getHostUm()}/api/um/v1/user');
    return _client.post(url,
        headers: _networkConfig.getHeaders(url), body: jsonBody);
  }

  Future<http.Response> updateStatusById(String userId, String jsonBody) {
    var url = Uri.parse(
        '${_networkConfig.getHostUm()}/api/um/v1/user/$userId/status');
    return _client.patch(url,
        headers: _networkConfig.getHeaders(url), body: jsonBody);
  }

  Future<http.Response> setPasswordById(String userId, String jsonBody) {
    var url = Uri.parse(
        '${_networkConfig.getHostUm()}/api/um/v1/user/$userId/set-password');
    return _client.patch(url,
        headers: _networkConfig.getHeaders(url), body: jsonBody);
  }

  Future<http.Response> updateRoleById(String userId, String jsonBody) {
    var url =
        Uri.parse('${_networkConfig.getHostUm()}/api/um/v1/user/$userId/role');
    return _client.patch(url,
        headers: _networkConfig.getHeaders(url), body: jsonBody);
  }
}
