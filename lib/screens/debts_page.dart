import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';

class DebtsPage extends StatefulWidget {
  const DebtsPage({super.key});

  @override
  State<DebtsPage> createState() => _DebtsPageState();
}

class _DebtsPageState extends State<DebtsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  DateTime _selectedDeadline = DateTime.now().add(const Duration(days: 7));

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _showAddDebtDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New Debt'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Debt Name'),
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
                  decoration: const InputDecoration(labelText: 'Amount (Rp)'),
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
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2025),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
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
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDeadline,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2025),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDeadline = picked;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
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
                  decoration: const InputDecoration(labelText: 'Note (Optional)'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
                transactionProvider.addTransaction(
                  Transaction(
                    amount: double.parse(_amountController.text.replaceAll(RegExp(r'[^0-9]'), '')),
                    type: 'debt',
                    category: _nameController.text,
                    paymentMethod: 'Debt',
                    date: _selectedDate,
                    deadline: _selectedDeadline,
                    note: _noteController.text.isEmpty ? null : _noteController.text,
                  ),
                );
                Navigator.of(context).pop();
                _nameController.clear();
                _amountController.clear();
                _noteController.clear();
                setState(() {
                  _selectedDate = DateTime.now();
                  _selectedDeadline = DateTime.now().add(const Duration(days: 7));
                });
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildDebtCard(Transaction debt) {
    final formatter = NumberFormat('#,###');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          title: Text(
            debt.category,
            style: TextStyle(
              decoration: debt.isDebtPaid ? TextDecoration.lineThrough : null,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (debt.note != null && debt.note!.isNotEmpty)
                Text(
                  debt.note!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              if (debt.deadline != null)
                Text(
                  'Due: ${DateFormat('dd/MM/yyyy').format(debt.deadline!)}',
                  style: TextStyle(
                    color: (debt.deadline!.isBefore(DateTime.now()) && !debt.isDebtPaid)
                        ? Colors.red
                        : null,
                  ),
                ),
            ],
          ),
          trailing: Container(
            constraints: const BoxConstraints(maxWidth: 200),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    'Rp ${formatter.format(debt.amount)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    debt.isDebtPaid ? Icons.check_circle : Icons.check_circle_outline,
                    color: debt.isDebtPaid ? Colors.green : Colors.grey,
                  ),
                  onPressed: () async {
                    if (debt.id != null && !debt.isDebtPaid) {
                      final paymentMethod = await showDialog<String>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Pilih Metode Pembayaran'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                title: const Text('ATM'),
                                onTap: () => Navigator.of(ctx).pop('ATM'),
                              ),
                              ListTile(
                                title: const Text('Cash'),
                                onTap: () => Navigator.of(ctx).pop('Cash'),
                              ),
                            ],
                          ),
                        ),
                      );
                      if (paymentMethod != null) {
                        // 1. Tandai debt sebagai lunas
                        await Provider.of<TransactionProvider>(context, listen: false)
                            .markDebtAsPaid(debt.id!);
                        // 2. Tambahkan transaksi expense ke history
                        await Provider.of<TransactionProvider>(context, listen: false)
                            .addTransaction(Transaction(
                          amount: debt.amount,
                          type: 'expense',
                          category: 'Debt Payment',
                          paymentMethod: paymentMethod,
                          date: DateTime.now(),
                          note: 'Pelunasan utang: ${debt.category}',
                        ));
                      }
                    }
                  },
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  constraints: const BoxConstraints(),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () async {
                    if (debt.id != null) {
                      await Provider.of<TransactionProvider>(context, listen: false)
                          .deleteTransaction(debt.id!);
                    }
                  },
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddDebtDialog,
          ),
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (ctx, provider, child) {
          final activeDebts = provider.activeDebts;
          final paidDebts = provider.debts.where((d) => d.isDebtPaid).toList();

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Outstanding Debt:',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Rp ${NumberFormat('#,###').format(provider.totalActiveDebts)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      const TabBar(
                        tabs: [
                          Tab(text: 'Active Debts'),
                          Tab(text: 'Paid Debts'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            activeDebts.isEmpty
                                ? const Center(
                                    child: Text('No active debts'),
                                  )
                                : ListView.builder(
                                    itemCount: activeDebts.length,
                                    itemBuilder: (ctx, i) =>
                                        _buildDebtCard(activeDebts[i]),
                                  ),
                            paidDebts.isEmpty
                                ? const Center(
                                    child: Text('No paid debts'),
                                  )
                                : ListView.builder(
                                    itemCount: paidDebts.length,
                                    itemBuilder: (ctx, i) =>
                                        _buildDebtCard(paidDebts[i]),
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
} 