class ForbiddenException implements Exception {
  String message = 'У вас нет прав на это действите';

  ForbiddenException({String? message}) {
    if (message != null) this.message = message;
  }
}
