// Package imports:
import 'package:common/config/app_config.dart';

class AppSession  {
  String _hostUm = "";
  String _hostApp = "";
  String _clientId = "";
  String _accessToken = "";

  AppSession(AppConfig config) {
    _hostUm = config.apiUrl;
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

  void setHostApp(String hostApp) {
    _hostApp = hostApp;
  }

  void clear() {
    _hostApp = "";
    _clientId = "";
    _accessToken = "";
  }
}
