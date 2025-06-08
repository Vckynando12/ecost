class Debt {
  final String id;
  final String title;
  final double amount;
  final String description;
  final DateTime dueDate;
  final DateTime createdAt;
  final bool isPaid;

  Debt({
    required this.id,
    required this.title,
    required this.amount,
    required this.description,
    required this.dueDate,
    required this.createdAt,
    this.isPaid = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'isPaid': isPaid,
    };
  }

  factory Debt.fromMap(Map<String, dynamic> map) {
    return Debt(
      id: map['id'],
      title: map['title'],
      amount: map['amount'].toDouble(),
      description: map['description'],
      dueDate: DateTime.parse(map['dueDate']),
      createdAt: DateTime.parse(map['createdAt']),
      isPaid: map['isPaid'] ?? false,
    );
  }
} 