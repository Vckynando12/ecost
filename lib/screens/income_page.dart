import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:ecost/models/transaction.dart';
import 'package:ecost/providers/transaction_provider.dart';
import 'package:intl/intl.dart';

class IncomePage extends StatefulWidget {
  const IncomePage({super.key});

  @override
  State<IncomePage> createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage> with SingleTickerProviderStateMixin {
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
        title: const Text('Add Income / Transfer'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Income'),
            Tab(text: 'ATM to Cash'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          IncomeForm(),
          AtmToCashForm(),
        ],
      ),
    );
  }
}

class IncomeForm extends StatefulWidget {
  const IncomeForm({super.key});

  @override
  State<IncomeForm> createState() => _IncomeFormState();
}

class _IncomeFormState extends State<IncomeForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _sourceController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedPaymentMethod = 'ATM';
  String _selectedCategory = 'Salary';

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Salary',
      'icon': Icons.account_balance_wallet,
    },
    {
      'name': 'Bonus',
      'icon': Icons.star,
    },
    {
      'name': 'Investment',
      'icon': Icons.trending_up,
    },
    {
      'name': 'Gift',
      'icon': Icons.card_giftcard,
    },
    {
      'name': 'Other',
      'icon': Icons.more_horiz,
    },
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _sourceController.dispose();
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
    if (picked != null && picked != _selectedDate && mounted) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<TransactionProvider>(context, listen: false);
      final transaction = Transaction(
        type: 'income',
        category: _selectedCategory,
        amount: double.parse(_amountController.text.replaceAll(RegExp(r'[^0-9]'), '')),
        paymentMethod: _selectedPaymentMethod,
        date: _selectedDate,
        note: _noteController.text,
      );

      provider.addTransaction(transaction).then((_) {
        if (!mounted) return;
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          text: 'Income added successfully!',
        ).then((_) {
          if (!mounted) return;
          Navigator.pop(context);
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
                keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: 'Rp ',
              ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  return null;
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
                      Icon(category['icon'] as IconData, size: 20, color: Colors.green),
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
            DropdownButtonFormField<String>(
              value: _selectedPaymentMethod,
              decoration: const InputDecoration(
                labelText: 'Payment Method',
              ),
                    items: const [
                      DropdownMenuItem(value: 'ATM', child: Text('ATM')),
                      DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                    ],
              onChanged: (String? newValue) {
                if (newValue != null) {
                        setState(() {
                    _selectedPaymentMethod = newValue;
                        });
                      }
                    },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                    Text(DateFormat('dd MMMM yyyy').format(_selectedDate)),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note (Optional)',
              ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
              child: const Text('Add Income'),
            ),
          ],
        ),
      ),
    );
  }
}

class AtmToCashForm extends StatefulWidget {
  const AtmToCashForm({super.key});

  @override
  State<AtmToCashForm> createState() => _AtmToCashFormState();
}

class _AtmToCashFormState extends State<AtmToCashForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<TransactionProvider>(context, listen: false);
      final amount = double.parse(_amountController.text.replaceAll(RegExp(r'[^0-9]'), ''));
      
      provider.addAtmToCashTransfer(amount, _noteController.text).then((_) {
        if (!mounted) return;
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          text: 'Transfer completed successfully!',
        ).then((_) {
          if (!mounted) return;
          Navigator.pop(context);
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
            const Text(
              'Transfer money from ATM to Cash',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
                ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: 'Rp ',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                final amount = double.tryParse(value.replaceAll(RegExp(r'[^0-9]'), ''));
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note (Optional)',
                hintText: 'e.g., ATM withdrawal for monthly expenses',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Transfer to Cash'),
            ),
          ],
        ),
      ),
    );
  }
} 