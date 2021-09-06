class AuthenticationFailed implements Exception {
  String getMessage() {
    return 'Неверный логин или пароль';
  }
}
