class User {
  final String displayName;
  final String email;
  final bool isAdmin;

  User(this.displayName, this.email, this.isAdmin);

  factory User.fromJson(Map<String, dynamic> json) => User(
      json['displayName'] as String,
      json['email'] as String,
      json['isAdmin'] as bool);

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'email': email, 'isAdmin': isAdmin};
}
