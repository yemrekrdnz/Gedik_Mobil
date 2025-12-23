import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:gedik_mobil/features/login/pages/login_page.dart';
import 'package:gedik_mobil/utils/app_theme.dart';
import 'package:gedik_mobil/services/notification_service.dart'; // 🔔 EKLENDİ

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 🔔 LOCAL NOTIFICATION INIT
  await NotificationService.init();

  runApp(const GedikMobilApp());
}

class GedikMobilApp extends StatelessWidget {
  const GedikMobilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gedik Mobil',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginPage(),
    );
  }
}
