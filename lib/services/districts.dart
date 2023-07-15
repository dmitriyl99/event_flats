import 'package:dio/dio.dart';
import 'package:event_flats/models/user.dart';
import 'package:event_flats/services/api_authentication.dart';

import 'api_settings.dart';
import 'exceptions/server_error_exception.dart';
import 'exceptions/user_empty.dart';

Future<List<Map<String, dynamic>>> getDistricts() async {
  final Dio _httpClient = new Dio(BaseOptions(
      baseUrl: '${ApiSettings.host}/api/v1/',
      responseType: ResponseType.json,
      headers: {'Accept': 'application/json'}));
  var response = await _httpClient.get('addresses',
      options: await _authorizationOptions());
  if (response.statusCode == 500) throw new ServerErrorException();
  var data = List<Map<String, dynamic>>.from(response.data);
  return data;
}

Future<User> _getUser() async {
  ApiAuthenticationService authenticationService =
      new ApiAuthenticationService();
  var user = authenticationService.getUser();
  if (user == null) throw new UnauthorizedUserException();
  return user;
}

Future<Options> _authorizationOptions() async {
  var user = await _getUser();
  return Options(headers: {'Authorization': 'Bearer ${user.accessToken}'});
}
