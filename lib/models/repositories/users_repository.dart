import 'package:dio/dio.dart';
import 'package:event_flats/services/authentication.dart';
import 'package:event_flats/services/exceptions/authentication_failed.dart';
import 'package:event_flats/services/exceptions/forbidden_exception.dart';
import 'package:event_flats/services/exceptions/no_internet.dart';
import 'package:event_flats/services/exceptions/server_error_exception.dart';
import 'package:event_flats/services/exceptions/user_empty.dart';

import '../user.dart';

class UsersRepository {
  final Dio _httpClient = new Dio(BaseOptions(
      baseUrl: 'http://localhost:8000/api/v1/admin/users',
      responseType: ResponseType.json,
      headers: {'Accept': 'application/json'}));

  final AuthenticationService _authenticationService;

  UsersRepository(this._authenticationService);

  Future<List<Map<String, dynamic>>> index() async {
    Response<dynamic> response;
    try {
      response = await _httpClient.get('', options: _authorizationOptions());
    } on DioError catch (error) {
      if (error.response == null) throw NoInternetException();
      var response = error.response!;
      if (response.statusCode == 500) throw new ServerErrorException();
      if (response.statusCode == 401) throw new AuthenticationFailed();
      if (response.statusCode == 403)
        throw new ForbiddenException(message: response.data['error'] as String);
      throw error;
    }
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<void> create(String name, String email, String password) async {
    var payload = {'name': name, 'email': email, 'password': password};
    try {
      await _httpClient.post('',
          data: payload, options: _authorizationOptions());
    } on DioError catch (error) {
      if (error.response == null) throw NoInternetException();
      var response = error.response!;
      if (response.statusCode == 500) throw new ServerErrorException();
      if (response.statusCode == 403)
        throw new ForbiddenException(message: response.data['error'] as String);
      throw error;
    }
  }

  Future<void> update(
      int id, String name, String email, String password) async {
    var payload = {'name': name, 'email': email, 'password': password};
    try {
      await _httpClient.put('/$id',
          data: payload, options: _authorizationOptions());
    } on DioError catch (error) {
      if (error.response == null) throw NoInternetException();
      var response = error.response!;
      if (response.statusCode == 500) throw new ServerErrorException();
      if (response.statusCode == 403)
        throw new ForbiddenException(message: response.data['error'] as String);
      throw error;
    }
  }

  Future<void> delete(int id) async {
    try {
      await _httpClient.delete('/$id', options: _authorizationOptions());
    } on DioError catch (error) {
      if (error.response == null) throw NoInternetException();
      var response = error.response!;
      if (response.statusCode == 500) throw new ServerErrorException();
      if (response.statusCode == 403)
        throw new ForbiddenException(message: response.data['error'] as String);
      throw error;
    }
  }

  User _getUser() {
    var user = _authenticationService.getUser();
    if (user == null) throw new UnauthorizedUserException();
    return user;
  }

  Options _authorizationOptions() {
    var user = _getUser();
    return Options(headers: {'Authorization': 'Bearer ${user.accessToken}'});
  }
}
