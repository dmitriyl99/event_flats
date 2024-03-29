import 'package:dio/dio.dart';
import 'package:event_flats/models/user.dart';
import 'package:event_flats/services/authentication.dart';
import 'package:event_flats/services/exceptions/authentication_failed.dart';
import 'package:event_flats/services/exceptions/no_internet.dart';
import 'package:hive/hive.dart';

class ApiAuthenticationService extends AuthenticationService {
  final Dio _httpClient = new Dio(BaseOptions(
      baseUrl: 'http://161.35.61.88/api/v1/auth/',
      receiveDataWhenStatusError: true));

  static User? _currentUser;

  static Future<void> init() async {
    User? user;
    var usersBox = await Hive.openBox<User>('users');
    if (usersBox.containsKey('authenticated'))
      user = usersBox.get('authenticated') as User;
    _currentUser = user;
  }

  @override
  User? getUser() {
    return _currentUser;
  }

  @override
  Future<void> login(String email, String password) async {
    var payload = {"email": email, "password": password};
    Response<dynamic> response;
    try {
      response = await _httpClient.post('login/access-token',
          data: payload, options: Options(responseType: ResponseType.json));
    } on DioError catch (error) {
      if (error.response == null) throw new NoInternetException();
      if (error.response!.statusCode == 401) {
        throw new AuthenticationFailed();
      }
      throw error;
    }
    var usersBox = await Hive.openBox<User>('users');
    var data = response.data as Map<String, dynamic>;
    var accessToken = data['access_token'];
    var userResponse = await _httpClient.get('me',
        options: Options(
            responseType: ResponseType.json,
            headers: {'Authorization': 'Bearer $accessToken'}));
    var userData = userResponse.data as Map<String, dynamic>;
    userData['access_token'] = accessToken;
    var userObj = User.fromJson(userData);
    usersBox.put('authenticated', userObj);
    await init();
  }

  @override
  Future<void> signOut() async {
    var usersBox = await Hive.openBox<User>('users');
    var user = usersBox.get('authenticated');
    if (user == null) return;
    await _httpClient.post('logout',
        options:
            Options(headers: {'Authorization': 'Bearer ${user.accessToken}'}));
    await usersBox.delete('authenticated');
    await init();
  }
}
