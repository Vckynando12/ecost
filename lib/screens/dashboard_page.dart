import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ecost/providers/transaction_provider.dart';
import 'package:ecost/providers/debt_provider.dart';
import 'package:ecost/utils/app_theme.dart';
import 'package:ecost/utils/pdf_generator.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Consumer<TransactionProvider>(
          builder: (context, provider, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/logo.png',
                            width: 40,
                            height: 40,
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'E-cost',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'powered by vcky.naand01',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () async {
                              try {
                                await PdfGenerator.generateAndSavePdf(
                                  transactions: provider.transactions,
                                  totalAtm: provider.totalAtm,
                                  totalCash: provider.totalCash,
                                  totalActiveDebts: provider.totalActiveDebts,
                                  totalExpense: provider.totalExpense,
                                  startDate: provider.startDate ?? DateTime.now(),
                                  endDate: provider.endDate ?? DateTime.now(),
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('PDF generated successfully!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to generate PDF: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.picture_as_pdf),
                            tooltip: 'Export PDF',
                          ),
                          const SizedBox(width: 8),
                          _buildDateFilterButton(context),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildBalanceCards(provider),
                  const SizedBox(height: 24),
                  Consumer<TransactionProvider>(
                    builder: (context, provider, _) {
                      final transactions = provider.transactions;
                      final lastTransactions = transactions.length > 5
                          ? transactions.sublist(transactions.length - 5).reversed.toList()
                          : transactions.reversed.toList();
                      if (lastTransactions.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: AppTheme.cardDecoration,
                          child: const Text(
                            'Belum ada transaksi',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        );
                      }
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: AppTheme.cardDecoration,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Last Transactions',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            ...lastTransactions.map((tx) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: _getTransactionColor(tx.type).withOpacity(0.2),
                                    child: Icon(
                                      _getTransactionIcon(tx.type),
                                      color: _getTransactionColor(tx.type),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tx.category,
                                          style: const TextStyle(fontWeight: FontWeight.w500),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (tx.note != null && tx.note!.isNotEmpty)
                                          Text(
                                            tx.note!,
                                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        Text(
                                          DateFormat('dd MMM yyyy').format(tx.date),
                                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${tx.type == 'income' || tx.type == 'debt' ? '+' : '-'}Rp${NumberFormat('#,###').format(tx.amount)}',
                                    style: TextStyle(
                                      color: _getTransactionColor(tx.type),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildStatisticsChart(provider),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBalanceCards(TransactionProvider provider) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildCard(
                'ATM Balance',
                currencyFormat.format(provider.totalAtm),
                Icons.credit_card,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCard(
                'Cash Balance',
                currencyFormat.format(provider.totalCash),
                Icons.payments,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildCard(
                'Active Debts',
                currencyFormat.format(provider.totalActiveDebts),
                Icons.warning_amber,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCard(
                'Total Expenses',
                currencyFormat.format(provider.totalExpense),
                Icons.money_off,
                Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCard(String title, String amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
            amount,
            style: const TextStyle(
                fontSize: 15,
              fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsChart(TransactionProvider provider) {
    return Consumer<TransactionProvider>(
      builder: (context, chartProvider, child) {
        final values = [
          provider.totalAtm,
          provider.totalCash,
          provider.totalActiveDebts,
          provider.totalExpense
        ];
        final total = values.fold(0.0, (sum, value) => sum + value.abs());
        
        String getPercentage(double value) {
          if (total == 0) return '0%';
          return '${((value.abs() / total) * 100).toStringAsFixed(1)}%';
        }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
                    'Financial Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
                  ),
                  Consumer<TransactionProvider>(
                    builder: (context, _, __) => _buildDateFilterButton(context),
                  ),
                ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: [
                      PieChartSectionData(
                        color: Colors.blue,
                        value: provider.totalAtm.abs(),
                        title: '${getPercentage(provider.totalAtm)}\nATM',
                        radius: 100,
                        titleStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        titlePositionPercentageOffset: 0.6,
                      ),
                      PieChartSectionData(
                        color: Colors.green,
                        value: provider.totalCash.abs(),
                        title: '${getPercentage(provider.totalCash)}\nCash',
                        radius: 100,
                        titleStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        titlePositionPercentageOffset: 0.6,
                      ),
                      PieChartSectionData(
                        color: Colors.orange,
                        value: provider.totalActiveDebts.abs(),
                        title: '${getPercentage(provider.totalActiveDebts)}\nDebt',
                        radius: 100,
                        titleStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        titlePositionPercentageOffset: 0.6,
                      ),
                      PieChartSectionData(
                        color: Colors.red,
                        value: provider.totalExpense.abs(),
                        title: '${getPercentage(provider.totalExpense)}\nExpense',
                        radius: 100,
                        titleStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        titlePositionPercentageOffset: 0.6,
                      ),
                    ],
              ),
            ),
          ),
          const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                    _buildLegendItem('ATM Balance', Colors.blue, provider.totalAtm),
                    const SizedBox(width: 24),
                    _buildLegendItem('Cash Balance', Colors.green, provider.totalCash),
                    const SizedBox(width: 24),
                    _buildLegendItem('Active Debts', Colors.orange, provider.totalActiveDebts),
              const SizedBox(width: 24),
                    _buildLegendItem('Total Expenses', Colors.red, provider.totalExpense),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(String label, Color color, double amount) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        Text(label),
            Text(
              NumberFormat.currency(
                locale: 'id_ID',
                symbol: 'Rp',
                decimalDigits: 0,
              ).format(amount),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateFilterButton(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        return PopupMenuButton<String>(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.filter_list, size: 20),
                const SizedBox(width: 4),
                if (provider.startDate != null && provider.endDate != null)
                  Text(
                    _getFilterText(provider.startDate!, provider.endDate!),
                    style: const TextStyle(fontSize: 12),
                  ),
              ],
            ),
          ),
          onSelected: (String value) async {
            if (value == 'custom') {
              final now = DateTime.now();
              final initialStart = provider.startDate ?? now;
              final initialEnd = provider.endDate != null && provider.endDate!.isAfter(now)
                  ? now
                  : (provider.endDate ?? now);
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: now,
                initialDateRange: DateTimeRange(
                  start: initialStart.isAfter(now) ? now : initialStart,
                  end: initialEnd,
                ),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      appBarTheme: const AppBarTheme(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                provider.setDateFilter(picked.start, picked.end);
              }
            } else {
              provider.filterByTimePeriod(value);
            }
          },
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
      );
      },
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
      return '';
    }

    if (startDate == DateTime(now.year, 1, 1) &&
        endDate == DateTime(now.year, 12, 31)) {
      return 'This Year';
    }

    return '${start.day}/${start.month} - ${end.day}/${end.month}';
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
} 