
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/report_provider.dart';

class MonthlyReportScreen extends StatefulWidget {
  const MonthlyReportScreen({super.key});

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReportProvider>(context, listen: false).loadReport();
    });
  }

  String _formatCurrency(dynamic amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(double.parse(amount.toString()));
  }

  Future<void> _selectMonth(BuildContext context) async {
    final reportProvider = Provider.of<ReportProvider>(context, listen: false);
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: reportProvider.selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDatePickerMode: DatePickerMode.year,
    );
    
    if (picked != null && picked != reportProvider.selectedDate) {
      reportProvider.setDate(picked);
      reportProvider.loadReport();
    }
  }

  List<PieChartSectionData> _buildExpenseSections(Map<String, dynamic> report) {
    final expenseByCategory = report['expense_by_category'];
    if (expenseByCategory == null || expenseByCategory is! Map) return [];
    
    final categories = Map<String, dynamic>.from(expenseByCategory);
    if (categories.isEmpty) return [];

    final colors = [
      Colors.red,
      Colors.orange,
      Colors.amber,
      Colors.purple,
      Colors.pink,
      Colors.teal,
    ];

    int index = 0;
    return categories.entries.map((entry) {
      final color = colors[index % colors.length];
      index++;
      final value = double.parse(entry.value.toString());
      final total = categories.values.fold<double>(
        0,
        (sum, v) => sum + double.parse(v.toString()),
      );
      final percentage = (value / total * 100).toStringAsFixed(1);

      return PieChartSectionData(
        color: color,
        value: value,
        title: '$percentage%',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<Widget> _buildLegend(Map<String, dynamic> report) {
    final expenseByCategory = report['expense_by_category'];
    if (expenseByCategory == null || expenseByCategory is! Map) return [];
    
    final categories = Map<String, dynamic>.from(expenseByCategory);
    if (categories.isEmpty) return [];

    final colors = [
      Colors.red,
      Colors.orange,
      Colors.amber,
      Colors.purple,
      Colors.pink,
      Colors.teal,
    ];

    int index = 0;
    return categories.entries.map((entry) {
      final color = colors[index % colors.length];
      index++;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
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
            Expanded(
              child: Text(
                entry.key,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            Text(
              _formatCurrency(entry.value),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildCategoryList(Map<String, dynamic> categories, Color color) {
    return categories.entries.map((entry) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              entry.key,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              _formatCurrency(entry.value),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider = Provider.of<ReportProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Monthly Report'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _selectMonth(context),
            icon: const Icon(Icons.calendar_month_rounded),
          ),
        ],
      ),
      body: reportProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : reportProvider.report == null
              ? const Center(child: Text('No data available'))
              : RefreshIndicator(
                  onRefresh: () => reportProvider.loadReport(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Text(
                              DateFormat('MMMM yyyy').format(reportProvider.selectedDate),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Summary Cards
                        Row(
                          children: [
                            Expanded(
                              child: _buildSummaryCard(
                                'Income',
                                _formatCurrency(reportProvider.report!['income']),
                                Icons.arrow_downward_rounded,
                                Colors.green,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildSummaryCard(
                                'Expense',
                                _formatCurrency(reportProvider.report!['expense']),
                                Icons.arrow_upward_rounded,
                                Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildSummaryCard(
                          'Balance',
                          _formatCurrency(reportProvider.report!['balance']),
                          Icons.account_balance_wallet_rounded,
                          Theme.of(context).colorScheme.primary,
                          isLarge: true,
                        ),
                        const SizedBox(height: 32),

                        // Expense Chart
                        if (reportProvider.report!['expense_by_category'] != null &&
                            reportProvider.report!['expense_by_category'] is Map &&
                            (reportProvider.report!['expense_by_category'] as Map).isNotEmpty) ...[
                          Text(
                            'Expense by Category',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant
                                    .withOpacity(0.5),
                              ),
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 200,
                                  child: PieChart(
                                    PieChartData(
                                      sections: _buildExpenseSections(reportProvider.report!),
                                      centerSpaceRadius: 40,
                                      sectionsSpace: 2,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ..._buildLegend(reportProvider.report!),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],

                        // Income Categories
                        if (reportProvider.report!['income_by_category'] != null &&
                            reportProvider.report!['income_by_category'] is Map &&
                            (reportProvider.report!['income_by_category'] as Map).isNotEmpty) ...[
                          Text(
                            'Income Categories',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ..._buildCategoryList(
                            Map<String, dynamic>.from(reportProvider.report!['income_by_category']),
                            Colors.green,
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Expense Categories
                        if (reportProvider.report!['expense_by_category'] != null &&
                            reportProvider.report!['expense_by_category'] is Map &&
                            (reportProvider.report!['expense_by_category'] as Map).isNotEmpty) ...[
                          Text(
                            'Expense Categories',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ..._buildCategoryList(
                            Map<String, dynamic>.from(reportProvider.report!['expense_by_category']),
                            Colors.red,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String amount,
    IconData icon,
    Color color, {
    bool isLarge = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isLarge ? 24 : 20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            isLarge ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isLarge
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
          SizedBox(height: isLarge ? 12 : 8),
          Text(
            amount,
            style: TextStyle(
              fontSize: isLarge ? 28 : 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: isLarge ? TextAlign.center : TextAlign.start,
          ),
        ],
      ),
    );
  }
}