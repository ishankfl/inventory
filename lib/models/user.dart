class User {
  final String id;
  final String fullName;
  final String email;
  final int role;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'role': role,
      };

  factory User.empty() {
    return User(id: '', fullName: '', email: '', role: 1);
  }
}
