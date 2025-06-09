import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/debt.dart';

class DebtProvider with ChangeNotifier {
  final List<Debt> _debts = [];
  
  List<Debt> get debts => [..._debts];
  List<Debt> get activeDebts => _debts.where((debt) => !debt.isPaid).toList();
  List<Debt> get paidDebts => _debts.where((debt) => debt.isPaid).toList();
  
  double get totalDebt {
    return activeDebts.fold(0, (sum, debt) => sum + debt.amount);
  }

  void addDebt(String title, double amount, String description, DateTime dueDate) {
    final newDebt = Debt(
      id: const Uuid().v4(),
      title: title,
      amount: amount,
      description: description,
      dueDate: dueDate,
      createdAt: DateTime.now(),
    );
    
    _debts.add(newDebt);
    notifyListeners();
  }

  void toggleDebtStatus(String debtId) {
    final debtIndex = _debts.indexWhere((debt) => debt.id == debtId);
    if (debtIndex >= 0) {
      final debt = _debts[debtIndex];
      _debts[debtIndex] = Debt(
        id: debt.id,
        title: debt.title,
        amount: debt.amount,
        description: debt.description,
        dueDate: debt.dueDate,
        createdAt: debt.createdAt,
        isPaid: !debt.isPaid,
      );
      notifyListeners();
    }
  }

  void deleteDebt(String debtId) {
    _debts.removeWhere((debt) => debt.id == debtId);
    notifyListeners();
  }
} 