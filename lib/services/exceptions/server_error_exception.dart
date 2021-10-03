class ServerErrorException implements Exception {
  String getMessage() {
    return 'Сервер временно недоступен';
  }
}
