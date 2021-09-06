import 'dart:convert';

import 'package:hive/hive.dart';

class User {
  final String displayName;
  final String email;
  final bool isAdmin;

  User(this.displayName, this.email, this.isAdmin);

  factory User.fromJson(dynamic json) => User(json['displayName'] as String,
      json['email'] as String, json['isAdmin'] as bool);

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'email': email, 'isAdmin': isAdmin};
}

class UserAdapter extends TypeAdapter<User> {
  @override
  final typeId = 0;

  @override
  User read(BinaryReader reader) {
    return User.fromJson(json.decode(reader.read()));
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer.writeString(json.encode(obj.toJson()));
  }
}
