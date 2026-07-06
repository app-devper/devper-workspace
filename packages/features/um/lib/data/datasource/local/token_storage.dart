abstract class TokenStorage {
  Future<void> save(String accessToken);

  Future<String> read();

  Future<void> clear();
}
