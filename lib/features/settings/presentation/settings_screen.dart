import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات والنسخ الاحتياطي'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          const ListTile(
            title: Text('إعدادات المتجر والمعلومات', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('الاسم التجاري، العنوان، والعملة (ILS, JOD, USD)'),
            leading: Icon(Icons.store),
          ),
          const Divider(),
          ListTile(
            title: const Text('النسخ الاحتياطي وتصدير البيانات'),
            subtitle: const Text('حفظ نسخة احتياطية من البيانات والمخزون'),
            leading: const Icon(Icons.cloud_upload),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إنشاء نسخة احتياطية من البيانات بنجاح!')));
            },
          ),
          const Divider(),
          const ListTile(
            title: Text('إعدادات طباعة الفواتير'),
            subtitle: Text('ربط الطابعة الحرارية وتنسيق الورق (80mm / 58mm)'),
            leading: Icon(Icons.print),
          ),
        ],
      ),
    );
  }
}
