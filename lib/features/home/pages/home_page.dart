import 'package:flutter/material.dart';
import 'package:gedik_mobil/services/auth_service.dart';
import 'package:gedik_mobil/features/login/pages/login_page.dart';
import 'package:gedik_mobil/features/map/pages/map_page.dart';
import 'package:gedik_mobil/features/kimlik/pages/digital_id_page.dart';
import 'package:gedik_mobil/features/hocaVeKul%C3%BCp/pages/hoca_ve_kulup.dart';

import 'cafeteria_page.dart';
import 'announcements_page.dart';
import 'program_page.dart';
import 'request_suggestion_page.dart';
import 'career_plan_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  int currentIndex = 0;

  final List<Widget> pages = const [
    CafeteriaPage(),
    AnnouncementsPage(),
    MapPage(),
    HocaVeKuluep(),
    DigitalIDPage(),
  ];

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Çıkış hatası: $e')));
    }
  }

  void onMenuSelected(String value) {
    switch (value) {
      case 'program':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProgramPage()),
        );
        break;
      case 'request':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RequestSuggestionPage()),
        );
        break;
      case 'career_plan':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CareerPlanPage()),
        );
        break;
      case 'logout':
        logout();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    const appBarColor = Color.fromARGB(255, 136, 31, 96);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        foregroundColor: Colors.white,

        // 🔥 SOL ÜST LOGO (TITLE YERİNE)
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: appBarColor.withOpacity(0.85), // arkaplan
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(
                'assets/images/logo.png',
                height: 28,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              "Gedik Mobil",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),

        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu),
            onSelected: onMenuSelected,
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'program',
                child: ListTile(
                  leading: Icon(Icons.calendar_today),
                  title: Text("Program"),
                ),
              ),
              PopupMenuItem(
                value: 'request',
                child: ListTile(
                  leading: Icon(Icons.feedback),
                  title: Text("Dilek / İstek"),
                ),
              ),
              PopupMenuItem(
                value: 'career_plan',
                child: ListTile(
                  leading: Icon(Icons.psychology),
                  title: Text("Kariyer Planım"),
                ),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text("Çıkış Yap"),
                ),
              ),
            ],
          ),
        ],
      ),

      body: pages[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: appBarColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() => currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: "Yemekhane",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: "Duyurular",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Harita"),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: "Kadro & Kulüp",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.badge), label: "Kimlik"),
        ],
      ),
    );
  }
}
