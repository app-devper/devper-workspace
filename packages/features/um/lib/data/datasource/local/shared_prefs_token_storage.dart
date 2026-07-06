import 'package:shared_preferences/shared_preferences.dart';

import 'token_storage.dart';

class SharedPrefsTokenStorage implements TokenStorage {
  static const _cachedTokenKey = 'cached_token';

  final SharedPreferences _sharedPreferences;

  SharedPrefsTokenStorage({
    required SharedPreferences sharedPreferences,
  }) : _sharedPreferences = sharedPreferences;

  @override
  Future<void> save(String accessToken) {
    return _sharedPreferences.setString(_cachedTokenKey, accessToken);
  }

  @override
  Future<String> read() {
    return Future.value(_sharedPreferences.getString(_cachedTokenKey) ?? "");
  }

  @override
  Future<void> clear() async {
    await _sharedPreferences.remove(_cachedTokenKey);
  }
}
