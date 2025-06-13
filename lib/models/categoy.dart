class Categoires {
  final String id;
  final String name;
  final String description;
  final String userId;
  final User user;

  Categoires({
    required this.id,
    required this.name,
    required this.description,
    required this.userId,
    required this.user,
  });

  factory Categoires.fromJson(Map<String, dynamic> json) {
    return Categoires(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      userId: json['userId'],
      user: User.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'userId': userId,
        'user': user.toJson(),
      };
}

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
}
