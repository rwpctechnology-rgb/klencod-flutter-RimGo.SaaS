import 'package:flutter/material.dart';
import '../../../core/services/database_service.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key});

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> parties = [];
  
  Map<String, dynamic>? selectedSupplier;
  Map<String, dynamic>? selectedProduct;

  final TextEditingController barcodeCtrl = TextEditingController();
  final TextEditingController qtyCtrl = TextEditingController(text: '1');
  final TextEditingController costCtrl = TextEditingController();

  final List<Map<String, dynamic>> purchaseItems = [];
  String paymentType = 'cash'; // 'cash' نقداً من الصندوق أو 'credit' أُجل على المورد

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    var pList = await DatabaseService.getProducts();
    var ptList = await DatabaseService.getParties();
    setState(() {
      products = pList;
      parties = ptList.where((p) => p['type'] == 'supplier' || p['type'] == 'customer').toList();
      if (parties.isNotEmpty) selectedSupplier = parties.first;
    });
  }

  void _addProductToPurchase() {
    String code = barcodeCtrl.text.trim();
    int qty = int.tryParse(qtyCtrl.text) ?? 1;
    double cost = double.tryParse(costCtrl.text) ?? 0.0;

    if (code.isEmpty || cost <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال الباركود وسعر الشراء الصحيح!'), backgroundColor: Colors.red),
      );
      return;
    }

    var prodMatch = products.firstWhere((p) => p['code'] == code, orElse: () => {});
    String prodName = prodMatch.isNotEmpty ? prodMatch['name'] : 'صنف جديد ($code)';

    setState(() {
      purchaseItems.add({
        'code': code,
        'name': prodName,
        'qty': qty,
        'cost': cost,
      });
      barcodeCtrl.clear();
      costCtrl.clear();
      qtyCtrl.text = '1';
      selectedProduct = null;
    });
  }

  Future<void> _savePurchaseInvoice() async {
    if (purchaseItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أضف أصناف لفاتورة الشراء أولاً!'), backgroundColor: Colors.orange),
      );
      return;
    }

    double totalCost = purchaseItems.fold(0, (sum, item) => sum + (item['qty'] * item['cost']));

    // 1. زيادة كميات المخزون للأصناف الواردة
    for (var item in purchaseItems) {
      int idx = products.indexWhere((p) => p['code'] == item['code']);
      if (idx != -1) {
        products[idx]['stock'] = (products[idx]['stock'] as int) + (item['qty'] as int);
        products[idx]['price'] = item['cost'] * 1.25; // تحديث سعر البيع تلقائياً بهامش 25% مثلاً
      } else {
        // إضافة صنف جديد كلياً للمخزون إذا لم يكن موجوداً
        products.add({
          'code': item['code'],
          'name': item['name'],
          'price': item['cost'] * 1.25,
          'stock': item['qty'],
        });
      }
    }
    await DatabaseService.saveProducts(products);

    // 2. تحديث رصيد المورد (إذا كان الشراء بالآجل يزيد الدين للمورد)
    if (paymentType == 'credit' && selectedSupplier != null) {
      int pIdx = parties.indexWhere((pt) => pt['name'] == selectedSupplier!['name']);
      if (pIdx != -1) {
        double currentBal = (parties[pIdx]['balance'] as num).toDouble();
        parties[pIdx]['balance'] = currentBal - totalCost; // رصيد سالب يعني مستحق للمورد
      }
      await DatabaseService.saveParties(parties);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم حفظ فاتورة الشراء وتحديث المخزون بنجاح بقيمة \$$totalCost!')),
    );

    setState(() {
      purchaseItems.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    double totalInvoice = purchaseItems.fold(0, (sum, item) => sum + (item['qty'] * item['cost']));

    return Scaffold(
      appBar: AppBar(
        title: const Text('فاتورة شراء بضاعة (الموردين)'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            // اختيار المورد وطريقة الدفع
            Card(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    DropdownButtonFormField<Map<String, dynamic>>(
                      value: selectedSupplier,
                      decoration: const InputDecoration(labelText: 'اختر المورد / التاجر', border: OutlineInputBorder()),
                      items: parties.map((p) {
                        return DropdownMenuItem(
                          value: p,
                          child: Text('${p['name']} (${p['type'] == 'supplier' ? "مورد" : "عميل"})'),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => selectedSupplier = val),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('نقداً (من الصندوق)'),
                            value: 'cash',
                            groupValue: paymentType,
                            onChanged: (val) => setState(() => paymentType = val!),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('بالآجل (على المورد)'),
                            value: 'credit',
                            groupValue: paymentType,
                            onChanged: (val) => setState(() => paymentType = val!),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // إدخال الصنف والشراء
            Card(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    DropdownButtonFormField<Map<String, dynamic>>(
                      value: selectedProduct,
                      decoration: const InputDecoration(labelText: 'اختر من أصناف المخزون', border: OutlineInputBorder()),
                      items: products.map((p) {
                        return DropdownMenuItem(
                          value: p,
                          child: Text('${p['name']} [باركود: ${p['code']}]'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            selectedProduct = val;
                            barcodeCtrl.text = val['code'];
                            costCtrl.text = val['price'].toString();
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: barcodeCtrl, decoration: const InputDecoration(labelText: 'الباركود', border: OutlineInputBorder()))),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: costCtrl, decoration: const InputDecoration(labelText: 'سعر الشراء الإفرادي', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: qtyCtrl, decoration: const InputDecoration(labelText: 'الكمية الواردة', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                          onPressed: _addProductToPurchase,
                          icon: const Icon(Icons.add),
                          label: const Text('إضافة للقائمة'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // قائمة الأصناف المضافة لفاتورة الشراء
            Expanded(
              child: Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                child: purchaseItems.isEmpty
                    ? const Center(child: Text('لم يتم إدراج أصناف لفاتورة الشراء بعد'))
                    : ListView.builder(
                        itemCount: purchaseItems.length,
                        itemBuilder: (ctx, i) {
                          var item = purchaseItems[i];
                          double total = item['qty'] * item['cost'];
                          return ListTile(
                            title: Text(item['name']),
                            subtitle: Text('الكمية: ${item['qty']} | سعر الشراء: \$${item['cost']}'),
                            trailing: Text('\$$total', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(height: 10),

            // الإجمالي وزر الحفظ
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
              child: Text(
                'إجمالي فاتورة الشراء: \$${totalInvoice.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white).wrap(
                ElevatedButton.icon(
                  onPressed: _savePurchaseInvoice,
                  icon: const Icon(Icons.save),
                  label: const Text('حفظ فاتورة الشراء وتحديث المخزون'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}