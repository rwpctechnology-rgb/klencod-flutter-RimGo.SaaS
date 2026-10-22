import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OutgoingChecksScreen extends StatefulWidget {
  const OutgoingChecksScreen({super.key});

  @override
  State<OutgoingChecksScreen> createState() => _OutgoingChecksScreenState();
}

class _OutgoingChecksScreenState extends State<OutgoingChecksScreen> {
  List<Map<String, dynamic>> outgoingChecks = [];
  final TextEditingController supplierCtrl = TextEditingController();
  final TextEditingController checkNumberCtrl = TextEditingController();
  final TextEditingController bankNameCtrl = TextEditingController();
  final TextEditingController amountCtrl = TextEditingController();
  final TextEditingController dueDateCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadOutgoingChecks();
  }

  Future<void> _loadOutgoingChecks() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('rimgo_outgoing_checks');
    if (data != null) {
      setState(() {
        outgoingChecks = List<Map<String, dynamic>>.from(jsonDecode(data));
      });
    } else {
      setState(() {
        outgoingChecks = [
          {'supplier': 'مورد القدس', 'number': '50012', 'bank': 'بنك فلسطين', 'amount': 2500.0, 'dueDate': '2026-12-01', 'status': 'معلق للدفع'},
        ];
      });
    }
  }

  Future<void> _saveOutgoingChecks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('rimgo_outgoing_checks', jsonEncode(outgoingChecks));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الشيكات الصادرة (للموردين)'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    const Text('تسجيل شيك صادر جديد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 8),
                    TextField(controller: supplierCtrl, decoration: const InputDecoration(labelText: 'اسم المورد المستفيد', border: OutlineInputBorder())),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: checkNumberCtrl, decoration: const InputDecoration(labelText: 'رقم الشيك', border: OutlineInputBorder()))),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: bankNameCtrl, decoration: const InputDecoration(labelText: 'اسم البنك المسحوب عليه', border: OutlineInputBorder()))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: amountCtrl, decoration: const InputDecoration(labelText: 'المبلغ (\$)', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: dueDateCtrl, decoration: const InputDecoration(labelText: 'تاريخ الاستحقاق (YYYY-MM-DD)', border: OutlineInputBorder()))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
                        onPressed: () {
                          if (supplierCtrl.text.isNotEmpty && amountCtrl.text.isNotEmpty) {
                            setState(() {
                              outgoingChecks.insert(0, {
                                'supplier': supplierCtrl.text,
                                'number': checkNumberCtrl.text,
                                'bank': bankNameCtrl.text,
                                'amount': double.tryParse(amountCtrl.text) ?? 0.0,
                                'dueDate': dueDateCtrl.text,
                                'status': 'معلق للدفع',
                              });
                              supplierCtrl.clear();
                              checkNumberCtrl.clear();
                              bankNameCtrl.clear();
                              amountCtrl.clear();
                              dueDateCtrl.clear();
                            });
                            _saveOutgoingChecks();
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ الشيك الصادر بنجاح!')));
                          }
                        },
                        icon: const Icon(Icons.outbox),
                        label: const Text('حفظ الشيك الصادر'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerRight,
              child: Text('قائمة الشيكات الصادرة للموردين:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: outgoingChecks.isEmpty
                  ? const Center(child: Text('لا توجد شيكات صادرة مسجلة'))
                  : ListView.builder(
                      itemCount: outgoingChecks.length,
                      itemBuilder: (ctx, i) {
                        var chk = outgoingChecks[i];
                        return Card(
                          child: ListTile(
                            leading: const CircleAvatar(backgroundColor: Colors.purple, child: Icon(Icons.arrow_upward, color: Colors.white)),
                            title: Text('المورد: ${chk['supplier']} - \$${chk['amount']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('رقم الشيك: ${chk['number']} | البنك: ${chk['bank']}\nتاريخ الاستحقاق: ${chk['dueDate']}'),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.purple.shade100, borderRadius: BorderRadius.circular(6)),
                              child: Text(chk['status'], style: TextStyle(color: Colors.purple.shade900, fontWeight: FontWeight.bold, fontSize: 12)),
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
