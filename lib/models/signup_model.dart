class Signup {
  final int id;
  final String? email;
  final String? username;

  Signup({
    required this.id,
    this.email,
    this.username,
  });

  factory Signup.fromJson(Map<String, dynamic> json) {
    return Signup(
      id: json['id'] as int,
      email: json['email'] as String?,
      username: json['username'] as String?,
    );
  }
}
