import 'package:flutter/material.dart';
import 'features/erp_manager_screen.dart';

void main() {
  runApp(const RimGoApp());
}

class RimGoApp extends StatelessWidget {
  const RimGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RimGo SaaS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: const ErpManagerScreen(), // التوجيه المباشر للشاشة الشاملة الجديدة
    );
  }
}