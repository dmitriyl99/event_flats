import 'package:event_flats/models/user.dart' as UserModel;
import 'package:event_flats/services/exceptions/authentication_failed.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

abstract class AuthenticationService {
  Future<void> login(String email, String password);
  Future<void> signOut();
  Future<UserModel.User> getUser();
}

class FirebaseAuthenticationService implements AuthenticationService {
  @override
  Future<UserModel.User> getUser() {
    // TODO: implement getUser
    throw UnimplementedError();
  }

  @override
  Future<void> login(String email, String password) async {
    UserCredential? userCredential = null;
    try {
      userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException {
      throw new AuthenticationFailed();
    }
    String userUid = userCredential.user!.uid;
    var data = await FirebaseDatabase.instance
        .reference()
        .child('users')
        .orderByKey()
        .equalTo(userUid)
        .once();
    var value = data.value[userUid];
    UserModel.User user = UserModel.User.fromJson(value);
    print(data);
  }

  @override
  Future<void> signOut() {
    // TODO: implement signOut
    throw UnimplementedError();
  }
}
