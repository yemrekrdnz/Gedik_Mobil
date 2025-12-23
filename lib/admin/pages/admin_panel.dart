import 'package:flutter/material.dart';
import 'package:gedik_mobil/services/auth_service.dart';
import 'package:gedik_mobil/features/login/pages/login_page.dart';
import 'announcement_management_page.dart';
import 'cafeteria_management_page.dart';
import 'request_suggestion_management_page.dart';

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
    const RequestSuggestionManagementPage(),
  ];

  Future<void> logout() async {
    await _authService.signOut();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Paneli"),
        backgroundColor: const Color.fromARGB(255, 136, 31, 96),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: logout),
        ],
      ),
      body: _pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: const Color.fromARGB(255, 136, 31, 96),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Panel"),
          BottomNavigationBarItem(
            icon: Icon(Icons.announcement),
            label: "Duyurular",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: "Yemekhane",
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
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
          const SizedBox(height: 24),

          HoverDashboardCard(
            title: "Duyurular",
            icon: Icons.announcement,
            color: Colors.blue,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AnnouncementManagementPage(),
              ),
            ),
          ),
          const SizedBox(height: 16),

          HoverDashboardCard(
            title: "Yemekhane Menüsü",
            icon: Icons.restaurant_menu,
            color: Colors.green,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CafeteriaManagementPage(),
              ),
            ),
          ),
          const SizedBox(height: 16),

          HoverDashboardCard(
            title: "İstek & Öneriler",
            icon: Icons.feedback,
            color: Colors.purple,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const RequestSuggestionManagementPage(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🔥 HOVER ANİMASYONLU KART
class HoverDashboardCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const HoverDashboardCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<HoverDashboardCard> createState() => _HoverDashboardCardState();
}

class _HoverDashboardCardState extends State<HoverDashboardCard> {
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHover = true),
      onExit: (_) => setState(() => isHover = false),
      child: AnimatedScale(
        scale: isHover ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isHover ? 0.25 : 0.15),
                blurRadius: isHover ? 18 : 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 100,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [widget.color.withOpacity(0.75), widget.color],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(widget.icon, size: 42, color: Colors.white),
                    const SizedBox(width: 16),
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
