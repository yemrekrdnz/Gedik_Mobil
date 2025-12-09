import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gedik_mobil/features/login/pages/login_page.dart';
import 'package:gedik_mobil/features/map/pages/map_page.dart';

// 🔥 Dijital Kimlik sayfasını import et
import 'package:gedik_mobil/features/kimlik/pages/digital_id_page.dart';

// 🔥 Akademik Bilgi sayfasını import et
import 'package:gedik_mobil/features/hocaVeKuluep/pages/hoca_ve_kuluep.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  // 🔥 Sayfalar listesi
  final pages = [
    Center(child: Text("Yemekhane")),
    Center(child: Text("Duyurular")),
    const MapPage(),

    // 🔥 Dijital Kimlik
    const DigitalIDPage(),
    
    // 🔥 Akademik Bilgi (Kadro & Kulüpler)
    const HocaVeKuluep(),
  ];

  // 🔥 ÇIKIŞ FONKSİYONU
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false, // tüm geçmişi sil → geri dönemez
    );
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
        type: BottomNavigationBarType.fixed, // 5 item için gerekli
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
          BottomNavigationBarItem(icon: Icon(Icons.badge), label: "Kimlik"),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: "Hoca Ve Kulüp"),
        ],
      ),
    );
  }
}
