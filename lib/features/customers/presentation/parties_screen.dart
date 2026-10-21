import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PartiesScreen extends StatefulWidget {
  const PartiesScreen({super.key});

  @override
  State<PartiesScreen> createState() => _PartiesScreenState();
}

class _PartiesScreenState extends State<PartiesScreen> {
  List<Map<String, dynamic>> parties = [];
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  String partyType = 'customer'; // customer أو supplier

  @override
  void initState() {
    super.initState();
    _loadParties();
  }

  Future<void> _loadParties() async {
    final prefs = await SharedPreferences.getInstance();
    String? ptStr = prefs.getString('rimgo_parties');
    if (ptStr != null) {
      setState(() {
        parties = List<Map<String, dynamic>>.from(jsonDecode(ptStr));
      });
    } else {
      setState(() {
        parties = [
          {'name': 'زبون نقدي عام', 'phone': '000', 'type': 'customer', 'balance': 0.0},
          {'name': 'شركة الأمل للتجارة', 'phone': '0599000111', 'type': 'customer', 'balance': 150.0},
          {'name': 'مورد القدس للتوريدات', 'phone': '0569000222', 'type': 'supplier', 'balance': -500.0},
        ];
      });
    }
  }

  Future<void> _saveParties() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('rimgo_parties', jsonEncode(parties));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة العملاء والموردين'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    const Text('إضافة عميل أو مورد جديد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile(
                            title: const Text('عميل'),
                            value: 'customer',
                            groupValue: partyType,
                            onChanged: (v) => setState(() => partyType = v.toString()),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile(
                            title: const Text('مورد / تاجر'),
                            value: 'supplier',
                            groupValue: partyType,
                            onChanged: (v) => setState(() => partyType = v.toString()),
                          ),
                        ),
                      ],
                    ),
                    TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'الاسم الحساب', border: OutlineInputBorder())),
                    const SizedBox(height: 8),
                    TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'رقم الهاتف', border: OutlineInputBorder()), keyboardType: TextInputType.phone),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800, foregroundColor: Colors.white),
                        onPressed: () {
                          if (nameCtrl.text.isNotEmpty) {
                            setState(() {
                              parties.add({
                                'name': nameCtrl.text,
                                'phone': phoneCtrl.text,
                                'type': partyType,
                                'balance': 0.0,
                              });
                              nameCtrl.clear();
                              phoneCtrl.clear();
                            });
                            _saveParties();
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إضافة الحساب بنجاح!')));
                          }
                        },
                        icon: const Icon(Icons.person_add),
                        label: const Text('حفظ الحساب'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: parties.length,
                itemBuilder: (ctx, i) {
                  var pt = parties[i];
                  bool isCustomer = pt['type'] == 'customer';
                  double bal = (pt['balance'] as num).toDouble();
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isCustomer ? Colors.orange.shade100 : Colors.purple.shade100,
                        child: Icon(isCustomer ? Icons.person : Icons.store, color: isCustomer ? Colors.orange : Colors.purple),
                      ),
                      title: Text(pt['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('هاتف: ${pt['phone']} | ${isCustomer ? "عميل" : "مورد/تاجر"}'),
                      trailing: Text(
                        'الرصيد: \$${bal.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: bal > 0 ? Colors.red : (bal < 0 ? Colors.green : Colors.black),
                          fontWeight: FontWeight.bold,
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
