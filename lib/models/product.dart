import 'package:inventory/models/category.dart';
import 'package:inventory/models/user.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final int quantity;
  final double price;
  final String categoryId;
  final String userId;
  final User user;
  final Categoires category;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.quantity,
    required this.price,
    required this.categoryId,
    required this.userId,
    required this.user,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      quantity: json['quantity'],
      price: json['price'].toDouble(),
      categoryId: json['categoryId'],
      userId: json['userId'],
      user: json['user'] != null
          ? User.fromJson(json['user'])
          : User.empty(), // 👈
      category: json['category'] != null
          ? Categoires.fromJson(json['category'])
          : Categoires.empty(), // 👈
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'quantity': quantity,
      'price': price,
      'categoryId': categoryId,
      'userId': userId,
      'user': user.toJson(),
      'category': category.toJson(),
    };
  }
}
