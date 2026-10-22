import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/database_service.dart';

class PartyLedgerScreen extends StatefulWidget {
  final Map<String, dynamic> party;
  const PartyLedgerScreen({super.key, required this.party});

  @override
  State<PartyLedgerScreen> createState() => _PartyLedgerScreenState();
}

class _PartyLedgerScreenState extends State<PartyLedgerScreen> {
  late TextEditingController nameCtrl;
  late TextEditingController phoneCtrl;
  late double balance;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.party['name']);
    phoneCtrl = TextEditingController(text: widget.party['phone']);
    balance = (widget.party['balance'] as num).toDouble();
  }

  Future<void> _updatePartyDetails() async {
    List<Map<String, dynamic>> parties = await DatabaseService.getParties();
    int idx = parties.indexWhere((p) => p['name'] == widget.party['name']);
    if (idx != -1) {
      parties[idx]['name'] = nameCtrl.text;
      parties[idx]['phone'] = phoneCtrl.text;
      await DatabaseService.saveParties(parties);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث بيانات الحساب بنجاح!')),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isCustomer = widget.party['type'] == 'customer';

    return Scaffold(
      appBar: AppBar(
        title: Text('كشف حساب: ${widget.party['name']}'),
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
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  children: [
                    const Text('تعديل بيانات الحساب وتفاصيل الاتصال', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم الحساب', border: OutlineInputBorder())),
                    const SizedBox(height: 10),
                    TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'رقم الهاتف', border: OutlineInputBorder()), keyboardType: TextInputType.phone),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('الرصيد الحالي: \$${balance.toStringAsFixed(2)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: balance > 0 ? Colors.red : Colors.green)),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800, foregroundColor: Colors.white),
                          onPressed: _updatePartyDetails,
                          icon: const Icon(Icons.save),
                          label: const Text('حفظ التعديلات'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerRight,
              child: Text('سجل حركات الحساب والفواتير السابقة:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                child: Center(
                  child: Text(
                    isCustomer ? 'لا توجد فواتير مسجلة مباشرة لهذا العميل' : 'لا توجد حركات شراء مسجلة لهذا المورد',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}