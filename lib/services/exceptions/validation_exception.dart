class ValidationException implements Exception {
  final Map<String, dynamic> _errors;

  ValidationException(this._errors);

  Map<String, dynamic> getErrors() {
    return _errors;
  }
}
