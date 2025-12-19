import 'package:flutter/material.dart';
import 'package:gedik_mobil/services/auth_service.dart';
import 'package:gedik_mobil/features/login/pages/login_page.dart';
import 'package:gedik_mobil/features/map/pages/map_page.dart';
import 'package:gedik_mobil/features/kimlik/pages/digital_id_page.dart';
import 'package:gedik_mobil/features/hocaVeKuluep/pages/hoca_ve_kuluep.dart';
import 'announcements_page.dart';
import 'cafeteria_page.dart';
import 'program_page.dart';
import 'request_suggestion_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  int currentIndex = 0;

  // 🔥 Sayfalar listesi
  final pages = [
    const CafeteriaPage(),
    const AnnouncementsPage(),
    const ProgramPage(),
    const MapPage(),
    const DigitalIDPage(),
    const HocaVeKuluep(),
    const RequestSuggestionPage(),
  ];

  // 🔥 ÇIKIŞ FONKSİYONU
  Future<void> logout() async {
    try {
      await _authService.signOut();

      if (!mounted) return;
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Çıkış hatası: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gedik Mobil"),
        backgroundColor: const Color.fromARGB(255, 136, 31, 96),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
            tooltip: "Çıkış Yap",
          ),
        ],
      ),

      body: pages[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: const Color.fromARGB(255, 136, 31, 96),
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => currentIndex = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: "Yemekhane",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: "Duyurular",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Program",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Harita"),
          BottomNavigationBarItem(icon: Icon(Icons.badge), label: "Kimlik"),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: "Hocalar",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback),
            label: "İstek/Öneri",
          ),
        ],
      ),
    );
  }
}
