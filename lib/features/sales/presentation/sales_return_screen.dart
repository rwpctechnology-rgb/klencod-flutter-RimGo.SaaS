import 'package:flutter/material.dart';
import '../../../core/services/database_service.dart';

class SalesReturnScreen extends StatefulWidget {
  const SalesReturnScreen({super.key});

  @override
  State<SalesReturnScreen> createState() => _SalesReturnScreenState();
}

class _SalesReturnScreenState extends State<SalesReturnScreen> {
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> parties = [];
  
  Map<String, dynamic>? selectedCustomer;
  Map<String, dynamic>? selectedProduct;

  final TextEditingController barcodeCtrl = TextEditingController();
  final TextEditingController qtyCtrl = TextEditingController(text: '1');
  final TextEditingController priceCtrl = TextEditingController();

  final List<Map<String, dynamic>> returnItems = [];
  String refundType = 'deduct_from_balance'; // خصم من الدين أو 'cash' رد نقدي

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
      parties = ptList;
      if (parties.isNotEmpty) selectedCustomer = parties.first;
    });
  }

  void _addItemToReturn() {
    String code = barcodeCtrl.text.trim();
    int qty = int.tryParse(qtyCtrl.text) ?? 1;
    double price = double.tryParse(priceCtrl.text) ?? 0.0;

    if (code.isEmpty || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال الباركود وسعر المرتجع الصحيح!'), backgroundColor: Colors.red),
      );
      return;
    }

    var prodMatch = products.firstWhere((p) => p['code'] == code, orElse: () => {});
    String prodName = prodMatch.isNotEmpty ? prodMatch['name'] : 'صنف مرتجع ($code)';

    setState(() {
      returnItems.add({
        'code': code,
        'name': prodName,
        'qty': qty,
        'price': price,
      });
      barcodeCtrl.clear();
      priceCtrl.clear();
      qtyCtrl.text = '1';
      selectedProduct = null;
    });
  }

  Future<void> _saveSalesReturn() async {
    if (returnItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أضف أصناف لقائمة مردود البيع أولاً!'), backgroundColor: Colors.orange),
      );
      return;
    }

    double totalRefund = returnItems.fold(0, (sum, item) => sum + (item['qty'] * item['price']));

    // 1. إعادة الكميات المرتجعة إلى المخزون
    for (var item in returnItems) {
      int idx = products.indexWhere((p) => p['code'] == item['code']);
      if (idx != -1) {
        products[idx]['stock'] = (products[idx]['stock'] as int) + (item['qty'] as int);
      }
    }
    await DatabaseService.saveProducts(products);

    // 2. تحديث حساب العميل (تخفيض الدين عليه أو تسجيل رصيد له)
    if (refundType == 'deduct_from_balance' && selectedCustomer != null) {
      int pIdx = parties.indexWhere((pt) => pt['name'] == selectedCustomer!['name']);
      if (pIdx != -1) {
        double currentBal = (parties[pIdx]['balance'] as num).toDouble();
        parties[pIdx]['balance'] = currentBal - totalRefund; // تخفيض الدين المترتب على العميل
      }
      await DatabaseService.saveParties(parties);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم حفظ مردود البيع وإعادة الأصناف للمخزون بقيمة \$$totalRefund!')),
    );

    setState(() {
      returnItems.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    double totalReturnInvoice = returnItems.fold(0, (sum, item) => sum + (item['qty'] * item['price']));

    return Scaffold(
      appBar: AppBar(
        title: const Text('مردود بيع (مرتجعات الزبائن)'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    DropdownButtonFormField<Map<String, dynamic>>(
                      value: selectedCustomer,
                      decoration: const InputDecoration(labelText: 'اختر العميل / الزبون', border: OutlineInputBorder()),
                      items: parties.map((p) {
                        return DropdownMenuItem(
                          value: p,
                          child: Text('${p['name']}'),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => selectedCustomer = val),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('خصم من دين العميل'),
                            value: 'deduct_from_balance',
                            groupValue: refundType,
                            onChanged: (val) => setState(() => refundType = val!),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('رد نقدي (من الصندوق)'),
                            value: 'cash',
                            groupValue: refundType,
                            onChanged: (val) => setState(() => refundType = val!),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    DropdownButtonFormField<Map<String, dynamic>>(
                      value: selectedProduct,
                      decoration: const InputDecoration(labelText: 'اختر الصنف المرتجع من المخزون', border: OutlineInputBorder()),
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
                            priceCtrl.text = val['price'].toString();
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: barcodeCtrl, decoration: const InputDecoration(labelText: 'الباركود', border: OutlineInputBorder()))),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'سعر الارتجاع', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: qtyCtrl, decoration: const InputDecoration(labelText: 'الكمية المرتجعة', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                          onPressed: _addItemToReturn,
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
            Expanded(
              child: Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                child: returnItems.isEmpty
                    ? const Center(child: Text('لم يتم إدراج أصناف لمردود البيع بعد'))
                    : ListView.builder(
                        itemCount: returnItems.length,
                        itemBuilder: (ctx, i) {
                          var item = returnItems[i];
                          double total = item['qty'] * item['price'];
                          return ListTile(
                            title: Text(item['name']),
                            subtitle: Text('الكمية: ${item['qty']} | السعر: \$${item['price']}'),
                            trailing: Text('\$$total', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
              child: Text(
                'إجمالي مردود البيع: \$${totalReturnInvoice.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade800, foregroundColor: Colors.white),
                onPressed: _saveSalesReturn,
                icon: const Icon(Icons.assignment_return),
                label: const Text('حفظ مردود البيع وتحديث المخزون'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
