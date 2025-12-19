import 'package:flutter/material.dart';
import 'package:gedik_mobil/services/auth_service.dart';
import 'package:gedik_mobil/features/login/pages/login_page.dart';
import 'announcement_management_page.dart';
import 'cafeteria_management_page.dart';
import 'request_suggestion_management_page.dart';
import 'program_management_page.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final AuthService _authService = AuthService();
  int currentIndex = 0;

  final List<Widget> _pages = [
    const AdminDashboard(),
    const AnnouncementManagementPage(),
    const CafeteriaManagementPage(),
    const ProgramManagementPage(),
    const RequestSuggestionManagementPage(),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Çıkış hatası: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Paneli"),
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
      body: _pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: const Color.fromARGB(255, 136, 31, 96),
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => currentIndex = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Panel",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.announcement),
            label: "Duyurular",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: "Yemekhane",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Program",
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

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Hoş Geldiniz, Admin!",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 136, 31, 96),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildDashboardCard(
                  context,
                  "Duyurular",
                  Icons.announcement,
                  Colors.blue,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AnnouncementManagementPage(),
                    ),
                  ),
                ),
                _buildDashboardCard(
                  context,
                  "Yemekhane Menüsü",
                  Icons.restaurant_menu,
                  Colors.green,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CafeteriaManagementPage(),
                    ),
                  ),
                ),
                _buildDashboardCard(
                  context,
                  "Program Yönetimi",
                  Icons.calendar_today,
                  Colors.orange,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProgramManagementPage(),
                    ),
                  ),
                ),
                _buildDashboardCard(
                  context,
                  "İstek & Öneri",
                  Icons.feedback,
                  Colors.purple,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RequestSuggestionManagementPage(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.7), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
