import 'package:event_flats/models/user.dart' as UserModel;

abstract class AuthenticationService {
  Future<void> login(String email, String password);
  Future<void> signOut();
  UserModel.User? getUser();
}
