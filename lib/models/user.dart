import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User {
  @HiveField(0)
  final String displayName;
  @HiveField(1)
  final String email;
  @HiveField(2)
  final bool isAdmin;

  User(this.displayName, this.email, this.isAdmin);

  factory User.fromJson(dynamic json) => User(json['displayName'] as String,
      json['email'] as String, json['isAdmin'] as bool);

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'email': email, 'isAdmin': isAdmin};
}
