import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/debt_provider.dart';
import '../models/debt.dart';

class DebtsPage extends StatefulWidget {
  const DebtsPage({Key? key}) : super(key: key);

  @override
  State<DebtsPage> createState() => _DebtsPageState();
}

class _DebtsPageState extends State<DebtsPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDueDate = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showAddDebtDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New Debt'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Due Date: '),
                  TextButton(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedDueDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _selectedDueDate = pickedDate;
                        });
                      }
                    },
                    child: Text(
                      DateFormat('dd/MM/yyyy').format(_selectedDueDate),
                    ),
                  ),
                ],
              ),
            ],
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
                final provider = Provider.of<DebtProvider>(context, listen: false);
                provider.addDebt(
                  _titleController.text,
                  double.parse(_amountController.text),
                  _descriptionController.text,
                  _selectedDueDate,
                );
                Navigator.of(context).pop();
                _titleController.clear();
                _amountController.clear();
                _descriptionController.clear();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildDebtCard(Debt debt) {
    final formatter = NumberFormat('#,###');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          title: Text(
            debt.title,
            style: TextStyle(
              decoration: debt.isPaid ? TextDecoration.lineThrough : null,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                debt.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Due: ${DateFormat('dd/MM/yyyy').format(debt.dueDate)}',
                style: TextStyle(
                  color: debt.dueDate.isBefore(DateTime.now()) && !debt.isPaid
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
                    debt.isPaid ? Icons.check_circle : Icons.check_circle_outline,
                    color: debt.isPaid ? Colors.green : Colors.grey,
                  ),
                  onPressed: () {
                    Provider.of<DebtProvider>(context, listen: false)
                        .toggleDebtStatus(debt.id);
                  },
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  constraints: const BoxConstraints(),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    Provider.of<DebtProvider>(context, listen: false)
                        .deleteDebt(debt.id);
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
      body: Consumer<DebtProvider>(
        builder: (ctx, debtProvider, child) {
          final activeDebts = debtProvider.activeDebts;
          final paidDebts = debtProvider.paidDebts;

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
                      'Rp ${NumberFormat('#,###').format(debtProvider.totalDebt)}',
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