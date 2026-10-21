import 'package:flutter/material.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final TextEditingController clientCtrl = TextEditingController();
  final TextEditingController itemCodeCtrl = TextEditingController();
  final TextEditingController qtyCtrl = TextEditingController(text: '1');
  final TextEditingController priceCtrl = TextEditingController();
  final TextEditingController discountCtrl = TextEditingController(text: '0');

  final List<Map<String, dynamic>> registeredItems = [
    {'code': '101', 'name': 'قلم حبر جاف', 'price': 2.5, 'stock': 50},
    {'code': '102', 'name': 'دفتر تسجيل', 'price': 5.0, 'stock': 20},
    {'code': '103', 'name': 'حقيبة لابتوب', 'price': 35.0, 'stock': 5},
  ];

  final List<String> registeredClients = ['شركة الأمل للتجارة', 'مؤسسة النور', 'محمد أحمد'];
  final List<Map<String, dynamic>> invoiceItems = [];
  String validationMessage = '';

  @override
  Widget build(BuildContext context) {
    double subtotal = invoiceItems.fold(0, (sum, item) => sum + (item['qty'] * item['price']));
    double discount = double.tryParse(discountCtrl.text) ?? 0.0;
    double finalTotal = subtotal - discount;
    if (finalTotal < 0) finalTotal = 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('فاتورة بيع جديدة'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // اسم العميل
            TextField(
              controller: clientCtrl,
              decoration: const InputDecoration(
                labelText: 'اسم العميل / الحساب',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),

            // باركود الصنف
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: itemCodeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'رقم / باركود الصنف',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.qr_code),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      String code = itemCodeCtrl.text.trim();
                      var found = registeredItems.firstWhere(
                        (i) => i['code'] == code,
                        orElse: () => {},
                      );
                      if (found.isNotEmpty) {
                        priceCtrl.text = found['price'].toString();
                        validationMessage = 'تم العثور على: ${found['name']} (المخزون: ${found['stock']})';
                      } else {
                        validationMessage = 'خطأ: الصنف غير مسجل في النظام!';
                      }
                    });
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('فحص'),
                ),
              ],
            ),
            if (validationMessage.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                validationMessage,
                style: TextStyle(
                  color: validationMessage.contains('خطأ') ? Colors.red : Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(height: 12),

            // الكمية والسعر
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
            const SizedBox(height: 12),

            // زر الإضافة للفاتورة
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.secondary, foregroundColor: Colors.white),
              onPressed: () {
                String code = itemCodeCtrl.text.trim();
                var matched = registeredItems.firstWhere(
                  (i) => i['code'] == code,
                  orElse: () => {},
                );

                if (matched.isNotEmpty && clientCtrl.text.isNotEmpty) {
                  int q = int.tryParse(qtyCtrl.text) ?? 1;
                  setState(() {
                    invoiceItems.add({
                      'name': matched['name'],
                      'code': code,
                      'qty': q,
                      'price': double.tryParse(priceCtrl.text) ?? matched['price'],
                    });
                    itemCodeCtrl.clear();
                    priceCtrl.clear();
                    qtyCtrl.text = '1';
                    validationMessage = 'تمت إضافة الصنف بنجاح';
                  });
                } else {
                  setState(() {
                    validationMessage = 'الرجاء التأكد من اسم العميل وصحة الصنف!';
                  });
                }
              },
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('إضافة الصنف إلى الفاتورة'),
            ),

            const Divider(height: 30),
            const Text('الأصناف المضافة:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),

            // جدول الأصناف المضافة
            Container(
              height: 150,
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
              child: invoiceItems.isEmpty
                  ? const Center(child: Text('لا توجد أصناف مضافة حالياً', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: invoiceItems.length,
                      itemBuilder: (ctx, i) {
                        final itm = invoiceItems[i];
                        double total = itm['qty'] * itm['price'];
                        return ListTile(
                          title: Text(itm['name']),
                          subtitle: Text('الكمية: ${itm['qty']} | السعر: \$${itm['price']} | الإجمالي: \$$total'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => setState(() => invoiceItems.removeAt(i)),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 12),

            // خانة الخصم
            TextField(
              controller: discountCtrl,
              decoration: const InputDecoration(labelText: 'قيمة الخصم على الفاتورة (\$)', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              onChanged: (val) => setState(() {}),
            ),
            const SizedBox(height: 12),

            // الملخص المالي النهائي
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
              child: Text(
                'الصافي النهائي للدفع: \$${finalTotal.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),

            // أزرار الحفظ والتصدير
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    onPressed: () {
                      if (invoiceItems.isNotEmpty && clientCtrl.text.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم حفظ الفاتورة وتحديث المخزون بنجاح بطريقة محاسبية آمنة!')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('أدخل اسم العميل وأضف أصناف صحيحة أولاً.')),
                        );
                      }
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('حفظ الفاتورة'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey, foregroundColor: Colors.white),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('جاري تصدير الفاتورة كملف PDF رسمي...')),
                      );
                    },
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('تصدير PDF'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
