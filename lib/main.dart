import 'package:flutter/material.dart';

void main() {
  runApp(const AccountingApp());
}

class AccountingApp extends StatelessWidget {
  const AccountingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'نظام المحاسبة الذكي',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const MainHomeScreen(),
    );
  }
}

// نموذج بيانات الحساب (عميل / مورد)
class Account {
  final String id;
  final String name;
  final String phone;
  double debit; // مدين (له)
  double credit; // دائن (عليه)

  Account({
    required this.id,
    required this.name,
    required this.phone,
    this.debit = 0.0,
    this.credit = 0.0,
  });

  double get balance => debit - credit;
}

// نموذج بيانات الصنف / المنتجات
class Product {
  final String id;
  final String name;
  double costPrice; // التكلفة
  double sellPrice; // سعر البيع
  int quantity; // الكمية

  Product({
    required this.id,
    required this.name,
    required this.costPrice,
    required this.sellPrice,
    required this.quantity,
  });
}

// نموذج المعاملة المالية
class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final String type; // 'قبض', 'صرف', 'بيع', 'شراء'
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
  });
}

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _selectedIndex = 0;

  // البيانات التقديرية للبدء
  final List<Account> _accounts = [
    Account(id: '1', name: 'شركة الأمل', phone: '0590000000', debit: 1500, credit: 200),
    Account(id: '2', name: 'العميل أحمد', phone: '0560000000', debit: 0, credit: 450),
  ];

  final List<Product> _products = [
    Product(id: '1', name: 'منتج أ', costPrice: 50, sellPrice: 75, quantity: 100),
    Product(id: '2', name: 'منتج ب', costPrice: 120, sellPrice: 160, quantity: 30),
  ];

  final List<TransactionModel> _transactions = [
    TransactionModel(id: '1', title: 'دفعة من العميل أحمد', amount: 200, type: 'قبض', date: DateTime.now()),
    TransactionModel(id: '2', title: 'شراء بضاعة جديدة', amount: 500, type: 'صرف', date: DateTime.now()),
  ];

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildDashboardTab(),
      _buildAccountsTab(),
      _buildProductsTab(),
      _buildTransactionsTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('المحاسب الذكي', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'الحسابات'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'الأصناف'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'الحركات'),
        ],
      ),
    );
  }

  // --- 1. شاشة لوحة التحكم ---
  Widget _buildDashboardTab() {
    double totalDebit = _accounts.fold(0, (sum, item) => sum + item.debit);
    double totalCredit = _accounts.fold(0, (sum, item) => sum + item.credit);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: _buildSummaryCard('إجمالي لكم (مدين)', '\$${totalDebit.toStringAsFixed(2)}', Colors.green)),
              const SizedBox(width: 12),
              Expanded(child: _buildSummaryCard('إجمالي عليكم (دائن)', '\$${totalCredit.toStringAsFixed(2)}', Colors.red)),
            ],
          ),
          const SizedBox(height: 12),
          _buildSummaryCard('الصافي الحالي', '\$${(totalDebit - totalCredit).toStringAsFixed(2)}', Colors.blue),
          const SizedBox(height: 20),
          const Text('آخر الحركات المالية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _transactions.length,
            itemBuilder: (context, index) {
              final tx = _transactions[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: tx.type == 'قبض' ? Colors.green.shade100 : Colors.red.shade100,
                    child: Icon(
                      tx.type == 'قبض' ? Icons.arrow_downward : Icons.arrow_upward,
                      color: tx.type == 'قبض' ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(tx.title),
                  subtitle: Text('${tx.date.day}/${tx.date.month}/${tx.date.year}'),
                  trailing: Text(
                    '\$${tx.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: tx.type == 'قبض' ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  // --- 2. شاشة الحسابات ---
  Widget _buildAccountsTab() {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewAccountDialog,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _accounts.length,
        itemBuilder: (context, index) {
          final acc = _accounts[index];
          return Card(
            child: ListTile(
              title: Text(acc.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('هاتف: ${acc.phone}'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('له: \$${acc.debit}', style: const TextStyle(color: Colors.green, fontSize: 12)),
                  Text('عليه: \$${acc.credit}', style: const TextStyle(color: Colors.red, fontSize: 12)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- 3. شاشة الأصناف ---
  Widget _buildProductsTab() {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewProductDialog,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final prod = _products[index];
          return Card(
            child: ListTile(
              title: Text(prod.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('التكلفة: \$${prod.costPrice} | البيع: \$${prod.sellPrice}'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('الكمية: ${prod.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- 4. شاشة الحركات المالية ---
  Widget _buildTransactionsTab() {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewTransactionDialog,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _transactions.length,
        itemBuilder: (context, index) {
          final tx = _transactions[index];
          return Card(
            child: ListTile(
              title: Text(tx.title),
              subtitle: Text('النوع: ${tx.type}'),
              trailing: Text('\$${tx.amount}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          );
        },
      ),
    );
  }

  // حوارات إضافة البيانات الجديدة
  void _addNewAccountDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة حساب جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم الحساب/العميل')),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'رقم الهاتف'), keyboardType: TextInputType.phone),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                setState(() {
                  _accounts.add(Account(
                    id: DateTime.now().toString(),
                    name: nameCtrl.text,
                    phone: phoneCtrl.text,
                  ));
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _addNewProductDialog() {
    final nameCtrl = TextEditingController();
    final costCtrl = TextEditingController();
    final sellCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة صنف جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم الصنف')),
            TextField(controller: costCtrl, decoration: const InputDecoration(labelText: 'سعر التكلفة'), keyboardType: TextInputType.number),
            TextField(controller: sellCtrl, decoration: const InputDecoration(labelText: 'سعر البيع'), keyboardType: TextInputType.number),
            TextField(controller: qtyCtrl, decoration: const InputDecoration(labelText: 'الكمية الحالية'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                setState(() {
                  _products.add(Product(
                    id: DateTime.now().toString(),
                    name: nameCtrl.text,
                    costPrice: double.tryParse(costCtrl.text) ?? 0.0,
                    sellPrice: double.tryParse(sellCtrl.text) ?? 0.0,
                    quantity: int.tryParse(qtyCtrl.text) ?? 0,
                  ));
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _addNewTransactionDialog() {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String selectedType = 'قبض';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('إضافة حركة مالية'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'البيان / الوصف')),
              TextField(controller: amountCtrl, decoration: const InputDecoration(labelText: 'المبلغ'), keyboardType: TextInputType.number),
              DropdownButton<String>(
                value: selectedType,
                isExpanded: true,
                items: ['قبض', 'صرف'].map((String val) {
                  return DropdownMenuItem<String>(value: val, child: Text(val));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setDialogState(() => selectedType = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.isNotEmpty && amountCtrl.text.isNotEmpty) {
                  setState(() {
                    _transactions.add(TransactionModel(
                      id: DateTime.now().toString(),
                      title: titleCtrl.text,
                      amount: double.tryParse(amountCtrl.text) ?? 0.0,
                      type: selectedType,
                      date: DateTime.now(),
                    ));
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }
}