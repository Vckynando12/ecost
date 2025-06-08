import 'package:flutter/foundation.dart';
import 'package:ecost/models/transaction.dart';
import 'package:ecost/services/database_helper.dart';

class TransactionProvider with ChangeNotifier {
  List<Transaction> _transactions = [];
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  DateTime? _startDate;
  DateTime? _endDate;

  // Getters for date filter
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  List<Transaction> get transactions {
    if (_startDate == null || _endDate == null) {
      return _transactions;
    }
    return _transactions.where((t) {
      return t.date.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
          t.date.isBefore(_endDate!.add(const Duration(days: 1)));
    }).toList();
  }

  // Getters for different transaction types
  List<Transaction> get incomes => transactions.where((t) => t.type == 'income').toList();
  List<Transaction> get expenses => transactions.where((t) => t.type == 'expense').toList();
  List<Transaction> get debts => transactions.where((t) => t.type == 'debt').toList();
  List<Transaction> get atmToCashTransfers => transactions.where((t) => 
    t.type == 'income' && 
    t.category == 'ATM to Cash Transfer'
  ).toList();

  // Get active debts (not paid)
  List<Transaction> get activeDebts => debts.where((t) => !t.isDebtPaid).toList();

  // Calculate totals
  double get totalAtm {
    double atmBalance = _calculateTotal('ATM');
    double transfersToCache = atmToCashTransfers.fold(0.0, (sum, transfer) => sum + transfer.amount);
    return atmBalance - transfersToCache;
  }
  
  double get totalCash => _calculateTotal('Cash');
  double get totalActiveDebts => activeDebts.fold(0, (sum, debt) => sum + debt.amount);
  
  double get totalIncome => incomes
      .where((t) => t.category != 'ATM to Cash Transfer')
      .fold(0, (sum, income) => sum + income.amount);
      
  double get totalExpense => expenses.fold(0, (sum, expense) => sum + expense.amount);
  double get balance => totalIncome - totalExpense;

  double _calculateTotal(String paymentMethod) {
    double incomeTotal = incomes
        .where((t) => t.paymentMethod == paymentMethod)
        .fold(0, (sum, income) => sum + income.amount);
    
    double expenseTotal = expenses
        .where((t) => t.paymentMethod == paymentMethod)
        .fold(0, (sum, expense) => sum + expense.amount);
    
    return incomeTotal - expenseTotal;
  }

  // Set date filter
  void setDateFilter(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  // Filter by time period
  void filterByTimePeriod(String period) {
    final now = DateTime.now();
    DateTime start;
    DateTime end;

    switch (period) {
      case 'day':
        start = DateTime(now.year, now.month, now.day);
        end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'week':
        start = now.subtract(Duration(days: now.weekday - 1));
        end = start.add(const Duration(days: 6));
        break;
      case 'month':
        start = DateTime(now.year, now.month, 1);
        end = DateTime(now.year, now.month + 1, 0);
        break;
      case 'year':
        start = DateTime(now.year, 1, 1);
        end = DateTime(now.year, 12, 31);
        break;
      default:
        start = DateTime(now.year, now.month, 1);
        end = DateTime(now.year, now.month + 1, 0);
    }

    setDateFilter(start, end);
  }

  // Load all transactions
  Future<void> loadTransactions() async {
    _transactions = await _dbHelper.getAllTransactions();
    notifyListeners();
  }

  // Add new transaction
  Future<void> addTransaction(Transaction transaction) async {
    await _dbHelper.insertTransaction(transaction);
    await loadTransactions();
  }

  // Add ATM to Cash transfer
  Future<void> addAtmToCashTransfer(double amount, String note) async {
    final transfer = Transaction(
      type: 'income',
      category: 'ATM to Cash Transfer',
      amount: amount,
      paymentMethod: 'Cash',
      date: DateTime.now(),
      note: note,
    );
    await addTransaction(transfer);
  }

  // Mark debt as paid
  Future<void> markDebtAsPaid(int id) async {
    final transaction = _transactions.firstWhere((t) => t.id == id);
    final updatedTransaction = Transaction(
      id: transaction.id,
      type: transaction.type,
      category: transaction.category,
      amount: transaction.amount,
      paymentMethod: transaction.paymentMethod,
      date: transaction.date,
      deadline: transaction.deadline,
      note: transaction.note,
      isDebtPaid: true,
    );
    await _dbHelper.updateTransaction(updatedTransaction);
    await loadTransactions();
  }

  // Delete transaction
  Future<void> deleteTransaction(int id) async {
    await _dbHelper.deleteTransaction(id);
    await loadTransactions();
  }

  // Get transactions by date range
  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await _dbHelper.getTransactionsByDateRange(startDate, endDate);
  }

  // Check for upcoming debt deadlines
  List<Transaction> getUpcomingDebtDeadlines(int daysThreshold) {
    final now = DateTime.now();
    return activeDebts.where((debt) {
      if (debt.deadline == null) return false;
      final daysUntilDeadline = debt.deadline!.difference(now).inDays;
      return daysUntilDeadline <= daysThreshold && daysUntilDeadline >= 0;
    }).toList();
  }

  // Initialize transactions
  Future<void> init() async {
    await loadTransactions();
  }
} 