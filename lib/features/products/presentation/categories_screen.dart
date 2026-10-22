import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<Map<String, dynamic>> categories = [];
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController parentCtrl = TextEditingController(text: 'رئيسي');

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('rimgo_categories_tree');
    if (data != null) {
      setState(() {
        categories = List<Map<String, dynamic>>.from(jsonDecode(data));
      });
    } else {
      setState(() {
        categories = [
          {'name': 'إلكترونيات وأجهزة', 'parent': 'رئيسي'},
          {'name': 'هواتف ذكية', 'parent': 'إلكترونيات وأجهزة'},
          {'name': 'إكسسوارات وشواحن', 'parent': 'إلكترونيات وأجهزة'},
          {'name': 'قطع غيار صيانة', 'parent': 'رئيسي'},
        ];
      });
    }
  }

  Future<void> _saveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('rimgo_categories_tree', jsonEncode(categories));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('شجرة وتصنيفات الأصناف'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    const Text('إضافة قسم أو تصنيف جديد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'اسم التصنيف أو المجموعة', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: parentCtrl,
                      decoration: const InputDecoration(labelText: 'التصنيف الأب (أو اكتب رئيسي)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                        onPressed: () {
                          if (nameCtrl.text.isNotEmpty) {
                            setState(() {
                              categories.add({
                                'name': nameCtrl.text,
                                'parent': parentCtrl.text.isEmpty ? 'رئيسي' : parentCtrl.text,
                              });
                              nameCtrl.clear();
                              parentCtrl.text = 'رئيسي';
                            });
                            _saveCategories();
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت إضافة التصنيف بنجاح!')));
                          }
                        },
                        icon: const Icon(Icons.account_tree),
                        label: const Text('حفظ التصنيف'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerRight,
              child: Text('هيكلية وتصنيفات المخزون:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: categories.isEmpty
                  ? const Center(child: Text('لا توجد تصنيفات مسجلة'))
                  : ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (ctx, i) {
                        var cat = categories[i];
                        bool isMain = cat['parent'] == 'رئيسي';
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isMain ? Colors.blue.shade100 : Colors.teal.shade100,
                              child: Icon(isMain ? Icons.folder : Icons.subdirectory_arrow_right, color: isMain ? Colors.blue : Colors.teal),
                            ),
                            title: Text(cat['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('يتبع لمجموعة: ${cat['parent']}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  categories.removeAt(i);
                                });
                                _saveCategories();
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}