import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String displayName;
  @HiveField(2)
  final String email;
  @HiveField(3)
  final bool isAdmin;
  @HiveField(4)
  final String accessToken;

  User(this.id, this.displayName, this.email, this.isAdmin, this.accessToken);

  factory User.fromJson(dynamic json) => User(
      json['id'] as int,
      json['name'] as String,
      json['email'] as String,
      json['is_admin'] == 1,
      json['access_token'] as String);

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'email': email, 'isAdmin': isAdmin};
}
