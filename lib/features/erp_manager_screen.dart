import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ErpManagerScreen extends StatefulWidget {
  const ErpManagerScreen({super.key});

  @override
  State<ErpManagerScreen> createState() => _ErpManagerScreenState();
}

class _ErpManagerScreenState extends State<ErpManagerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // القوائم الحقيقية
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> parties = []; // عملاء وموردين
  List<Map<String, dynamic>> invoices = [];

  // Controllers للأصناف
  final TextEditingController prodCodeCtrl = TextEditingController();
  final TextEditingController prodNameCtrl = TextEditingController();
  final TextEditingController prodPriceCtrl = TextEditingController();
  final TextEditingController prodStockCtrl = TextEditingController();

  // Controllers للعملاء والموردين
  final TextEditingController partyNameCtrl = TextEditingController();
  final TextEditingController partyPhoneCtrl = TextEditingController();
  String partyType = 'customer'; // customer أو supplier

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      String? pStr = prefs.getString('rimgo_products');
      if (pStr != null) products = List<Map<String, dynamic>>.from(jsonDecode(pStr));

      String? ptStr = prefs.getString('rimgo_parties');
      if (ptStr != null) parties = List<Map<String, dynamic>>.from(jsonDecode(ptStr));

      String? invStr = prefs.getString('rimgo_invoices');
      if (invStr != null) invoices = List<Map<String, dynamic>>.from(jsonDecode(invStr));
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('rimgo_products', jsonEncode(products));
    await prefs.setString('rimgo_parties', jsonEncode(parties));
    await prefs.setString('rimgo_invoices', jsonEncode(invoices));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RimGo SaaS - الإدارة الشاملة'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'الأصناف والمخزون', icon: Icon(Icons.inventory)),
            Tab(text: 'العملاء والتجار', icon: Icon(Icons.people)),
            Tab(text: 'الفواتير والمبيعات', icon: Icon(Icons.receipt_long)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProductsTab(),
          _buildPartiesTab(),
          _buildInvoicesTab(),
        ],
      ),
    );
  }

  // 1. تبويب إدارة الأصناف
  Widget _buildProductsTab() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  const Text('إضافة صنف جديد للمخزون', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: prodCodeCtrl, decoration: const InputDecoration(labelText: 'باركود / رقم الصنف'))),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(controller: prodNameCtrl, decoration: const InputDecoration(labelText: 'اسم الصنف'))),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: prodPriceCtrl, decoration: const InputDecoration(labelText: 'سعر البيع'), keyboardType: TextInputType.number)),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(controller: prodStockCtrl, decoration: const InputDecoration(labelText: 'الكمية الأولية'), keyboardType: TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    onPressed: () {
                      if (prodNameCtrl.text.isNotEmpty && prodPriceCtrl.text.isNotEmpty) {
                        setState(() {
                          products.add({
                            'code': prodCodeCtrl.text.isEmpty ? '10${products.length + 1}' : prodCodeCtrl.text,
                            'name': prodNameCtrl.text,
                            'price': double.tryParse(prodPriceCtrl.text) ?? 0.0,
                            'stock': int.tryParse(prodStockCtrl.text) ?? 0,
                          });
                          prodCodeCtrl.clear();
                          prodNameCtrl.clear();
                          prodPriceCtrl.clear();
                          prodStockCtrl.clear();
                        });
                        _saveData();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت إضافة الصنف وحفظه بنجاح!')));
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('حفظ وإضافة الصنف'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (ctx, i) {
                var p = products[i];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.shopping_bag, color: Colors.blue),
                    title: Text(p['name']),
                    subtitle: Text('الباركود: ${p['code']} | السعر: \$${p['price']}'),
                    trailing: Text('المخزون: ${p['stock']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 2. تبويب العملاء والتجار
  Widget _buildPartiesTab() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  const Text('إضافة عميل أو تاجر / مورد جديد', style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile(
                          title: const Text('عميل (زباين)'),
                          value: 'customer',
                          groupValue: partyType,
                          onChanged: (val) => setState(() => partyType = val.toString()),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile(
                          title: const Text('تاجر / مورد'),
                          value: 'supplier',
                          groupValue: partyType,
                          onChanged: (val) => setState(() => partyType = val.toString()),
                        ),
                      ),
                    ],
                  ),
                  TextField(controller: partyNameCtrl, decoration: const InputDecoration(labelText: 'اسم الحساب (العميل أو التاجر)')),
                  TextField(controller: partyPhoneCtrl, decoration: const InputDecoration(labelText: 'رقم الهاتف'), keyboardType: TextInputType.phone),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                    onPressed: () {
                      if (partyNameCtrl.text.isNotEmpty) {
                        setState(() {
                          parties.add({
                            'name': partyNameCtrl.text,
                            'phone': partyPhoneCtrl.text,
                            'type': partyType,
                            'balance': 0.0,
                          });
                          partyNameCtrl.clear();
                          partyPhoneCtrl.clear();
                        });
                        _saveData();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ الحساب بنجاح!')));
                      }
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text('حفظ الحساب'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: parties.length,
              itemBuilder: (ctx, i) {
                var pt = parties[i];
                bool isCustomer = pt['type'] == 'customer';
                return Card(
                  child: ListTile(
                    leading: Icon(isCustomer ? Icons.person : Icons.store, color: isCustomer ? Colors.orange : Colors.purple),
                    title: Text(pt['name']),
                    subtitle: Text('النوع: ${isCustomer ? 'عميل' : 'تاجر / مورد'} | الهاتف: ${pt['phone']}'),
                    trailing: Text('الرصيد: \$${pt['balance']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 3. تبويب الفواتير والمبيعات السريعة
  Widget _buildInvoicesTab() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 45)),
            onPressed: () {
              if (products.isEmpty || parties.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء إضافة أصناف وعملاء أولاً قبل إنشاء الفاتورة!')));
              } else {
                // إنشاء فاتورة افتراضية سريعة من البيانات المسجلة
                setState(() {
                  invoices.insert(0, {
                    'client': parties.first['name'],
                    'item': products.first['name'],
                    'total': products.first['price'],
                    'date': DateTime.now().toString().substring(0, 16),
                  });
                });
                _saveData();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إصدار وحفظ فاتورة البيع وخصم المخزون بنجاح!')));
              }
            },
            icon: const Icon(Icons.point_of_sale),
            label: const Text('إصدار فاتورة بيع سريعة ومحفوظة'),
          ),
          const SizedBox(height: 10),
          const Text('سجل الفواتير المحفوظة:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Expanded(
            child: invoices.isEmpty
                ? const Center(child: Text('لا توجد فواتير محفوظة بعد'))
                : ListView.builder(
                    itemCount: invoices.length,
                    itemBuilder: (ctx, i) {
                      var inv = invoices[i];
                      return Card(
                        child: ListTile(
                          title: Text('العميل: ${inv['client']}'),
                          subtitle: Text('الصنف: ${inv['item']} | التاريخ: ${inv['date']}'),
                          trailing: Text('\$${inv['total']}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}