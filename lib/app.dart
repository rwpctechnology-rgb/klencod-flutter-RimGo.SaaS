import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';

class RimGoApp extends StatelessWidget {
  const RimGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RimGo SaaS ERP',
      debugShowCheckedModeBanner: false,
      
      // دعم اللغة العربية واتجاه الواجهة RTL بشكل كامل
      locale: const Locale('ar', 'AE'),
      supportedLocales: const [
        Locale('ar', 'AE'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // التصميم والهوية البصرية (أزرق وبنفسجي احترافي)
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A), // الأزرق التجاري
          secondary: const Color(0xFF7C3AED), // البنفسجي الاحترافي
          brightness: Brightness.light,
        ),
        fontFamily: 'Cairo', // يمكن اعتماده خطاً عربياً أساسياً لاحقاً
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B82F6),
          secondary: const Color(0xFF8B5CF6),
          brightness: Brightness.dark,
        ),
      ),

      // الشاشة الرئيسية المبدئية (لوحة التحكم المحاسبية)
      home: const DashboardScreen(),
    );
  }
}
