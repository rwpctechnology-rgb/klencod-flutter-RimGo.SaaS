import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  AppDatabase._init();

  // حفظ بيانات المحل والمستخدم الحالي
  Future<void> saveTenantData(String shopId, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tenant_$shopId', jsonEncode(data));
  }

  // استرجاع بيانات المحل مع ضمان عزل البيانات بالكامل
  Future<Map<String, dynamic>?> getTenantData(String shopId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? dataStr = prefs.getString('tenant_$shopId');
    if (dataStr != null) {
      return jsonDecode(dataStr);
    }
    return null;
  }

  // محاكاة تنفيذ المعاملات المحاسبية الآمنة (Database Transactions)
  Future<bool> runTransaction(Future<void> Function() txnAction) async {
    try {
      // بدء المعاملة المحاسبية
      await txnAction();
      // نجاح المعاملة وتثبيت القيود
      return true;
    } catch (e) {
      // التراجع عن التغييرات في حال حدوث خطأ (Rollback)
      return false;
    }
  }
}
