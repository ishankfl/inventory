class User {
  final String id;
  final String fullName;
  final String email;

  User({
    required this.id,
    required this.fullName,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
      };

  factory User.empty() {
    return User(
      id: '',
      fullName: '',
      email: '',
      // passwordHash: '',
      // passwordSalt: '',
      // role: 0,
      // createdAt: DateTime.now(),
    );
  }
}
