class Transaction {
  final int? id;
  final double amount;
  final String type; // 'income', 'expense', 'debt'
  final String category;
  final String paymentMethod; // 'ATM' or 'Cash'
  final DateTime date;
  final String? note;
  final bool isDebtPaid; // Only for debt transactions
  final DateTime? deadline; // Only for debt transactions

  Transaction({
    this.id,
    required this.amount,
    required this.type,
    required this.category,
    required this.paymentMethod,
    required this.date,
    this.note,
    this.isDebtPaid = false,
    this.deadline,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'category': category,
      'paymentMethod': paymentMethod,
      'date': date.toIso8601String(),
      'note': note,
      'isDebtPaid': isDebtPaid ? 1 : 0,
      'deadline': deadline?.toIso8601String(),
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      amount: map['amount'],
      type: map['type'],
      category: map['category'],
      paymentMethod: map['paymentMethod'],
      date: DateTime.parse(map['date']),
      note: map['note'],
      isDebtPaid: map['isDebtPaid'] == 1,
      deadline: map['deadline'] != null ? DateTime.parse(map['deadline']) : null,
    );
  }
} 