import 'package:flutter/material.dart';

void main() {
  runApp(const AccountingApp());
}

class AccountingApp extends StatelessWidget {
  const AccountingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'نظام المحاسبة والصيانة المتكامل',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const MainHomeScreen(),
    );
  }
}

// --- النماذج (Models) ---

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
}

class Product {
  final String id;
  final String name;
  double costPrice;
  double sellPrice;
  int quantity;

  Product({
    required this.id,
    required this.name,
    required this.costPrice,
    required this.sellPrice,
    required this.quantity,
  });
}

class MaintenanceTicket {
  final String id;
  final String clientName;
  final String clientPhone;
  final String deviceModel;
  final String issueDescription;
  String status; // 'قيد الفحص', 'بانتظار قطع غيار', 'تم الإصلاح', 'تم التسليم'
  double laborCost; // أجور اليد
  double partsCost; // تكلفة قطع الغيار
  bool isInvoiced; // هل تحولت لفاتورة

  MaintenanceTicket({
    required this.id,
    required this.clientName,
    required this.clientPhone,
    required this.deviceModel,
    required this.issueDescription,
    this.status = 'قيد الفحص',
    this.laborCost = 0.0,
    this.partsCost = 0.0,
    this.isInvoiced = false,
  });

  double get totalPrice => laborCost + partsCost;
}

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final String type; // 'قبض', 'صرف', 'فاتورة صيانة', 'بيع'
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
  });
}

// --- الشاشة الرئيسية ---

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _selectedIndex = 0;

  final List<Account> _accounts = [
    Account(id: '1', name: 'سامر خالد', phone: '0590000000', debit: 250, credit: 0),
  ];

  final List<Product> _products = [
    Product(id: '1', name: 'شاشة أيفون 13', costPrice: 40, sellPrice: 65, quantity: 5),
    Product(id: '2', name: 'بطارية سامسونج S21', costPrice: 15, sellPrice: 25, quantity: 8),
  ];

  final List<MaintenanceTicket> _tickets = [
    MaintenanceTicket(
      id: 'T-1001',
      clientName: 'سامر خالد',
      clientPhone: '0590000000',
      deviceModel: 'iPhone 13 Pro',
      issueDescription: 'تبديل شاشة مكسورة',
      status: 'قيد الفحص',
      laborCost: 20.0,
      partsCost: 65.0,
    ),
  ];

  final List<TransactionModel> _transactions = [];

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildDashboardTab(),
      _buildTicketsTab(),
      _buildAccountsTab(),
      _buildProductsTab(),
      _buildTransactionsTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('المحاسب الذكي وإدارة الصيانة', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.build_outlined), selectedIcon: Icon(Icons.build), label: 'الصيانة'),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'الحسابات'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'الأصناف'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'الحركات'),
        ],
      ),
    );
  }

  // 1. لوحة التحكم
  Widget _buildDashboardTab() {
    double totalDebit = _accounts.fold(0, (sum, item) => sum + item.debit);
    double totalCredit = _accounts.fold(0, (sum, item) => sum + item.credit);
    int activeTickets = _tickets.where((t) => t.status != 'تم التسليم').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: _buildCard('تذاكر الصيانة النشطة', '$activeTickets جهاز', Colors.orange)),
              const SizedBox(width: 10),
              Expanded(child: _buildCard('إجمالي المدين (لكم)', '\$${totalDebit.toStringAsFixed(1)}', Colors.green)),
            ],
          ),
          const SizedBox(height: 10),
          _buildCard('إجمالي الدائن (عليكم)', '\$${totalCredit.toStringAsFixed(1)}', Colors.red),
          const SizedBox(height: 20),
          const Text('تذاكر الصيانة الحالية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _tickets.length,
            itemBuilder: (ctx, idx) => _buildTicketCard(_tickets[idx]),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, String val, Color col) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 6),
            Text(val, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: col)),
          ],
        ),
      ),
    );
  }

  // 2. شاشة تذاكر الصيانة
  Widget _buildTicketsTab() {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewTicketDialog,
        icon: const Icon(Icons.add_to_photos),
        label: const Text('تذكرة صيانة جديدة'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _tickets.length,
        itemBuilder: (ctx, idx) => _buildTicketCard(_tickets[idx]),
      ),
    );
  }

  Widget _buildTicketCard(MaintenanceTicket ticket) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: ticket.isInvoiced ? Colors.green.shade100 : Colors.orange.shade100,
          child: Icon(ticket.isInvoiced ? Icons.check_circle : Icons.build,
              color: ticket.isInvoiced ? Colors.green : Colors.orange),
        ),
        title: Text('${ticket.deviceModel} - ${ticket.clientName}', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('الحالة: ${ticket.status} | الإجمالي: \$${ticket.totalPrice}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('رقم التذكرة: ${ticket.id}'),
                Text('رقم العميل: ${ticket.clientPhone}'),
                Text('الوصف/المشكلة: ${ticket.issueDescription}'),
                Text('تكلفة قطع الغيار: \$${ticket.partsCost}'),
                Text('أجور الصيانة (اليد): \$${ticket.laborCost}'),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DropdownButton<String>(
                      value: ticket.status,
                      items: ['قيد الفحص', 'بانتظار قطع غيار', 'تم الإصلاح', 'تم التسليم']
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => ticket.status = val);
                      },
                    ),
                    if (!ticket.isInvoiced)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                        onPressed: () => _convertTicketToInvoice(ticket),
                        icon: const Icon(Icons.receipt),
                        label: const Text('تحويل إلى فاتورة'),
                      )
                    else
                      const Chip(label: Text('تم الفوترة'), backgroundColor: Colors.greenAccent),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void _convertTicketToInvoice(MaintenanceTicket ticket) {
    setState(() {
      ticket.isInvoiced = true;
      ticket.status = 'تم التسليم';
      _transactions.add(TransactionModel(
        id: DateTime.now().toString(),
        title: 'فاتورة صيانة: ${ticket.deviceModel} (${ticket.clientName})',
        amount: ticket.totalPrice,
        type: 'فاتورة صيانة',
        date: DateTime.now(),
      ));

      // إضافة المبلغ لمدين العميل تلقائياً
      var acc = _accounts.firstWhere((a) => a.name == ticket.clientName,
          orElse: () => Account(id: DateTime.now().toString(), name: ticket.clientName, phone: ticket.clientPhone));
      acc.debit += ticket.totalPrice;
      if (!_accounts.contains(acc)) _accounts.add(acc);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم تحويل التذكرة ${ticket.id} إلى فاتورة وإضافتها لحساب العميل!')),
    );
  }

  void _addNewTicketDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final modelCtrl = TextEditingController();
    final issueCtrl = TextEditingController();
    final partsCtrl = TextEditingController();
    final laborCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة تذكرة صيانة جديد'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم العميل')),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'رقم الهاتف'), keyboardType: TextInputType.phone),
              TextField(controller: modelCtrl, decoration: const InputDecoration(labelText: 'نوع/موديل الجهاز')),
              TextField(controller: issueCtrl, decoration: const InputDecoration(labelText: 'وصف العطل')),
              TextField(controller: partsCtrl, decoration: const InputDecoration(labelText: 'تكلفة قطع الغيار'), keyboardType: TextInputType.number),
              TextField(controller: laborCtrl, decoration: const InputDecoration(labelText: 'أجور اليد / الصيانة'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && modelCtrl.text.isNotEmpty) {
                setState(() {
                  _tickets.add(MaintenanceTicket(
                    id: 'T-${1000 + _tickets.length + 1}',
                    clientName: nameCtrl.text,
                    clientPhone: phoneCtrl.text,
                    deviceModel: modelCtrl.text,
                    issueDescription: issueCtrl.text,
                    partsCost: double.tryParse(partsCtrl.text) ?? 0.0,
                    laborCost: double.tryParse(laborCtrl.text) ?? 0.0,
                  ));
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('حفظ التذكرة'),
          ),
        ],
      ),
    );
  }

  // 3. باقي الشاشات (الحسابات، الأصناف، الحركات)
  Widget _buildAccountsTab() {
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _accounts.length,
        itemBuilder: (ctx, idx) {
          final acc = _accounts[idx];
          return Card(
            child: ListTile(
              title: Text(acc.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('هاتف: ${acc.phone}'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('له (مدين): \$${acc.debit}', style: const TextStyle(color: Colors.green, fontSize: 12)),
                  Text('عليه (دائن): \$${acc.credit}', style: const TextStyle(color: Colors.red, fontSize: 12)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductsTab() {
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _products.length,
        itemBuilder: (ctx, idx) {
          final prod = _products[idx];
          return Card(
            child: ListTile(
              title: Text(prod.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('تكلفة: \$${prod.costPrice} | بيع: \$${prod.sellPrice}'),
              trailing: Chip(label: Text('المتوفر: ${prod.quantity}')),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionsTab() {
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _transactions.length,
        itemBuilder: (ctx, idx) {
          final tx = _transactions[idx];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.receipt, color: Colors.blue),
              title: Text(tx.title),
              subtitle: Text('النوع: ${tx.type}'),
              trailing: Text('\$${tx.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
            ),
          );
        },
      ),
    );
  }
}