import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_flats/models/user.dart' as UserModel;
import 'package:event_flats/services/exceptions/authentication_failed.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract class AuthenticationService {
  Future<void> login(String email, String password);
  Future<void> signOut();
  Future<UserModel.User?> getUser();
}

class FirebaseAuthenticationService implements AuthenticationService {
  @override
  Future<UserModel.User?> getUser() async {
    var usersBox = await Hive.openBox<UserModel.User>('users');
    if (usersBox.containsKey('authenticated'))
      return usersBox.get('authenticated') as UserModel.User;
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      var data = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      var value = data.data()!;
      UserModel.User user = UserModel.User.fromJson(value);
      usersBox.put('authenticated', user);
      return user;
    }
    return null;
  }

  @override
  Future<void> login(String email, String password) async {
    UserCredential? userCredential;
    try {
      userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException {
      throw new AuthenticationFailed();
    }
    String userUid = userCredential.user!.uid;
    var data =
        await FirebaseFirestore.instance.collection('users').doc(userUid).get();
    var value = data.data()!;
    UserModel.User user = UserModel.User.fromJson(value);
    var usersBox = await Hive.openBox<UserModel.User>('users');
    usersBox.put('authenticated', user);
  }

  @override
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    var usersBox = await Hive.openBox<UserModel.User>('users');
    usersBox.delete('authenticated');
  }
}
