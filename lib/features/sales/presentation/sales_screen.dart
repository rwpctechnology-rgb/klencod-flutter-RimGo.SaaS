import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'barcode_scanner_screen.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> parties = [];
  
  Map<String, dynamic>? selectedParty;
  Map<String, dynamic>? selectedProduct;

  final TextEditingController itemCodeCtrl = TextEditingController();
  final TextEditingController qtyCtrl = TextEditingController(text: '1');
  final TextEditingController priceCtrl = TextEditingController();
  final TextEditingController discountCtrl = TextEditingController(text: '0');

  final List<Map<String, dynamic>> invoiceItems = [];
  String paymentType = 'cash'; // 'cash' نقداً أو 'credit' بالآجل / على الحساب
  String validationMessage = '';

  @override
  void initState() {
    super.initState();
    _loadMasterData();
  }

  Future<void> _loadMasterData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      String? pStr = prefs.getString('rimgo_products');
      if (pStr != null) {
        products = List<Map<String, dynamic>>.from(jsonDecode(pStr));
      } else {
        // أصناف افتراضية أولية
        products = [
          {'code': '101', 'name': 'حقيبة لابتوب', 'price': 35.0, 'stock': 10},
          {'code': '102', 'name': 'شاحن سريع 65W', 'price': 15.0, 'stock': 25},
          {'code': '103', 'name': 'ماوس لاسلكي', 'price': 8.0, 'stock': 40},
        ];
      }

      String? ptStr = prefs.getString('rimgo_parties');
      if (ptStr != null) {
        parties = List<Map<String, dynamic>>.from(jsonDecode(ptStr));
      } else {
        // عملاء افتراضيون أوليون
        parties = [
          {'name': 'زبون نقدي عام', 'phone': '000', 'type': 'customer', 'balance': 0.0},
          {'name': 'شركة الأمل للتجارة', 'phone': '0599000111', 'type': 'customer', 'balance': 150.0},
          {'name': 'مؤسسة القدس', 'phone': '0569000222', 'type': 'customer', 'balance': 0.0},
        ];
      }

      if (parties.isNotEmpty) selectedParty = parties.first;
    });
  }

  Future<void> _saveInvoiceAndUpdateBalance(double finalTotal) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. تحديث مخزون الأصناف
    for (var invItem in invoiceItems) {
      int idx = products.indexWhere((p) => p['code'] == invItem['code']);
      if (idx != -1) {
        products[idx]['stock'] = (products[idx]['stock'] as int) - (invItem['qty'] as int);
      }
    }
    await prefs.setString('rimgo_products', jsonEncode(products));

    // 2. تحديث رصيد العميل إذا كان الشراء بالآجل (دين)
    if (paymentType == 'credit' && selectedParty != null) {
      int pIdx = parties.indexWhere((pt) => pt['name'] == selectedParty!['name']);
      if (pIdx != -1) {
        double currentBal = (parties[pIdx]['balance'] as num).toDouble();
        parties[pIdx]['balance'] = currentBal + finalTotal; // إضافة المبلع كدين عليه
      }
      await prefs.setString('rimgo_parties', jsonEncode(parties));
    }

    // 3. حفظ الفاتورة في السجل
    String? invStr = prefs.getString('rimgo_invoices');
    List<dynamic> existingInvoices = invStr != null ? jsonDecode(invStr) : [];
    existingInvoices.insert(0, {
      'client': selectedParty?['name'] ?? 'زبون نقدي',
      'paymentType': paymentType == 'cash' ? 'نقداً' : 'بالآجل (على الحساب)',
      'total': finalTotal,
      'itemsCount': invoiceItems.length,
      'date': DateTime.now().toString().substring(0, 16),
    });
    await prefs.setString('rimgo_invoices', jsonEncode(existingInvoices));
  }

  void _onProductSelected(Map<String, dynamic>? prod) {
    if (prod == null) return;
    setState(() {
      selectedProduct = prod;
      itemCodeCtrl.text = prod['code'];
      priceCtrl.text = prod['price'].toString();
      validationMessage = 'المخزون المتاح: ${prod['stock']} قطعة';
    });
  }

  @override
  Widget build(BuildContext context) {
    double subtotal = invoiceItems.fold(0, (sum, item) => sum + (item['qty'] * item['price']));
    double discount = double.tryParse(discountCtrl.text) ?? 0.0;
    double finalTotal = subtotal - discount;
    if (finalTotal < 0) finalTotal = 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('فاتورة بيع جديدة'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // 1. اختيار العميل / الحساب مع إمكانية التحديد الديناميكي
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('بيانات العميل وطريقة الدفع', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<Map<String, dynamic>>(
                      value: selectedParty,
                      decoration: const InputDecoration(
                        labelText: 'اختيار العميل / الحساب',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      items: parties.map((p) {
                        return DropdownMenuItem(
                          value: p,
                          child: Text('${p['name']} (الرصيد الحالي: \$${p['balance']})'),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => selectedParty = val),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('نقداً (كاش)'),
                            value: 'cash',
                            groupValue: paymentType,
                            onChanged: (val) => setState(() => paymentType = val!),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('بالآجل (دين)'),
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
            const SizedBox(height: 12),

            // 2. اختيار الصنف مسح الباركود بالكاميرا
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('تحديد الأصناف', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<Map<String, dynamic>>(
                      value: selectedProduct,
                      decoration: const InputDecoration(
                        labelText: 'اختر الصنف من القائمة',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.inventory_2),
                      ),
                      items: products.map((p) {
                        return DropdownMenuItem(
                          value: p,
                          child: Text('${p['name']} - [الباركود: ${p['code']}] - \$${p['price']}'),
                        );
                      }).toList(),
                      onChanged: _onProductSelected,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: itemCodeCtrl,
                            decoration: const InputDecoration(
                              labelText: 'الباركود',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                          onPressed: () async {
                            // فتح كاميرا مسح الباركود
                            final scannedCode = await Navigator.push<String>(
                              context,
                              MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
                            );
                            if (scannedCode != null) {
                              var found = products.firstWhere(
                                (p) => p['code'] == scannedCode,
                                orElse: () => {},
                              );
                              if (found.isNotEmpty) {
                                _onProductSelected(found);
                              } else {
                                setState(() {
                                  itemCodeCtrl.text = scannedCode;
                                  validationMessage = 'صنف غير مسجل! أدخل البيانات لإضافته.';
                                });
                              }
                            }
                          },
                          icon: const Icon(Icons.qr_code_scanner),
                          label: const Text('الكاميرا'),
                        ),
                      ],
                    ),
                    if (validationMessage.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(validationMessage, style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: qtyCtrl,
                            decoration: const InputDecoration(labelText: 'الكمية', border: OutlineInputBorder()),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: priceCtrl,
                            decoration: const InputDecoration(labelText: 'السعر الإفرادي', border: OutlineInputBorder()),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                        onPressed: () {
                          String code = itemCodeCtrl.text.trim();
                          int q = int.tryParse(qtyCtrl.text) ?? 1;
                          double p = double.tryParse(priceCtrl.text) ?? 0.0;
                          String pName = selectedProduct != null ? selectedProduct!['name'] : 'صنف برقم $code';

                          if (code.isNotEmpty && p > 0) {
                            setState(() {
                              invoiceItems.add({
                                'name': pName,
                                'code': code,
                                'qty': q,
                                'price': p,
                              });
                              itemCodeCtrl.clear();
                              priceCtrl.clear();
                              qtyCtrl.text = '1';
                              selectedProduct = null;
                              validationMessage = 'تمت إضافة الصنف للفاتورة';
                            });
                          }
                        },
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('إضافة الصنف للفاتورة'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 3. جدول الأصناف في الفاتورة
            const Text('الأصناف في الفاتورة:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 6),
            Container(
              height: 140,
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
              child: invoiceItems.isEmpty
                  ? const Center(child: Text('لا توجد أصناف مضافة حالياً', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: invoiceItems.length,
                      itemBuilder: (ctx, i) {
                        final itm = invoiceItems[i];
                        double total = itm['qty'] * itm['price'];
                        return ListTile(
                          title: Text(itm['name']),
                          subtitle: Text('الكمية: ${itm['qty']} | السعر: \$${itm['price']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('\$$total', style: const TextStyle(fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => setState(() => invoiceItems.removeAt(i)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 12),

            // 4. الخصم والإجمالي المحاسبي
            TextField(
              controller: discountCtrl,
              decoration: const InputDecoration(labelText: 'الخصم (\$)', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
              child: Text(
                'الصافي النهائي للدفع: \$${finalTotal.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 14),

            // زر حفظ الفاتورة وتحديث المخزون والديون
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
                onPressed: () async {
                  if (invoiceItems.isNotEmpty) {
                    await _saveInvoiceAndUpdateBalance(finalTotal);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('تم حفظ الفاتورة وتحديث ${paymentType == 'credit' ? 'رصيد دين العميل' : 'الصندوق والمخزون'} بنجاح!')),
                    );
                    setState(() {
                      invoiceItems.clear();
                      discountCtrl.text = '0';
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أضف أصناف للفاتورة أولاً.')));
                  }
                },
                icon: const Icon(Icons.save),
                label: const Text('حفظ واصدار الفاتورة المحاسبية'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}