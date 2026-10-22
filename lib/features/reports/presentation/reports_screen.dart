import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير المالية والأرباح'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildReportTile(context, 'تقرير المبيعات اليومية', 'إجمالي الفواتير والمقادير المسددة', Icons.receipt, Colors.green),
            _buildReportTile(context, 'تقرير أرباح المنتجات', 'مقارنة سعر التكلفة بسعر البيع', Icons.trending_up, Colors.blue),
            _buildReportTile(context, 'كشف حسابات العملاء (الديون)', 'تفاصيل المبالغ المتبقية على الزبائن', Icons.people, Colors.orange),
            _buildReportTile(context, 'حركة الصندوق النقدية', 'تقرير حركة القبض والصرف اليومي', Icons.account_balance_wallet, Colors.purple),
            _buildReportTile(context, 'جرد المخزون والكميات', 'حساب قيمة المخزون الحالي الإجمالية', Icons.inventory, Colors.teal),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTile(BuildContext context, String title, String subtitle, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.15), child: Icon(icon, color: color)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('جاري تحميل $title...')));
        },
      ),
    );
  }
}