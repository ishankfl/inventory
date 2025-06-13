class Product {
  final String id;
  final String name;
  final String description;
  final int quantity;
  final double price;
  final String categoryId;
  final String userId;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.quantity,
    required this.price,
    required this.categoryId,
    required this.userId,
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
    );
  }
}
