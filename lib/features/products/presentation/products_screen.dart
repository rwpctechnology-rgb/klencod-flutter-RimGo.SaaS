import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<Map<String, dynamic>> products = [];
  final TextEditingController codeCtrl = TextEditingController();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController priceCtrl = TextEditingController();
  final TextEditingController stockCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    String? pStr = prefs.getString('rimgo_products');
    if (pStr != null) {
      setState(() {
        products = List<Map<String, dynamic>>.from(jsonDecode(pStr));
      });
    } else {
      setState(() {
        products = [
          {'code': '101', 'name': 'حقيبة لابتوب', 'price': 35.0, 'stock': 10},
          {'code': '102', 'name': 'شاحن سريع 65W', 'price': 15.0, 'stock': 25},
          {'code': '103', 'name': 'ماوس لاسلكي', 'price': 8.0, 'stock': 40},
        ];
      });
    }
  }

  Future<void> _saveProducts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('rimgo_products', jsonEncode(products));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الأصناف والمخزون'),
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
                    const Text('إضافة صنف جديد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'الباركوُد', border: OutlineInputBorder()))),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم الصنف', border: OutlineInputBorder()))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'سعر البيع', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: stockCtrl, decoration: const InputDecoration(labelText: 'الكمية بالمخزن', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
                        onPressed: () {
                          if (nameCtrl.text.isNotEmpty && priceCtrl.text.isNotEmpty) {
                            setState(() {
                              products.add({
                                'code': codeCtrl.text.isEmpty ? '10${products.length + 1}' : codeCtrl.text,
                                'name': nameCtrl.text,
                                'price': double.tryParse(priceCtrl.text) ?? 0.0,
                                'stock': int.tryParse(stockCtrl.text) ?? 0,
                              });
                              codeCtrl.clear();
                              nameCtrl.clear();
                              priceCtrl.clear();
                              stockCtrl.clear();
                            });
                            _saveProducts();
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت إضافة الصنف بنجاح!')));
                          }
                        },
                        icon: const Icon(Icons.add_box),
                        label: const Text('حفظ الصنف'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (ctx, i) {
                  var p = products[i];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.inventory_2, color: Colors.blue),
                      title: Text(p['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('باركود: ${p['code']} | السعر: \$${p['price']}'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (p['stock'] as int) < 5 ? Colors.red.shade100 : Colors.green.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'المخزون: ${p['stock']}',
                          style: TextStyle(
                            color: (p['stock'] as int) < 5 ? Colors.red : Colors.green.shade900,
                            fontWeight: FontWeight.bold,
                          ),
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
