import 'issue_item.dart';
import 'department.dart';
import 'user.dart';

class ProductIssue {
  final String id;
  final String departmentId;
  final Department department;
  final String issuedById;
  final User issuedBy;
  final DateTime issueDate;
  final bool isCompleted;
  final List<IssueItem> issueItems;

  ProductIssue({
    required this.id,
    required this.departmentId,
    required this.department,
    required this.issuedById,
    required this.issuedBy,
    required this.issueDate,
    required this.isCompleted,
    required this.issueItems,
  });

  factory ProductIssue.fromJson(Map<String, dynamic> json) {
    return ProductIssue(
      id: json['id'],
      departmentId: json['departmentId'],
      department: Department.fromJson(json['department']),
      issuedById: json['issuedById'],
      issuedBy: User.fromJson(json['issuedBy']),
      issueDate: DateTime.parse(json['issueDate']),
      isCompleted: json['isCompleted'],
      issueItems: (json['issueItems'] as List)
          .map((item) => IssueItem.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'departmentId': departmentId,
      'department': department.toJson(),
      'issuedById': issuedById,
      'issuedBy': issuedBy.toJson(),
      'issueDate': issueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'issueItems': issueItems.map((e) => e.toJson()).toList(),
    };
  }
}
