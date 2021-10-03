import 'package:dio/dio.dart';
import 'package:event_flats/models/user.dart';
import 'package:event_flats/services/authentication.dart';
import 'package:event_flats/services/exceptions/authentication_failed.dart';
import 'package:hive/hive.dart';

class ApiAuthenticationService extends AuthenticationService {
  final Dio _httpClient =
      new Dio(BaseOptions(baseUrl: 'http://localhost:8000/api/v1/auth/'));

  @override
  Future<User?> getUser() async {
    var usersBox = await Hive.openBox<User>('users');
    if (usersBox.containsKey('authenticated'))
      return usersBox.get('authenticated') as User;
    return null;
  }

  @override
  Future<void> login(String email, String password) async {
    var payload = {"email": email, "password": password};
    var response = await _httpClient.post('login/access-token',
        data: payload, options: Options(responseType: ResponseType.json));
    if (response.statusCode == 401) {
      throw new AuthenticationFailed();
    }
    var usersBox = await Hive.openBox<User>('users');
    var data = response as Map<String, dynamic>;
    var accessToken = data['access_token'];
    var userResponse = await _httpClient.get('me',
        options: Options(
            responseType: ResponseType.json,
            headers: {'Authorization': 'Bearer $accessToken'}));
    var userData = userResponse.data as Map<String, dynamic>;
    userData['access_token'] = accessToken;
    var userObj = User.fromJson(userData);
    usersBox.put('authenticated', userObj);
  }

  @override
  Future<void> signOut() async {
    var usersBox = await Hive.openBox<User>('users');
    var user = usersBox.get('authenticated');
    if (user == null) return;
    await _httpClient.post('logout',
        options: Options(headers: {'Authorization': user.accessToken}));
    await usersBox.delete('authenticated');
  }
}
