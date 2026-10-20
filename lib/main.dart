import 'package:flutter/material.dart';

void main() {
  runApp(const FullERPAccountingApp());
}

class FullERPAccountingApp extends StatelessWidget {
  const FullERPAccountingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'النظام المحاسبي الشامل',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF10405A),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const ERPWorkspaceScreen(),
    );
  }
}

class OpenTab {
  final String id;
  final String title;
  final IconData icon;
  final Widget content;

  OpenTab({required this.id, required this.title, required this.icon, required this.content});
}

class ERPWorkspaceScreen extends StatefulWidget {
  const ERPWorkspaceScreen({super.key});

  @override
  State<ERPWorkspaceScreen> createState() => _ERPWorkspaceScreenState();
}

class _ERPWorkspaceScreenState extends State<ERPWorkspaceScreen> {
  final List<OpenTab> _openTabs = [];
  int _activeTabIndex = -1;

  void _openNewTab(String id, String title, IconData icon, Widget content) {
    int existingIndex = _openTabs.indexWhere((tab) => tab.id == id);
    if (existingIndex != -1) {
      setState(() => _activeTabIndex = existingIndex);
    } else {
      setState(() {
        _openTabs.add(OpenTab(id: id, title: title, icon: icon, content: content));
        _activeTabIndex = _openTabs.length - 1;
      });
    }
  }

  void _closeTab(int index) {
    setState(() {
      _openTabs.removeAt(index);
      if (_activeTabIndex >= _openTabs.length) {
        _activeTabIndex = _openTabs.length - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم المحاسبية المتكاملة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => setState(() => _activeTabIndex = -1),
            tooltip: 'الواجهة الرئيسية',
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _activeTabIndex == -1 || _openTabs.isEmpty
                ? _buildMainDashboard()
                : _openTabs[_activeTabIndex].content,
          ),
          if (_openTabs.isNotEmpty) _buildBottomTabBar(),
        ],
      ),
    );
  }

  Widget _buildBottomTabBar() {
    return Container(
      height: 48,
      color: Colors.grey.shade200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _openTabs.length + 1,
        itemBuilder: (ctx, idx) {
          if (idx == 0) {
            return InkWell(
              onTap: () => setState(() => _activeTabIndex = -1),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: _activeTabIndex == -1 ? Colors.white : Colors.transparent,
                child: const Row(
                  children: [
                    Icon(Icons.grid_view, size: 18),
                    SizedBox(width: 6),
                    Text('الرئيسية', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            );
          }
          final tabIdx = idx - 1;
          final tab = _openTabs[tabIdx];
          final isActive = _activeTabIndex == tabIdx;

          return Container(
            margin: const EdgeInsets.only(right: 2, top: 4),
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.grey.shade300,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: InkWell(
              onTap: () => setState(() => _activeTabIndex = tabIdx),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Icon(tab.icon, size: 16, color: isActive ? Theme.of(context).primaryColor : Colors.black54),
                    const SizedBox(width: 6),
                    Text(tab.title, style: TextStyle(fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () => _closeTab(tabIdx),
                      child: const Icon(Icons.close, size: 16, color: Colors.grey),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('الفواتير والتجارة', Icons.point_of_sale),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            children: [
              _buildToolCard('فاتورة بيع', Icons.add_shopping_cart, Colors.green, () => _openTab('sale_inv', 'فاتورة بيع', Icons.add_shopping_cart, _buildSaleInvoiceForm())),
              _buildToolCard('مردود مبيعات', Icons.remove_shopping_cart, Colors.orange, () => _openTab('sale_ret', 'مردود بيع', Icons.remove_shopping_cart, _buildGenericForm('مردود مبيعات'))),
              _buildToolCard('فاتورة شراء', Icons.shopping_bag, Colors.blue, () => _openTab('buy_inv', 'فاتورة شراء', Icons.shopping_bag, _buildGenericForm('فاتورة شراء جديدة'))),
              _buildToolCard('مردود مشتريات', Icons.assignment_return, Colors.deepOrange, () => _openTab('buy_ret', 'مردود شراء', Icons.assignment_return, _buildGenericForm('مردود مشتريات'))),
            ],
          ),
          const SizedBox(height: 16),

          _buildSectionHeader('السندات والمالية', Icons.account_balance_wallet),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            children: [
              _buildToolCard('سند قبض', Icons.arrow_downward, Colors.teal, () => _openTab('rec_v', 'سند قبض', Icons.arrow_downward, _buildGenericForm('سند قبض جديد'))),
              _buildToolCard('سند صرف', Icons.arrow_upward, Colors.redAccent, () => _openTab('pay_v', 'سند صرف', Icons.arrow_upward, _buildGenericForm('سند صرف جديد'))),
              _buildToolCard('شيكات واردة', Icons.subtitles, Colors.indigo, () => _openTab('chq_in', 'شيكات واردة', Icons.subtitles, _buildGenericList('سجل الشيكات الواردة'))),
              _buildToolCard('شيكات صادرة', Icons.confirmation_number, Colors.brown, () => _openTab('chq_out', 'شيكات صادرة', Icons.confirmation_number, _buildGenericList('سجل الشيكات الصادرة'))),
            ],
          ),
          const SizedBox(height: 16),

          _buildSectionHeader('الصيانة والأدلة والملاحظات', Icons.build_circle),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            children: [
              _buildToolCard('أوامر الصيانه', Icons.build, Colors.amber.shade800, () => _openTab('maint', 'أوامر الصيانه', Icons.build, _buildGenericList('أوامر وتذاكر الصيانة'))),
              _buildToolCard('دفتر الملاحظات', Icons.note_alt, Colors.purple, () => _openTab('notes', 'دفتر الملاحظات', Icons.note_alt, _buildNotebookTab())),
              _buildToolCard('شجرة الحسابات', Icons.account_tree, Colors.blueGrey, () => _openTab('acc_tree', 'شجرة الحسابات', Icons.account_tree, _buildGenericTree('شجرة دليل الحسابات'))),
              _buildToolCard('شجرة الأصناف', Icons.category, Colors.cyan.shade700, () => _openTab('item_tree', 'شجرة الأصناف', Icons.category, _buildGenericTree('شجرة دليل الأصناف'))),
            ],
          ),
          const SizedBox(height: 16),

          _buildSectionHeader('التقارير والأرباح والحسابات', Icons.analytics),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            children: [
              _buildToolCard('كشف حساب', Icons.receipt_long, Colors.blue, () => _openTab('stmt', 'كشف حساب', Icons.receipt_long, _buildGenericList('كشف حساب تفصيلي'))),
              _buildToolCard('حركة الأصناف', Icons.inventory, Colors.green, () => _openTab('item_mov', 'حركة الأصناف', Icons.inventory, _buildGenericList('تقرير حركة المخزون'))),
              _buildToolCard('أرباح المبيعات', Icons.monetization_on, Colors.lightGreen.shade700, () => _openTab('sales_prof', 'أرباح المبيعات', Icons.monetization_on, _buildReportCard('تقرير أرباح المبيعات'))),
              _buildToolCard('أرباح الأصناف', Icons.query_stats, Colors.deepPurple, () => _openTab('item_prof', 'أرباح الأصناف', Icons.query_stats, _buildReportCard('تقرير أرباح الأصناف والتكلفة'))),
              _buildToolCard('حساب المصاريف', Icons.money_off, Colors.red, () => _openTab('exp_acc', 'حساب المصاريف', Icons.money_off, _buildGenericList('دليل وحساب المصاريف'))),
              _buildToolCard('حساب الإيرادات', Icons.attach_money, Colors.green.shade800, () => _openTab('inc_acc', 'حساب الإيرادات', Icons.attach_money, _buildGenericList('دليل وحساب الإيرادات'))),
            ],
          ),
        ],
      ),
    );
  }

  void _openTab(String id, String title, IconData icon, Widget content) {
    _openNewTab(id, title, icon, content);
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 20),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildToolCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              CircleAvatar(backgroundColor: color.withOpacity(0.15), radius: 18, child: Icon(icon, color: color, size: 20)),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 1. [تعديل] واجهة فاتورة البيع المتقدمة
  // ==========================================
  Widget _buildSaleInvoiceForm() {
    final TextEditingController clientCtrl = TextEditingController();
    final TextEditingController itemNoCtrl = TextEditingController();
    final TextEditingController qtyCtrl = TextEditingController(text: '1');
    final TextEditingController priceCtrl = TextEditingController();

    return StatefulBuilder(
      builder: (context, setStateSB) {
        List<Map<String, dynamic>> itemsList = [];

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              const Text('فاتورة بيع جديدة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(controller: clientCtrl, decoration: const InputDecoration(labelText: 'اسم العميل / الحساب', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextField(controller: itemNoCtrl, decoration: const InputDecoration(labelText: 'رقم / باركود الصنف', border: OutlineInputBorder()))),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      setStateSB(() {
                        itemNoCtrl.text = "PRD-501";
                        priceCtrl.text = "75.0";
                      });
                    },
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('قراءة'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextField(controller: qtyCtrl, decoration: const InputDecoration(labelText: 'الكمية', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'السعر', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  if (itemNoCtrl.text.isNotEmpty && priceCtrl.text.isNotEmpty) {
                    setStateSB(() {
                      itemsList.add({
                        'code': itemNoCtrl.text,
                        'qty': qtyCtrl.text,
                        'price': priceCtrl.text,
                      });
                      itemNoCtrl.clear();
                      priceCtrl.clear();
                      qtyCtrl.text = '1';
                    });
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('إضافة الصنف للفاتورة'),
              ),
              const Divider(height: 30),
              const Text('الأصناف المضافة:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                height: 140,
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
                child: itemsList.isEmpty
                    ? const Center(child: Text('لم يتم إدراج أصناف بعد', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        itemCount: itemsList.length,
                        itemBuilder: (ctx, i) {
                          final itm = itemsList[i];
                          return ListTile(
                            title: Text('الصنف: ${itm['code']}'),
                            subtitle: Text('الكمية: ${itm['qty']} | السعر: \$${itm['price']}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => setStateSB(() => itemsList.removeAt(i)),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ فاتورة البيع بنجاح!')));
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('حفظ الفاتورة'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جاري إعداد وتصدير ملف الـ PDF...')));
                      },
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('تصدير PDF'),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // 2. النماذج العامة الأخرى
  // ==========================================
  Widget _buildGenericForm(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const TextField(decoration: InputDecoration(labelText: 'اسم الحساب / العميل', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          const TextField(decoration: InputDecoration(labelText: 'المبلغ / القيمة', border: OutlineInputBorder()), keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          const TextField(decoration: InputDecoration(labelText: 'البيان / ملاحظات', border: OutlineInputBorder()), maxLines: 2),
          const SizedBox(height: 20),
          ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.save), label: const Text('حفظ واحتساب')),
        ],
      ),
    );
  }

  Widget _buildNotebookTab() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('دفتر الملاحظات والمهام', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Expanded(
            child: TextField(
              maxLines: null,
              expands: true,
              decoration: InputDecoration(
                hintText: 'اكتب ملاحظات الصيانة، الديون المتبقية، أو تذكيرات العمل هنا...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenericList(String title) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 5,
      itemBuilder: (ctx, idx) => Card(
        child: ListTile(
          leading: const Icon(Icons.receipt),
          title: Text('$title #${idx + 101}'),
          subtitle: const Text('التاريخ: 2026/10/20 - الحالة: مكتمل'),
          trailing: const Text('\$150.00', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildGenericTree(String title) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Divider(),
        const ExpansionTile(
          title: Text('1. الأصول (Assets)'),
          children: [
            ListTile(title: Text('11. الصندوق والبنك')),
            ListTile(title: Text('12. الذمم المدينة (العملاء)')),
          ],
        ),
        const ExpansionTile(
          title: Text('2. الخصومات (Liabilities)'),
          children: [
            ListTile(title: Text('21. الموردين (الدائنون)')),
          ],
        ),
      ],
    );
  }

  Widget _buildReportCard(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            color: Colors.blue.shade50,
            child: ListTile(
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('إجمالي صافي الأرباح المحسوبة لهذا الشهر'),
              trailing: const Text('\$3,450.00', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
            ),
          )
        ],
      ),
    );
  }
}
