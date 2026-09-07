// Package imports:
import 'package:common/config/app_config.dart';

class AppSession {
  String _hostUm = "";
  String _hostApp = "";
  String _clientId = "";
  String _accessToken = "";
  // When set from config, this takes priority over system endpoint
  String _configHostApp = "";

  AppSession(AppConfig config) {
    _hostUm = config.apiUrl;
    if (config.hostApp.isNotEmpty) {
      _configHostApp = config.hostApp;
      _hostApp = config.hostApp;
    }
  }

  String getClientId() {
    return _clientId;
  }

  String getHostApp() {
    return _hostApp;
  }

  String getAccessToken() {
    return _accessToken;
  }

  void setAccessToken(String accessToken) {
    _accessToken = accessToken;
  }

  String getHostUm() {
    return _hostUm;
  }

  void setClientId(String clientId) {
    _clientId = clientId;
  }

  // If hostApp is pinned in config, ignore system endpoint override
  void setHostApp(String hostApp) {
    if (_configHostApp.isEmpty) {
      _hostApp = hostApp;
    }
  }

  void clear() {
    _hostApp = _configHostApp; // restore config override after logout
    _clientId = "";
    _accessToken = "";
  }
}
