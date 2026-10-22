import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Map<String, dynamic>> orders = [];
  final TextEditingController clientCtrl = TextEditingController();
  final TextEditingController detailsCtrl = TextEditingController();
  String orderType = 'sales_order'; // طلبية بيع أو purchase_order طلبية شراء

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('rimgo_orders');
    if (data != null) {
      setState(() {
        orders = List<Map<String, dynamic>>.from(jsonDecode(data));
      });
    } else {
      setState(() {
        orders = [
          {'client': 'معرض النور', 'details': 'طلب 10 هواتف ذكية', 'type': 'sales_order', 'status': 'معلقة', 'date': '2026-10-22'},
          {'client': 'مورد الشاشة الكبرى', 'details': 'طلب شاشات عرض POS', 'type': 'purchase_order', 'status': 'قيد التنفيذ', 'date': '2026-10-21'},
        ];
      });
    }
  }

  Future<void> _saveOrders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('rimgo_orders', jsonEncode(orders));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الطلبيات'),
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
                    const Text('تسجيل طلبية جديدة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('طلبية بيع (من زبون)'),
                            value: 'sales_order',
                            groupValue: orderType,
                            onChanged: (v) => setState(() => orderType = v!),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('طلبية شراء (لمورد)'),
                            value: 'purchase_order',
                            groupValue: orderType,
                            onChanged: (v) => setState(() => orderType = v!),
                          ),
                        ),
                      ],
                    ),
                    TextField(
                      controller: clientCtrl,
                      decoration: const InputDecoration(labelText: 'اسم العميل أو المورد', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: detailsCtrl,
                      decoration: const InputDecoration(labelText: 'تفاصيل الطلبية والأصناف', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                        onPressed: () {
                          if (clientCtrl.text.isNotEmpty && detailsCtrl.text.isNotEmpty) {
                            setState(() {
                              orders.insert(0, {
                                'client': clientCtrl.text,
                                'details': detailsCtrl.text,
                                'type': orderType,
                                'status': 'معلقة',
                                'date': DateTime.now().toString().substring(0, 10),
                              });
                              clientCtrl.clear();
                              detailsCtrl.clear();
                            });
                            _saveOrders();
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت إضافة الطلبية بنجاح!')));
                          }
                        },
                        icon: const Icon(Icons.note_add),
                        label: const Text('حفظ الطلبية'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerRight,
              child: Text('قائمة الطلبيات المسجلة:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: orders.isEmpty
                  ? const Center(child: Text('لا توجد طلبيات مسجلة حالياً'))
                  : ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (ctx, i) {
                        var o = orders[i];
                        bool isSales = o['type'] == 'sales_order';
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isSales ? Colors.blue.shade100 : Colors.teal.shade100,
                              child: Icon(isSales ? Icons.shopping_cart : Icons.local_shipping, color: isSales ? Colors.blue : Colors.teal),
                            ),
                            title: Text('${o['client']} (${isSales ? "طلبية بيع" : "طلبية شراء"})', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('التفاصيل: ${o['details']}\nالتاريخ: ${o['date']}'),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(o['status'], style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
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
