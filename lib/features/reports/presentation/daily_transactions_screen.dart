import 'package:flutter/material.dart';
import '../../../core/services/database_service.dart';

class DailyTransactionsScreen extends StatefulWidget {
  const DailyTransactionsScreen({super.key});

  @override
  State<DailyTransactionsScreen> createState() => _DailyTransactionsScreenState();
}

class _DailyTransactionsScreenState extends State<DailyTransactionsScreen> {
  List<Map<String, dynamic>> invoices = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    var invs = await DatabaseService.getInvoices();
    setState(() {
      invoices = invs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل الحركات اليومية والفواتير'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            Card(
              color: Colors.blue.shade50,
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'هنا يتم تسجيل كافة فواتير البيع والحركات المالية المسجلة في النظام تلقائياً.',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: invoices.isEmpty
                  ? const Center(child: Text('لا توجد حركات مسجلة حتى الآن'))
                  : ListView.builder(
                      itemCount: invoices.length,
                      itemBuilder: (ctx, i) {
                        var inv = invoices[i];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Icon(Icons.receipt, color: Colors.white),
                            ),
                            title: Text('العميل: ${inv['client']} | المجموع: \$${inv['total']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('طريقة الدفع: ${inv['paymentType']}\nالتاريخ: ${inv['date']}'),
                            trailing: Text('${inv['itemsCount']} أصناف', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
