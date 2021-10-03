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
  @HiveField(3)
  final String accessToken;

  User(this.displayName, this.email, this.isAdmin, this.accessToken);

  factory User.fromJson(dynamic json) => User(
      json['name'] as String,
      json['email'] as String,
      json['is_admin'] as bool,
      json['access_token'] as String);

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'email': email, 'isAdmin': isAdmin};
}
