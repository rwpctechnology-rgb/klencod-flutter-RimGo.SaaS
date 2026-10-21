import 'package:flutter/material.dart';
import '../../sales/presentation/sales_screen.dart';
import '../../cash/presentation/cash_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RimGo SaaS - لوحة التحكم'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      drawer: NavigationDrawer(
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text('RimGo SaaS ERP'),
            accountEmail: const Text('فرع الخليل - الشيكل (ILS)'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.store, color: Theme.of(context).colorScheme.primary),
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('لوحة التحكم'),
            selected: true,
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.point_of_sale),
            title: const Text('فاتورة بيع جديدة'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SalesScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: const Text('الصندوق والحركات النقدية'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CashScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.inventory_2),
            title: const Text('المنتجات والمخزون'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('العملاء والموردين'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('التقارير المالية والأرباح'),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('الإعدادات والنسخ الاحتياطي'),
            onTap: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بطاقات المؤشرات المالية الرئيسية
            const Text(
              'الملخص المالي اليومي',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.3,
              children: [
                _buildStatCard(
                  context,
                  title: 'إجمالي المبيعات',
                  value: '₪ 45,200',
                  icon: Icons.shopping_cart,
                  color: Colors.blue,
                ),
                _buildStatCard(
                  context,
                  title: 'صافي الربح',
                  value: '₪ 8,450',
                  icon: Icons.trending_up,
                  color: Colors.green,
                ),
                _buildStatCard(
                  context,
                  title: 'رصيد الصندوق',
                  value: '₪ 15,450',
                  icon: Icons.account_balance_wallet,
                  color: Colors.indigo,
                ),
                _buildStatCard(
                  context,
                  title: 'ديون لنا (عملاء)',
                  value: '₪ 12,300',
                  icon: Icons.call_received,
                  color: Colors.orange,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // الوصول السريع للعمليات
            const Text(
              'إجراءات سريعة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SalesScreen()),
                      );
                    },
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('فاتورة بيع'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CashScreen()),
                      );
                    },
                    icon: const Icon(Icons.receipt_long),
                    label: const Text('سند قبض / صرف'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // تنبيهات المخزون
            Card(
              color: Colors.amber.shade50,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.amber.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const ListTile(
                leading: Icon(Icons.warning_amber_rounded, color: Colors.amber),
                title: Text('تنبيه المخزون المنخفض', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('هناك 3 منتجات وصلت للحد الأدنى من الكمية المطلوب توفرها.'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, color: Colors.black87)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
