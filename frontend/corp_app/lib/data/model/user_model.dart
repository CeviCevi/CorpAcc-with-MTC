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
}
