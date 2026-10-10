import 'dart:developer';

class UserModel {
  final String id;
  final String login;
  final String email;
  final String password;
  final String image;
  final String role;
  final String createAt;

  const new({
    required this.id,
    required this.login,
    required this.email,
    required this.password,
    required this.image,
    required this.role,
    required this.createAt,
  });

  @override
  String toString() {
    return 'UserModel{id=$id, login=$login, email=$email, password=$password, image=$image, role=$role, createAt=$createAt}';
  }

  static const empty = UserModel(
    id: "NoN",
    login: "NoN",
    email: "NoN",
    password: "Non",
    image: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8DwHwAFBQIAX8jx0gAAAABJRU5ErkJggg==",
    role: "NoN",
    createAt: "1969-07-20T20:18:04.000Z",
  );

  void print() {
    log(toString());
  }

  UserModel copyWith({
    String? id,
    String? login,
    String? email,
    String? password,
    String? image,
    String? role,
    String? createAt,
    UserModel? empty,
  }) {
    return UserModel(
      id: id ?? this.id,
      login: login ?? this.login,
      email: email ?? this.email,
      password: password ?? this.password,
      image: image ?? this.image,
      role: role ?? this.role,
      createAt: createAt ?? this.createAt,
    );
  }
}
