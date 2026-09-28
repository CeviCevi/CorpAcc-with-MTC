import 'dart:developer';

class UserModel {
  final String id;
  final String login;
  final String email;
  final String password;
  final String image;
  final String role;
  final String createAt;

  UserModel({
    required this.id,
    required this.login,
    required this.email,
    required this.password,
    required this.image,
    this.role = "moderation",
    required this.createAt,
  });

  @override
  String toString() {
    return 'UserModel{id=$id, login=$login, email=$email, password=$password, image=$image, role=$role, createAt=$createAt}';
  }

  static UserModel get empty {
    return UserModel(
      id: "NoN",
      login: "NoN",
      email: "NoN",
      password: "Non",
      image: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8DwHwAFBQIAX8jx0gAAAABJRU5ErkJggg==",
      createAt: "1969-07-20T20:18:04.000Z",
    );
  }

  void print() {
    log(toString());
  }
}
