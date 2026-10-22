import 'package:flutter/material.dart';
import '../../../core/services/database_service.dart';

class PurchaseReturnScreen extends StatefulWidget {
  const PurchaseReturnScreen({super.key});

  @override
  State<PurchaseReturnScreen> createState() => _PurchaseReturnScreenState();
}

class _PurchaseReturnScreenState extends State<PurchaseReturnScreen> {
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> parties = [];
  
  Map<String, dynamic>? selectedSupplier;
  Map<String, dynamic>? selectedProduct;

  final TextEditingController barcodeCtrl = TextEditingController();
  final TextEditingController qtyCtrl = TextEditingController(text: '1');
  final TextEditingController costCtrl = TextEditingController();

  final List<Map<String, dynamic>> returnPurchaseItems = [];
  String refundType = 'deduct_from_supplier_debt'; // خصم من دين المورد أو 'cash' استلام نقدي

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
      if (parties.isNotEmpty) selectedSupplier = parties.first;
    });
  }

  void _addItemToPurchaseReturn() {
    String code = barcodeCtrl.text.trim();
    int qty = int.tryParse(qtyCtrl.text) ?? 1;
    double cost = double.tryParse(costCtrl.text) ?? 0.0;

    if (code.isEmpty || cost <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال الباركود وسعر التكلفة المرتجع بشكل صحيح!'), backgroundColor: Colors.red),
      );
      return;
    }

    var prodMatch = products.firstWhere((p) => p['code'] == code, orElse: () => {});
    String prodName = prodMatch.isNotEmpty ? prodMatch['name'] : 'صنف مردود للمورد ($code)';

    setState(() {
      returnPurchaseItems.add({
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

  Future<void> _savePurchaseReturn() async {
    if (returnPurchaseItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أضف أصناف لقائمة مردود الشراء أولاً!'), backgroundColor: Colors.orange),
      );
      return;
    }

    double totalReturnCost = returnPurchaseItems.fold(0, (sum, item) => sum + (item['qty'] * item['cost']));

    // 1. خصم الكميات المرتجعة من المخزون
    for (var item in returnPurchaseItems) {
      int idx = products.indexWhere((p) => p['code'] == item['code']);
      if (idx != -1) {
        int currentStock = (products[idx]['stock'] as int);
        products[idx]['stock'] = (currentStock - item['qty']) < 0 ? 0 : (currentStock - item['qty']);
      }
    }
    await DatabaseService.saveProducts(products);

    // 2. تحديث حساب المورد (تخفيض الدين المستحق له)
    if (refundType == 'deduct_from_supplier_debt' && selectedSupplier != null) {
      int pIdx = parties.indexWhere((pt) => pt['name'] == selectedSupplier!['name']);
      if (pIdx != -1) {
        double currentBal = (parties[pIdx]['balance'] as num).toDouble();
        parties[pIdx]['balance'] = currentBal + totalReturnCost; // تقليل المبلغ المستحق للمورد
      }
      await DatabaseService.saveParties(parties);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم حفظ مردود الشراء وتخصيم الكميات من المخزون بقيمة \$$totalReturnCost!')),
    );

    setState(() {
      returnPurchaseItems.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    double totalReturnInvoice = returnPurchaseItems.fold(0, (sum, item) => sum + (item['qty'] * item['cost']));

    return Scaffold(
      appBar: AppBar(
        title: const Text('مردود شراء (مرتجعات للموردين)'),
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
                      value: selectedSupplier,
                      decoration: const InputDecoration(labelText: 'اختر المورد / التاجر', border: OutlineInputBorder()),
                      items: parties.map((p) {
                        return DropdownMenuItem(
                          value: p,
                          child: Text('${p['name']}'),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => selectedSupplier = val),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('خصم من دين المورد'),
                            value: 'deduct_from_supplier_debt',
                            groupValue: refundType,
                            onChanged: (val) => setState(() => refundType = val!),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('استلام نقدي (لصندوق)'),
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
                      decoration: const InputDecoration(labelText: 'اختر الصنف المراد إرجاعه للمورد', border: OutlineInputBorder()),
                      items: products.map((p) {
                        return DropdownMenuItem(
                          value: p,
                          child: Text('${p['name']} [باركود: ${p['code']}] - مخزون: ${p['stock']}'),
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
                        Expanded(child: TextField(controller: costCtrl, decoration: const InputDecoration(labelText: 'سعر التكلفة المرتجع', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: qtyCtrl, decoration: const InputDecoration(labelText: 'الكمية المراد إرجاعها', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
                          onPressed: _addItemToPurchaseReturn,
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
                child: returnPurchaseItems.isEmpty
                    ? const Center(child: Text('لم يتم إدراج أصناف لمردود الشراء بعد'))
                    : ListView.builder(
                        itemCount: returnPurchaseItems.length,
                        itemBuilder: (ctx, i) {
                          var item = returnPurchaseItems[i];
                          double total = item['qty'] * item['cost'];
                          return ListTile(
                            title: Text(item['name']),
                            subtitle: Text('الكمية: ${item['qty']} | التكلفة: \$${item['cost']}'),
                            trailing: Text('\$$total', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(8)),
              child: Text(
                'إجمالي مردود الشراء: \$${totalReturnInvoice.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple.shade700, foregroundColor: Colors.white),
                onPressed: _savePurchaseReturn,
                icon: const Icon(Icons.undo),
                label: const Text('حفظ مردود الشراء وتخصيم المخزون'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
