import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/database_service.dart';
import 'barcode_scanner_screen.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> parties = [];
  Map<String, double> customerLastPrices = {}; // ذاكرة أسعار الزبائن

  Map<String, dynamic>? selectedParty;
  Map<String, dynamic>? selectedProduct;

  final TextEditingController itemCodeCtrl = TextEditingController();
  final TextEditingController qtyCtrl = TextEditingController(text: '1');
  final TextEditingController priceCtrl = TextEditingController();
  final TextEditingController discountCtrl = TextEditingController(text: '0');

  final List<Map<String, dynamic>> invoiceItems = [];
  String paymentType = 'cash'; // 'cash' أو 'credit'
  bool showCostPrice = false; // إظهار/إخفاء سعر الجملة/التكلفة

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    List<Map<String, dynamic>> loadedProducts = await DatabaseService.getProducts();
    List<Map<String, dynamic>> loadedParties = await DatabaseService.getParties();
    
    final prefs = await SharedPreferences.getInstance();
    String? pricesStr = prefs.getString('rimgo_customer_prices');
    Map<String, double> pricesMap = {};
    if (pricesStr != null) {
      Map<String, dynamic> decoded = jsonDecode(pricesStr);
      decoded.forEach((key, value) {
        pricesMap[key] = (value as num).toDouble();
      });
    }

    setState(() {
      products = loadedProducts;
      parties = loadedParties;
      customerLastPrices = pricesMap;
      if (parties.isNotEmpty) selectedParty = parties.first;
    });
  }

  // البحث إضافة الصنف تلقائياً للجدول عند مسح الباركود
  void _addByBarcode(String code) {
    if (code.isEmpty) return;

    var foundIndex = products.indexWhere((p) => p['code'] == code);
    if (foundIndex != -1) {
      var prod = products[foundIndex];
      double sellPrice = (prod['price'] as num).toDouble();

      // التحقق من وجود سعر خاص سابق لهذا الزبون مع هذا الصنف
      if (selectedParty != null) {
        String key = '${selectedParty!['name']}_$code';
        if (customerLastPrices.containsKey(key)) {
          sellPrice = customerLastPrices[key]!;
        }
      }

      _addItemToInvoiceTable(
        code: prod['code'],
        name: prod['name'],
        price: sellPrice,
        costPrice: (prod['costPrice'] ?? (sellPrice * 0.7)).toDouble(),
        qty: 1,
      );

      itemCodeCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تمت إضافة ${prod['name']} تلقائياً للفاتورة')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('الباركود $code غير مسجل بالمخزون!'), backgroundColor: Colors.red),
      );
    }
  }

  void _addItemToInvoiceTable({
    required String code,
    required String name,
    required double price,
    required double costPrice,
    required int qty,
  }) {
    setState(() {
      int existingIndex = invoiceItems.indexWhere((item) => item['code'] == code);
      if (existingIndex != -1) {
        invoiceItems[existingIndex]['qty'] += qty;
      } else {
        invoiceItems.add({
          'code': code,
          'name': name,
          'price': price,
          'costPrice': costPrice,
          'qty': qty,
        });
      }
    });
  }

  // المصادقة لإظهار سعر التكلفة والجملة
  void _authenticateToShowCost() {
    showDialog(
      context: context,
      builder: (ctx) {
        TextEditingController pinCtrl = TextEditingController();
        return AlertDialog(
          title: const Text('مصادقة الأمان (سعر التكلفة/الجملة)'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('أدخل رمز المرور أو البصمة لرؤية سعر الجملة/التكلفة:'),
              const SizedBox(height: 10),
              TextField(
                controller: pinCtrl,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'رمز الأمان (الافتراضي 1234)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                if (pinCtrl.text == '1234' || pinCtrl.text.isNotEmpty) {
                  setState(() => showCostPrice = true);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم تفعيل عرض سعر الجملة والتكلفة')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('رمز غير صحيح!'), backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text('تأكيد'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveInvoice() async {
    if (invoiceItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إضافة أصناف للفاتورة أولاً!'), backgroundColor: Colors.orange),
      );
      return;
    }

    if (paymentType == 'credit' && (selectedParty == null || selectedParty!['name'] == 'زبون نقدي عام')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تنبيه: يجب تحديد اسم الزبون عند البيع بالآجل (الدين)!'), backgroundColor: Colors.red),
      );
      return;
    }

    double subtotal = invoiceItems.fold(0, (sum, item) => sum + (item['qty'] * item['price']));
    double discount = double.tryParse(discountCtrl.text) ?? 0.0;
    double finalTotal = subtotal - discount;

    // 1. حفظ أسعار المبيعات الخاصة بهذا الزبون لاسترجاعها مستقبلاً
    if (selectedParty != null) {
      final prefs = await SharedPreferences.getInstance();
      for (var item in invoiceItems) {
        String key = '${selectedParty!['name']}_${item['code']}';
        customerLastPrices[key] = (item['price'] as num).toDouble();
      }
      await prefs.setString('rimgo_customer_prices', jsonEncode(customerLastPrices));
    }

    // 2. تحديث المخزون
    for (var item in invoiceItems) {
      int idx = products.indexWhere((p) => p['code'] == item['code']);
      if (idx != -1) {
        products[idx]['stock'] = (products[idx]['stock'] as int) - (item['qty'] as int);
      }
    }
    await DatabaseService.saveProducts(products);

    // 3. في حال كان البيع بالآجل -> إضافة المبلغ لحساب الزبون
    if (paymentType == 'credit' && selectedParty != null) {
      int pIdx = parties.indexWhere((pt) => pt['name'] == selectedParty!['name']);
      if (pIdx != -1) {
        parties[pIdx]['balance'] = (parties[pIdx]['balance'] as num).toDouble() + finalTotal;
      }
      await DatabaseService.saveParties(parties);
    }

    // 4. تسجيل الفاتورة
    List<Map<String, dynamic>> currentInvoices = await DatabaseService.getInvoices();
    currentInvoices.insert(0, {
      'client': selectedParty?['name'] ?? 'زبون نقدي',
      'paymentType': paymentType == 'cash' ? 'نقداً (الصندوق الرئيسي)' : 'بالآجل (على الحساب)',
      'total': finalTotal,
      'itemsCount': invoiceItems.length,
      'date': DateTime.now().toString().substring(0, 16),
    });
    await DatabaseService.saveInvoices(currentInvoices);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم إصدار الفاتورة وتحديث ${paymentType == 'cash' ? "الصندوق الرئيسي" : "حساب الزبون"} والمخزون بنجاح!')),
    );

    setState(() {
      invoiceItems.clear();
      discountCtrl.text = '0';
    });
  }

  @override
  Widget build(BuildContext context) {
    double subtotal = invoiceItems.fold(0, (sum, item) => sum + (item['qty'] * item['price']));
    double discount = double.tryParse(discountCtrl.text) ?? 0.0;
    double finalTotal = (subtotal - discount) < 0 ? 0 : (subtotal - discount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('فاتورة بيع متقدمة'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(showCostPrice ? Icons.visibility : Icons.visibility_off),
            tooltip: 'إظهار/إخفاء سعر الجملة والتكلفة',
            onPressed: () {
              if (showCostPrice) {
                setState(() => showCostPrice = false);
              } else {
                _authenticateToShowCost();
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            // 1. اختيار الحساب وطريقة الدفع
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    DropdownButtonFormField<Map<String, dynamic>>(
                      value: selectedParty,
                      decoration: const InputDecoration(
                        labelText: 'حساب العميل / الزبون',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      items: parties.map((p) {
                        return DropdownMenuItem(
                          value: p,
                          child: Text('${p['name']} (الرصيد: \$${p['balance']})'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedParty = val;
                        });
                      },
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('نقداً (للصندوق الرئيسي)'),
                            value: 'cash',
                            groupValue: paymentType,
                            onChanged: (val) => setState(() => paymentType = val!),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('بالآجل (على الزبون)'),
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

            const SizedBox(height: 8),

            // 2. إدخال الباركود السريع والكاميرا
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: itemCodeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'أدخل / امسح الباركود (إضافة فورية)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.qr_code),
                    ),
                    onSubmitted: (code) => _addByBarcode(code),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  ),
                  onPressed: () async {
                    final scannedCode = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
                    );
                    if (scannedCode != null) {
                      _addByBarcode(scannedCode);
                    }
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('كاميرا'),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 3. جدول أصناف الفاتورة القابل لتعديل الأسعار
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: invoiceItems.isEmpty
                    ? const Center(child: Text('امسح الباركود لإضافة أصناف للفاتورة تلقائياً'))
                    : ListView.builder(
                        itemCount: invoiceItems.length,
                        itemBuilder: (ctx, i) {
                          var item = invoiceItems[i];
                          return Card(
                            margin: const EdgeInsets.all(6),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                        if (showCostPrice)
                                          Text(
                                            'سعر التكلفة: \$${item['costPrice']}',
                                            style: const TextStyle(color: Colors.red, fontSize: 12),
                                          ),
                                      ],
                                    ),
                                  ),
                                  // الكمية
                                  SizedBox(
                                    width: 50,
                                    child: TextField(
                                      key: ValueKey('qty_${item['code']}'),
                                      controller: TextEditingController(text: item['qty'].toString()),
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(labelText: 'الكمية'),
                                      onChanged: (val) {
                                        int? newQty = int.tryParse(val);
                                        if (newQty != null && newQty > 0) {
                                          setState(() => item['qty'] = newQty);
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // تعديل السعر
                                  SizedBox(
                                    width: 70,
                                    child: TextField(
                                      key: ValueKey('price_${item['code']}'),
                                      controller: TextEditingController(text: item['price'].toString()),
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(labelText: 'السعر \$'),
                                      onChanged: (val) {
                                        double? newPrice = double.tryParse(val);
                                        if (newPrice != null) {
                                          setState(() => item['price'] = newPrice);
                                        }
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      setState(() => invoiceItems.removeAt(i));
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),

            const SizedBox(height: 8),

            // 4. الخصم والإجمالي وحفظ الفاتورة
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: discountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'الخصم (\$)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'الصافي: \$${finalTotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                ),
                onPressed: _saveInvoice,
                icon: const Icon(Icons.check_circle),
                label: const Text('حفظ واصدار الفاتورة'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
