import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IncomingChecksScreen extends StatefulWidget {
  const IncomingChecksScreen({super.key});

  @override
  State<IncomingChecksScreen> createState() => _IncomingChecksScreenState();
}

class _IncomingChecksScreenState extends State<IncomingChecksScreen> {
  List<Map<String, dynamic>> checks = [];
  final TextEditingController clientCtrl = TextEditingController();
  final TextEditingController checkNumberCtrl = TextEditingController();
  final TextEditingController bankNameCtrl = TextEditingController();
  final TextEditingController amountCtrl = TextEditingController();
  final TextEditingController dueDateCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadChecks();
  }

  Future<void> _loadChecks() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('rimgo_incoming_checks');
    if (data != null) {
      setState(() {
        checks = List<Map<String, dynamic>>.from(jsonDecode(data));
      });
    } else {
      setState(() {
        checks = [
          {'client': 'شركة الأمل', 'number': '100234', 'bank': 'البنك العربي', 'amount': 1500.0, 'dueDate': '2026-11-15', 'status': 'تحت التحصيل'},
        ];
      });
    }
  }

  Future<void> _saveChecks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('rimgo_incoming_checks', jsonEncode(checks));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الشيكات الواردة (من الزبائن)'),
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
                    const Text('تسجيل شيك وارد جديد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 8),
                    TextField(controller: clientCtrl, decoration: const InputDecoration(labelText: 'اسم الزبون (المسلم للشيك)', border: OutlineInputBorder())),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: checkNumberCtrl, decoration: const InputDecoration(labelText: 'رقم الشيك', border: OutlineInputBorder()))),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: bankNameCtrl, decoration: const InputDecoration(labelText: 'اسم البنك', border: OutlineInputBorder()))),
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
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
                        onPressed: () {
                          if (clientCtrl.text.isNotEmpty && amountCtrl.text.isNotEmpty) {
                            setState(() {
                              checks.insert(0, {
                                'client': clientCtrl.text,
                                'number': checkNumberCtrl.text,
                                'bank': bankNameCtrl.text,
                                'amount': double.tryParse(amountCtrl.text) ?? 0.0,
                                'dueDate': dueDateCtrl.text,
                                'status': 'تحت التحصيل',
                              });
                              clientCtrl.clear();
                              checkNumberCtrl.clear();
                              bankNameCtrl.clear();
                              amountCtrl.clear();
                              dueDateCtrl.clear();
                            });
                            _saveChecks();
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ الشيك الوارد بنجاح!')));
                          }
                        },
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('حفظ الشيك الوارد'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerRight,
              child: Text('قائمة الشيكات الواردة:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: checks.isEmpty
                  ? const Center(child: Text('لا توجد شيكات واردة مسجلة'))
                  : ListView.builder(
                      itemCount: checks.length,
                      itemBuilder: (ctx, i) {
                        var chk = checks[i];
                        return Card(
                          child: ListTile(
                            leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.arrow_downward, color: Colors.white)),
                            title: Text('الزبون: ${chk['client']} - \$${chk['amount']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('رقم الشيك: ${chk['number']} | البنك: ${chk['bank']}\nتاريخ الاستحقاق: ${chk['dueDate']}'),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(6)),
                              child: Text(chk['status'], style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold, fontSize: 12)),
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
