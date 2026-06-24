class TokenStorage {
  static String? _token;

  static String? get token => _token;

  static void saveToken(String token) {
    _token = token;
  }

  static void clear() {
    _token = null;
  }
}