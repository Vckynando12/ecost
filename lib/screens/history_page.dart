import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:ecost/models/transaction.dart';
import 'package:ecost/providers/transaction_provider.dart';
import 'package:ecost/utils/app_theme.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _selectedType = 'all';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    // Set default date range to current month
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = DateTime(now.year, now.month + 1, 0);
    
    // Apply initial filter
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider = Provider.of<TransactionProvider>(context, listen: false);
        provider.setDateFilter(_startDate, _endDate);
      }
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    if (!mounted) return;
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _startDate ?? DateTime.now(),
        end: _endDate ?? DateTime.now(),
      ),
    );

    if (picked != null && mounted) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      
      // Update provider's date filter
      final provider = Provider.of<TransactionProvider>(context, listen: false);
      provider.setDateFilter(_startDate, _endDate);
    }
  }

  void _onFilterSelected(String value) {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    if (value == 'custom') {
      _selectDateRange(context);
    } else {
      provider.filterByTimePeriod(value);
      // Update local state
      setState(() {
        _startDate = provider.transactions.first.date;
        _endDate = provider.transactions.last.date;
      });
    }
  }

  Color _getTransactionColor(String type) {
    switch (type) {
      case 'income':
        return Colors.green;
      case 'expense':
        return Colors.red;
      case 'debt':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getTransactionIcon(String type) {
    switch (type) {
      case 'income':
        return Icons.add_circle;
      case 'expense':
        return Icons.remove_circle;
      case 'debt':
        return Icons.warning;
      default:
        return Icons.attach_money;
    }
  }

  void _showTransactionDetails(Transaction transaction) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transaction.type.toUpperCase(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _getTransactionColor(transaction.type),
                ),
              ),
              const SizedBox(height: 16),
              _detailRow('Amount', NumberFormat.currency(
                locale: 'id_ID',
                symbol: 'Rp',
                decimalDigits: 0,
              ).format(transaction.amount)),
              _detailRow('Category', transaction.category),
              _detailRow('Payment Method', transaction.paymentMethod),
              _detailRow('Date', DateFormat('dd MMMM yyyy').format(transaction.date)),
              if (transaction.deadline != null)
                _detailRow('Deadline', DateFormat('dd MMMM yyyy').format(transaction.deadline!)),
              if (transaction.note != null && transaction.note!.isNotEmpty)
                _detailRow('Note', transaction.note!),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Transaction History'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedType,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All Transactions')),
                        DropdownMenuItem(value: 'income', child: Text('Income')),
                        DropdownMenuItem(value: 'expense', child: Text('Expense')),
                        DropdownMenuItem(value: 'debt', child: Text('Debt')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedType = value;
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDateRange(context),
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
                                _getFilterText(_startDate!, _endDate!),
                                style: const TextStyle(fontSize: 16),
                              ),
                              const Icon(Icons.calendar_today),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Icon(Icons.filter_list),
                      ),
                      onSelected: _onFilterSelected,
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'day',
                          child: Text('Today'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'week',
                          child: Text('This Week'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'month',
                          child: Text('This Month'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'year',
                          child: Text('This Year'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'custom',
                          child: Text('Custom Date Range'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<TransactionProvider>(
              builder: (context, provider, child) {
                List<Transaction> filteredTransactions = provider.transactions;

                // Apply type filter
                if (_selectedType != 'all') {
                  filteredTransactions = filteredTransactions
                      .where((t) => t.type == _selectedType)
                      .toList();
                }

                // Apply date filter
                filteredTransactions = filteredTransactions.where((t) {
                  return t.date.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
                      t.date.isBefore(_endDate!.add(const Duration(days: 1)));
                }).toList();

                // Sort by date (newest first)
                filteredTransactions.sort((a, b) => b.date.compareTo(a.date));

                if (filteredTransactions.isEmpty) {
                  return const Center(
                    child: Text('No transactions found'),
                  );
                }

                return ListView.builder(
                  itemCount: filteredTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = filteredTransactions[index];
                    return Slidable(
                      key: Key(transaction.id.toString()),
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          if (transaction.type == 'debt' && !transaction.isDebtPaid)
                            SlidableAction(
                              onPressed: (_) async {
                                await provider.markDebtAsPaid(transaction.id!);
                                if (mounted) {
                                  QuickAlert.show(
                                    context: context,
                                    type: QuickAlertType.success,
                                    text: 'Debt marked as paid successfully!',
                                  );
                                }
                              },
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              icon: Icons.check_circle,
                              label: 'Mark Paid',
                            ),
                          SlidableAction(
                            onPressed: (_) async {
                              await provider.deleteTransaction(transaction.id!);
                              if (mounted) {
                                QuickAlert.show(
                                  context: context,
                                  type: QuickAlertType.success,
                                  text: 'Transaction deleted successfully!',
                                );
                              }
                            },
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Delete',
                          ),
                        ],
                      ),
                      child: ListTile(
                        onTap: () => _showTransactionDetails(transaction),
                        leading: CircleAvatar(
                          backgroundColor: _getTransactionColor(transaction.type).withOpacity(0.2),
                          child: Icon(
                            _getTransactionIcon(transaction.type),
                            color: _getTransactionColor(transaction.type),
                          ),
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transaction.category,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (transaction.note?.isNotEmpty ?? false)
                              Text(
                                transaction.note!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                        subtitle: Text(
                          DateFormat('dd MMMM yyyy').format(transaction.date),
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        trailing: Text(
                          NumberFormat.currency(
                            locale: 'id_ID',
                            symbol: 'Rp',
                            decimalDigits: 0,
                          ).format(transaction.amount),
                          style: TextStyle(
                            color: _getTransactionColor(transaction.type),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getFilterText(DateTime start, DateTime end) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);

    if (startDate == today && endDate == today) {
      return 'Today';
    }

    if (startDate == DateTime(now.year, now.month, 1) &&
        endDate == DateTime(now.year, now.month + 1, 0)) {
      return 'This Month';
    }

    if (startDate == DateTime(now.year, 1, 1) &&
        endDate == DateTime(now.year, 12, 31)) {
      return 'This Year';
    }

    return '${DateFormat('dd MMM').format(start)} - ${DateFormat('dd MMM').format(end)}';
  }
} 