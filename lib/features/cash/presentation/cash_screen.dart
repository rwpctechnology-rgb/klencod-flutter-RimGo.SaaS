import 'package:flutter/material.dart';

class CashScreen extends StatefulWidget {
  const CashScreen({super.key});

  @override
  State<CashScreen> createState() => _CashScreenState();
}

class _CashScreenState extends State<CashScreen> {
  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController amountCtrl = TextEditingController();
  
  String transactionType = 'receipt'; // 'receipt' قبض أو 'payment' صرف
  double cashBoxBalance = 15450.00; // رصيد الصندوق الافتتاحي

  final List<Map<String, dynamic>> cashTransactions = [
    {'title': 'سند قبض من عميل (شركة الأمل)', 'amount': 1200.0, 'type': 'receipt', 'date': '2026-10-20'},
    {'title': 'صرف فاتورة كهرباء المحل', 'amount': 350.0, 'type': 'payment', 'date': '2026-10-19'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الصندوق والحركات المالية'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بطاقة رصيد الصندوق الحالي
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade800, Colors.indigo.shade600],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'رصيد الصندوق الحالي',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${cashBoxBalance.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // إضافة حركة نقدية جديدة
            const Text('تسجيل حركة نقدية جديدة (قبض / صرف)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('سند قبض'),
                    value: 'receipt',
                    groupValue: transactionType,
                    onChanged: (val) => setState(() => transactionType = val!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('سند صرف'),
                    value: 'payment',
                    groupValue: transactionType,
                    onChanged: (val) => setState(() => transactionType = val!),
                  ),
                ),
              ],
            ),

            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'بيان الحركة (السبب أو الجهة)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: amountCtrl,
              decoration: const InputDecoration(labelText: 'المبلغ (\$)', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  double amount = double.tryParse(amountCtrl.text) ?? 0.0;
                  if (titleCtrl.text.isNotEmpty && amount > 0) {
                    setState(() {
                      if (transactionType == 'receipt') {
                        cashBoxBalance += amount;
                      } else {
                        cashBoxBalance -= amount;
                      }

                      cashTransactions.insert(0, {
                        'title': titleCtrl.text,
                        'amount': amount,
                        'type': transactionType,
                        'date': DateTime.now().toString().substring(0, 10),
                      });

                      titleCtrl.clear();
                      amountCtrl.clear();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم تسجيل الحركة النقدية وتحديث الصندوق بنجاح!')),
                    );
                  }
                },
                icon: const Icon(Icons.save),
                label: const Text('حفظ وتسجيل الحركة المالية'),
              ),
            ),

            const Divider(height: 30),
            const Text('سجل الحركات النقدية الأخيرة:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),

            // قائمة الحركات الأخيرة
            Expanded(
              child: ListView.builder(
                itemCount: cashTransactions.length,
                itemBuilder: (ctx, i) {
                  var tx = cashTransactions[i];
                  bool isReceipt = tx['type'] == 'receipt';
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        isReceipt ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isReceipt ? Colors.green : Colors.red,
                      ),
                      title: Text(tx['title']),
                      subtitle: Text('التاريخ: ${tx['date']}'),
                      trailing: Text(
                        '${isReceipt ? '+' : '-'}\$${tx['amount']}',
                        style: TextStyle(
                          color: isReceipt ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
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
