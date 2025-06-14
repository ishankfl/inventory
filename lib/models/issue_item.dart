import 'product.dart';

class IssueItem {
  final String id;
  final String productIssueId;
  final String productId;
  final Product? product;
  final int quantityIssued;

  IssueItem({
    required this.id,
    required this.productIssueId,
    required this.productId,
    this.product,
    required this.quantityIssued,
  });

  factory IssueItem.fromJson(Map<String, dynamic> json) {
    return IssueItem(
      id: json['id'],
      productIssueId: json['productIssueId'],
      productId: json['productId'],
      product:
          json['product'] != null ? Product.fromJson(json['product']) : null,
      quantityIssued: json['quantityIssued'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productIssueId': productIssueId,
      'productId': productId,
      'product': product?.toJson(),
      'quantityIssued': quantityIssued,
    };
  }
}
