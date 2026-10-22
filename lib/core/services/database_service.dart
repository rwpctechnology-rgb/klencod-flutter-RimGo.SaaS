import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseService {
  static const String _keyProducts = 'rimgo_global_products';
  static const String _keyParties = 'rimgo_global_parties';
  static const String _keyInvoices = 'rimgo_global_invoices';

  // حفظ واسترجاع المنتجات
  static Future<List<Map<String, dynamic>>> getProducts() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString(_keyProducts);
    if (data != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(data));
    }
    // بيانات أولية افتراضية في حال كانت القائمة فارغة
    return [
      {'code': '101', 'name': 'حقيبة لابتوب', 'price': 35.0, 'stock': 10},
      {'code': '102', 'name': 'شاحن سريع 65W', 'price': 15.0, 'stock': 25},
    ];
  }

  static Future<void> saveProducts(List<Map<String, dynamic>> products) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyProducts, jsonEncode(products));
  }

  // حفظ واسترجاع العملاء والموردين
  static Future<List<Map<String, dynamic>>> getParties() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString(_keyParties);
    if (data != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(data));
    }
    return [
      {'name': 'زبون نقدي عام', 'phone': '000', 'type': 'customer', 'balance': 0.0},
      {'name': 'شركة الأمل للتجارة', 'phone': '0599000111', 'type': 'customer', 'balance': 150.0},
    ];
  }

  static Future<void> saveParties(List<Map<String, dynamic>> parties) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyParties, jsonEncode(parties));
  }

  // حفظ واسترجاع الفواتير
  static Future<List<Map<String, dynamic>>> getInvoices() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString(_keyInvoices);
    if (data != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(data));
    }
    return [];
  }

  static Future<void> saveInvoices(List<Map<String, dynamic>> invoices) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyInvoices, jsonEncode(invoices));
  }
}
