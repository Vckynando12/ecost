import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

class PdfGenerator {
  static Future<void> generateAndSavePdf({
    required List<Transaction> transactions,
    required double totalAtm,
    required double totalCash,
    required double totalActiveDebts,
    required double totalExpense,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final pdf = pw.Document();

    // Format currency
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    // Add content to the PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          _buildHeader(startDate, endDate),
          pw.SizedBox(height: 20),
          _buildSummary(
            totalAtm: totalAtm,
            totalCash: totalCash,
            totalActiveDebts: totalActiveDebts,
            totalExpense: totalExpense,
            currencyFormat: currencyFormat,
          ),
          pw.SizedBox(height: 20),
          _buildTransactionTable(transactions, currencyFormat),
        ],
      ),
    );

    // Get the application documents directory
    final dir = await getApplicationDocumentsDirectory();
    final String dateRange = '${DateFormat('dd-MM-yyyy').format(startDate)}_${DateFormat('dd-MM-yyyy').format(endDate)}';
    final String filePath = '${dir.path}/financial_report_$dateRange.pdf';

    // Save the PDF
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    // Open the PDF for preview
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static pw.Widget _buildHeader(DateTime startDate, DateTime endDate) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'E-cost Financial Report',
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          'Period: ${DateFormat('dd MMMM yyyy').format(startDate)} - ${DateFormat('dd MMMM yyyy').format(endDate)}',
          style: const pw.TextStyle(
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildSummary({
    required double totalAtm,
    required double totalCash,
    required double totalActiveDebts,
    required double totalExpense,
    required NumberFormat currencyFormat,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Financial Summary',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          _buildSummaryRow('ATM Balance', totalAtm, currencyFormat),
          _buildSummaryRow('Cash Balance', totalCash, currencyFormat),
          _buildSummaryRow('Active Debts', totalActiveDebts, currencyFormat),
          _buildSummaryRow('Total Expenses', totalExpense, currencyFormat),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryRow(String label, double amount, NumberFormat currencyFormat) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label),
          pw.Text(currencyFormat.format(amount)),
        ],
      ),
    );
  }

  static pw.Widget _buildTransactionTable(List<Transaction> transactions, NumberFormat currencyFormat) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(2),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _buildTableCell('Date', isHeader: true),
            _buildTableCell('Category', isHeader: true),
            _buildTableCell('Type', isHeader: true),
            _buildTableCell('Amount', isHeader: true),
          ],
        ),
        // Data rows
        ...transactions.map((transaction) => pw.TableRow(
          children: [
            _buildTableCell(DateFormat('dd/MM/yyyy').format(transaction.date)),
            _buildTableCell(transaction.category),
            _buildTableCell(transaction.type.toUpperCase()),
            _buildTableCell(currencyFormat.format(transaction.amount)),
          ],
        )).toList(),
      ],
    );
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : null,
        ),
      ),
    );
  }
} 