import 'package:flutter/material.dart';
import '../../../core/services/database_service.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<Map<String, dynamic>> products = [];
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController codeCtrl = TextEditingController();
  final TextEditingController priceCtrl = TextEditingController();
  final TextEditingController stockCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    var pList = await DatabaseService.getProducts();
    setState(() {
      products = pList;
    });
  }

  Future<void> _saveProducts() async {
    await DatabaseService.saveProducts(products);
  }

  void _addProduct() {
    if (nameCtrl.text.isEmpty || codeCtrl.text.isEmpty || priceCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال اسم الصنف والباركود والسعر!'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      products.add({
        'name': nameCtrl.text,
        'code': codeCtrl.text,
        'price': double.tryParse(priceCtrl.text) ?? 0.0,
        'stock': int.tryParse(stockCtrl.text) ?? 10,
      });
      nameCtrl.clear();
      codeCtrl.clear();
      priceCtrl.clear();
      stockCtrl.clear();
    });
    _saveProducts();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تمت إضافة المنتج بنجاح للمخزون!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المنتجات والمخزون'),
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
                    const Text('إضافة صنف جديد للمخزون', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم الصنف', border: OutlineInputBorder())),
                    const SizedBox(height: 8),
                    TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'باركود الصنف (الرقم)', border: OutlineInputBorder())),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'سعر البيع (\$)', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: stockCtrl, decoration: const InputDecoration(labelText: 'الكمية الافتتاحية', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _addProduct,
                        icon: const Icon(Icons.add),
                        label: const Text('حفظ الصنف الجديد'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerRight,
              child: Text('قائمة أصناف المخزون الحالية:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: products.isEmpty
                  ? const Center(child: Text('لا توجد أصناف مسجلة في المخزون'))
                  : ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (ctx, i) {
                        var p = products[i];
                        return Card(
                          child: ListTile(
                            leading: const CircleAvatar(backgroundColor: Colors.brown, child: Icon(Icons.inventory, color: Colors.white)),
                            title: Text(p['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('باركود: ${p['code']} | السعر: \$${p['price']}'),
                            trailing: Text('المخزون: ${p['stock']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
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