import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DigitalIDPage extends StatelessWidget {
  const DigitalIDPage({super.key});

  Future<Map<String, dynamic>?> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) return null;

    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    if (!doc.exists) return null;

    return doc.data() as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchUserData(),
      builder: (context, snapshot) {
        // ⏳ YÜKLEME
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color.fromARGB(255, 136, 31, 96),
            ),
          );
        }

        // ❌ HATA
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              "Bir hata oluştu.",
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
          );
        }

        final data = snapshot.data;

        if (data == null) {
          return const Center(
            child: Text(
              "Kullanıcı bilgileri bulunamadı.",
              style: TextStyle(fontSize: 18),
            ),
          );
        }

        // 🎉 KİMLİK KARTI TASARIMI
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 136, 31, 96),
                  Color.fromARGB(255, 180, 70, 140),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white.withOpacity(0.95),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Profil Fotoğrafı Icon
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: const Color.fromARGB(255, 136, 31, 96),
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    data["name"] ?? "",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 60, 0, 50),
                    ),
                  ),

                  const SizedBox(height: 15),

                  _infoRow(
                    Icons.confirmation_number,
                    "Öğrenci No",
                    data["studentNumber"],
                  ),
                  _divider(),
                  _infoRow(Icons.school, "Bölüm", data["department"]),
                  _divider(),
                  _infoRow(Icons.class_, "Sınıf", "${data["class"]}. Sınıf"),
                  _divider(),
                  _infoRow(
                    Icons.email,
                    "Mail",
                    "${data["studentNumber"]}@gedik.edu.tr",
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // BİLGİ SATIRI TASARIMI
  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Color.fromARGB(255, 136, 31, 96)),
          const SizedBox(width: 10),
          Text(
            "$label: ",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 18))),
        ],
      ),
    );
  }

  // Aralara ince çizgi
  Widget _divider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      height: 1,
      color: Colors.black12,
    );
  }
}
