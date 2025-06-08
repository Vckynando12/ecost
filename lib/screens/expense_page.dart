import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:ecost/models/transaction.dart';
import 'package:ecost/providers/transaction_provider.dart';
import 'package:ecost/utils/app_theme.dart';
import 'package:intl/intl.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key});

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Add Expense / Debt'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Expense'),
            Tab(text: 'Debt'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ExpenseForm(),
          DebtForm(),
        ],
      ),
    );
  }
}

class ExpenseForm extends StatefulWidget {
  const ExpenseForm({super.key});

  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedPaymentMethod = 'ATM';
  String _selectedCategory = 'Food';

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Food',
      'icon': Icons.restaurant,
    },
    {
      'name': 'Transportation',
      'icon': Icons.directions_car,
    },
    {
      'name': 'Shopping',
      'icon': Icons.shopping_bag,
    },
    {
      'name': 'Entertainment',
      'icon': Icons.movie,
    },
    {
      'name': 'Bills',
      'icon': Icons.receipt_long,
    },
    {
      'name': 'Health',
      'icon': Icons.medical_services,
    },
    {
      'name': 'Education',
      'icon': Icons.school,
    },
    {
      'name': 'Other',
      'icon': Icons.more_horiz,
    },
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<TransactionProvider>(context, listen: false);
      final transaction = Transaction(
        amount: double.parse(_amountController.text.replaceAll(RegExp(r'[^0-9]'), '')),
        type: 'expense',
        category: _selectedCategory,
        paymentMethod: _selectedPaymentMethod,
        date: _selectedDate,
        note: _noteController.text.isEmpty ? null : _noteController.text,
      );

      provider.addTransaction(transaction).then((_) {
        if (!mounted) return;
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          text: 'Expense added successfully!',
          confirmBtnColor: Theme.of(context).colorScheme.primary,
        );
        _formKey.currentState!.reset();
        _amountController.clear();
        _noteController.clear();
        setState(() {
          _selectedDate = DateTime.now();
          _selectedPaymentMethod = 'ATM';
          _selectedCategory = 'Food';
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _amountController,
              decoration: AppTheme.textFieldDecoration('Amount (Rp)'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                return null;
              },
              onChanged: (value) {
                if (value.isNotEmpty) {
                  final number = double.parse(value.replaceAll(RegExp(r'[^0-9]'), ''));
                  final formatted = NumberFormat.currency(
                    locale: 'id_ID',
                    symbol: 'Rp',
                    decimalDigits: 0,
                  ).format(number);
                  _amountController.value = TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(offset: formatted.length),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
              ),
              items: _categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category['name'] as String,
                  child: Row(
                    children: [
                      Icon(category['icon'] as IconData, size: 20, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(category['name'] as String),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedPaymentMethod,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'ATM', child: Text('ATM')),
                    DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedPaymentMethod = value;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('dd MMMM yyyy').format(_selectedDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              decoration: AppTheme.textFieldDecoration('Note (Optional)'),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                ),
              ),
              child: const Text(
                'Save Expense',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DebtForm extends StatefulWidget {
  const DebtForm({super.key});

  @override
  State<DebtForm> createState() => _DebtFormState();
}

class _DebtFormState extends State<DebtForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _nameController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  DateTime _selectedDeadline = DateTime.now().add(const Duration(days: 7));

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isDeadline) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isDeadline ? _selectedDeadline : _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );
    if (picked != null) {
      setState(() {
        if (isDeadline) {
          _selectedDeadline = picked;
        } else {
          _selectedDate = picked;
        }
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<TransactionProvider>(context, listen: false);
      final transaction = Transaction(
        amount: double.parse(_amountController.text.replaceAll(RegExp(r'[^0-9]'), '')),
        type: 'debt',
        category: _nameController.text,
        paymentMethod: 'Debt',
        date: _selectedDate,
        deadline: _selectedDeadline,
        note: _noteController.text.isEmpty ? null : _noteController.text,
      );

      provider.addTransaction(transaction).then((_) {
        if (!mounted) return;
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          text: 'Debt added successfully!',
          confirmBtnColor: Theme.of(context).colorScheme.primary,
        );
        _formKey.currentState!.reset();
        _amountController.clear();
        _nameController.clear();
        _noteController.clear();
        setState(() {
          _selectedDate = DateTime.now();
          _selectedDeadline = DateTime.now().add(const Duration(days: 7));
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: AppTheme.textFieldDecoration('Debt Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the debt name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: AppTheme.textFieldDecoration('Amount (Rp)'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                return null;
              },
              onChanged: (value) {
                if (value.isNotEmpty) {
                  final number = double.parse(value.replaceAll(RegExp(r'[^0-9]'), ''));
                  final formatted = NumberFormat.currency(
                    locale: 'id_ID',
                    symbol: 'Rp',
                    decimalDigits: 0,
                  ).format(number);
                  _amountController.value = TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(offset: formatted.length),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectDate(context, false),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Date: ${DateFormat('dd MMMM yyyy').format(_selectedDate)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectDate(context, true),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Deadline: ${DateFormat('dd MMMM yyyy').format(_selectedDeadline)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              decoration: AppTheme.textFieldDecoration('Note (Optional)'),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                ),
              ),
              child: const Text(
                'Save Debt',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 