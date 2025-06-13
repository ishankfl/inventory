import 'package:inventory/models/user.dart';

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
